/*
AJRInspectorTextField.swift
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

@objc
protocol AJRInspectorTextFieldDelegate : NSTextFieldDelegate {
    
    @objc optional func textField(_ textField: AJRInspectorTextField, willBeginEditingInFieldEditor text: NSTextView) -> Void
    @objc optional func textField(_ textField: AJRInspectorTextField, didEndEditingInFieldEditor text: NSTextView) -> Void
    @objc optional func textField(_ textField: AJRInspectorTextField, selectionDidChangeInFieldEditor text: NSTextView) -> Void
    @objc optional func textField(_ textField: AJRInspectorTextField, typingAttributesDidChangeInFieldEditor text: NSTextView) -> Void

}

class AJRInspectorTextFieldCell: NSTextFieldCell, NSTextDelegate {

    weak var selectionDidChangeObserverToken : AnyObject? = nil
    weak var didEndEditingObserverToken : AnyObject? = nil
    weak var typingAttributesDidChangeObserverToken : AnyObject? = nil
    weak var textDidChangeObserverToken : AnyObject? = nil
    
    deinit {
        stopObserving(token: &selectionDidChangeObserverToken)
        stopObserving(token: &didEndEditingObserverToken)
        stopObserving(token: &typingAttributesDidChangeObserverToken)
        stopObserving(token: &textDidChangeObserverToken)
    }

    internal func stopObserving(token: inout AnyObject?) {
        if token != nil {
            NotificationCenter.default.removeObserver(token!)
            token = nil
        }
    }

    open override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
        let text = super.setUpFieldEditorAttributes(textObj)
        
        if let text = text as? NSTextView {
            if backgroundColor?.isDark ?? false {
                text.insertionPointColor = NSColor.white
            } else {
                text.insertionPointColor = NSColor.textColor
            }
        }

        if let controlView = controlView as? NSTextField {
            if controlView.allowsEditingTextAttributes {
                let string = controlView.attributedStringValue.mutableCopy() as! NSMutableAttributedString
                (text as? NSTextView)?.textStorage?.setAttributedString(string)
            }
            
            weak var weakSelf = self
            selectionDidChangeObserverToken = NotificationCenter.default.addObserver(forName: NSTextView.didChangeSelectionNotification, object: text, queue: nil, using: { (notification) in
                if let text = notification.object as? NSTextView,
                    let strongSelf = weakSelf,
                    let textField = strongSelf.controlView as? AJRInspectorTextField,
                    let delegate = textField.delegate as? AJRInspectorTextFieldDelegate {
                    delegate.textField?(textField, selectionDidChangeInFieldEditor: text)
                }
            })
            didEndEditingObserverToken = NotificationCenter.default.addObserver(forName: NSControl.textDidEndEditingNotification, object: controlView, queue: nil, using: { (notification) in
                print("end editing")
                if let strongSelf = weakSelf {
                    strongSelf.stopObserving(token: &strongSelf.selectionDidChangeObserverToken)
                    strongSelf.stopObserving(token: &strongSelf.didEndEditingObserverToken)
                    strongSelf.stopObserving(token: &strongSelf.typingAttributesDidChangeObserverToken)
                    strongSelf.stopObserving(token: &strongSelf.textDidChangeObserverToken)
                    if let text = text as? NSTextView {
                        text.insertionPointColor = NSColor.white
                        if let textField = strongSelf.controlView as? AJRInspectorTextField,
                            let delegate = textField.delegate as? AJRInspectorTextFieldDelegate {
                            delegate.textField?(textField, didEndEditingInFieldEditor: text)
                        }
                    }
                }
            })
            typingAttributesDidChangeObserverToken = NotificationCenter.default.addObserver(forName: NSTextView.didChangeTypingAttributesNotification, object: text, queue: nil, using: { (notification) in
                if let strongSelf = weakSelf,
                    let textField = strongSelf.controlView as? AJRInspectorTextField {
                    if let text = text as? NSTextView,
                        let delegate = textField.delegate as? AJRInspectorTextFieldDelegate {
                        delegate.textField?(textField, typingAttributesDidChangeInFieldEditor: text)
                    }
                    if textField.isContinuous, let action = textField.action {
                        NSApp.sendAction(action, to: textField.target, from: textField)
                    }
                }
            })
            textDidChangeObserverToken = NotificationCenter.default.addObserver(forName: NSTextView.didChangeNotification, object: text, queue: nil, using: { (notification) in
                if let strongSelf = weakSelf,
                    let textField = strongSelf.controlView as? AJRInspectorTextField,
                    textField.isContinuous, let action = textField.action {
                    NSApp.sendAction(action, to: textField.target, from: textField)
                }
            })
        }
        
        text.delegate = self
        
        if let text = textObj as? NSTextView,
            let textField = controlView as? AJRInspectorTextField,
            let delegate = textField.delegate as? AJRInspectorTextFieldDelegate {
            delegate.textField?(textField, willBeginEditingInFieldEditor: text)
        }

        return text
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        if let textView = notification.object as? NSTextView {
            print("selection change 2: \(textView.selectedRange)")
        }
    }

}

class AJRInspectorTextField: NSTextField {

    open override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        if !isEditable {
            let width = frame.size.width
            let string = attributedStringValue.mutableCopy() as! NSMutableAttributedString
            let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.lineHeightMultiple = 1.0
            string.setAttributes([.paragraphStyle:style], range: NSRange(location: 0, length: string.length))
            var size = string.ajr_sizeConstrained(toWidth: width - 2.0)

            //print("intrinsicContentSize: \(size)")
            // This may seem a bit odd, but what we're really trying to do is grow our height based off our current width. By setting the width to 0, autolayout will basically enforce our desired height, but will make our minimum width 0, which will basically allow the surrounding constraints to enforce our width.
            size.width = 0.0
            
            return size
        }
        return size
    }
    
    override open var nextKeyView: NSView? {
        get {
            return super.nextKeyView
        }
        set {
            super.nextKeyView = newValue
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            if isEditable && isEnabled {
                delegate?.controlTextDidBeginEditing?(Notification(name: NSTextField.textDidBeginEditingNotification))
            }
            return true
        }
        return false
    }
    
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    
}
