/*
AJRObjectInspectorViewController.swift
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Cocoa

@objcMembers
open class AJRObjectInspectorViewController: NSViewController {

    public var debugFrames : Bool { return inspectorViewController?.debugFrames ?? false }
    open weak var inspectorViewController : AJRInspectorViewController?
    
    @IBInspectable open var name : String?
    private var _minWidth : CGFloat?
    @IBInspectable open var minWidth : CGFloat {
        get {
            return _minWidth ?? inspectorViewController?.minWidth ?? AJRInspectorViewController.defaultMinWidth
        }
        set {
            if newValue == inspectorViewController?.minWidth {
                _minWidth = nil
            } else {
                _minWidth = newValue
            }
        }
    }
    private var _bundle : Bundle?
    open var bundle : Bundle {
        get {
            return _bundle ?? Bundle.main
        }
        set {
            _bundle = newValue
        }
    }
    private var _xmlName : String?
    @IBInspectable open var xmlName : String! {
        get {
            return _xmlName ?? name
        }
        set {
            _xmlName = name
        }
    }
    @IBOutlet open var controller : NSObjectController? {
        willSet {
            willChangeValue(forKey: "controller")
        }
        didSet {
            didChangeValue(forKey: "controller")
        }
    }
    open var inspectorContent : AJRInspectorContent?
    open var labelWidth : CGFloat = 80.0
    open var fontSize : CGFloat = 10.0

    override public init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public required init(parent: AJRInspectorViewController, name: String?, xmlName: String?, bundle: Bundle?) {
        self.name = name
        self._xmlName = xmlName
        self._bundle = bundle
        self.inspectorViewController = parent
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func loadView() {
        if let url = bundle.url(forResource: xmlName, withExtension: "inspector") {
            do {
                self.translator.addAlternateBundle(bundle)
                weak var weakSelf = self
                inspectorContent = try AJRInspectorContent(url: url, inspectorViewController: self, bundle: bundle) { (url) in
                    weakSelf?.translator.addStringTableName(url.deletingPathExtension().lastPathComponent)
                }
            } catch {
                let error = "Failed to load \(url): \(error)"
                AJRLog.warning(error)
                self.view = AJRInspectorViewController.createView(withLabel: error)
            }
        } else {
            let warning = "Unable to find inspector \(xmlName ?? "") in \(bundle)";
            AJRLog.warning(warning)
            self.view = AJRInspectorViewController.createView(withLabel: warning)
        }
        
        if let inspectorContentView = inspectorContent?.view {
            self.view = inspectorContentView
        }

        view.addConstraint(view.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth))
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     NOTE: This is all necessary, because we override the translator by instances, mainly, we add the name of the inspector xml to the string table names used to find translations. Beacuse this happens on an instance by instance basis, rather than globally for the class, we have to create our own special instance.
     */
    private var translatorNames : [String] {
        var translatorNames = Self.translatorTableNames
        if let name = name {
            translatorNames.append(name)
        }
        if let xmlName = xmlName, name != xmlName {
            translatorNames.append(xmlName)
        }
        return translatorNames
    }
    private var _translator : AJRTranslator!
    override open var ajr_translator : AJRTranslator {
        if _translator == nil {
            _translator = AJRTranslator(for: Self.self, stringTableNames:translatorNames)
        }
        return _translator
    }
    
}
