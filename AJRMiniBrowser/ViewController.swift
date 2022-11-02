/*
 ViewController.swift
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
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

import AJRInterface
import Cocoa
import WebKit

open class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {

    // MARK: - Properties
    
    private func stopObservingWebView() -> Void {
        if let current = webView {
            current.removeObserver(self, forKeyPath: "estimatedProgress")
            current.removeObserver(self, forKeyPath: "URL")
            current.removeObserver(self, forKeyPath: "favoriteIcon")
            current.removeObserver(self, forKeyPath: "canGoBack")
            current.removeObserver(self, forKeyPath: "canGoForward")
            current.removeObserver(self, forKeyPath: "title")
            current.removeObserver(self, forKeyPath: "currentItem")
        }
    }
    
    @IBOutlet public var webView: AJRWebView! {
        willSet {
            stopObservingWebView()
        }
        didSet {
            if let current = webView {
                current.addObserver(self, forKeyPath: "estimatedProgress", options: [], context: nil)
                current.addObserver(self, forKeyPath: "URL", options: [], context: nil)
                current.addObserver(self, forKeyPath: "favoriteIcon", options: [], context: nil)
                current.addObserver(self, forKeyPath: "canGoBack", options: [], context: nil)
                current.addObserver(self, forKeyPath: "canGoForward", options: [], context: nil)
                current.addObserver(self, forKeyPath: "title", options: [], context: nil)
                current.addObserver(self, forKeyPath: "currentItem", options: [], context: nil)
            }
        }
    }
    
    public var urlField : AJRURLField!
    public var navigationSegments : NSSegmentedControl!
    
    // MARK: - Destruction
    
    deinit {
        stopObservingWebView()
        self.webView = nil
    }

    // MARK: - Utilities
    
    internal func updateNavigationSegments() -> Void {
        if let navigationSegments = navigationSegments {
            navigationSegments.setEnabled(webView.canGoBack, forSegment: 0)
            navigationSegments.setEnabled(webView.canGoForward, forSegment: 1)
            
            if let menu = webView.backForwardList.buildBackMenu(target: self, action: #selector(takeURLFrom(_:))) {
                navigationSegments.setMenu(menu, forSegment: 0)
            }
            if let menu = webView.backForwardList.buildForwardMenu(target: self, action: #selector(takeURLFrom(_:))) {
                navigationSegments.setMenu(menu, forSegment: 1)
            }
        }
    }
    
    // MARK: - NSViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if webView.homeURL == nil {
            webView.homeURL = URL(string: "https://www.apple.com/startpage");
        }
    }
    
    override open func viewDidAppear() {
        super.viewDidAppear()
        
        urlField = view.window?.toolbar?.toolbarItem(forItemIdentifier: "urlField")?.view as? AJRURLField
        navigationSegments = view.window?.toolbar?.toolbarItem(forItemIdentifier: "navigationSegments")?.view as? NSSegmentedControl
        
        updateNavigationSegments()
        urlField.urlValue = webView.url
        
        if webView.url == nil && !webView.isLoading {
            webView.goHome()
        }
    }

    override open var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Actions
    
    @IBAction open func takeURLFrom(_ sender: Any?) -> Void {
        if let menuItem = sender as? NSMenuItem {
            if let historyItem = menuItem.representedObject as? WKBackForwardListItem {
                webView.go(to: historyItem)
            } else if let url = menuItem.representedObject as? URL {
                webView.load(URLRequest(url: url))
            }
        } else if let bookmarkBar = sender as? AJRBookmarksBar,
            let url = bookmarkBar.selectedBookmark?.url {
            webView.load(URLRequest(url: url))
        } else if let url = (sender as? NSControl)?.urlValue {
            print("going to: \(url)")
            webView.load(URLRequest(url: url))
        }
    }
    
    @IBAction open func openLocation(_ sender: Any?) -> Void {
        view.window?.makeFirstResponder(urlField)
    }
    
    @IBAction open func navigateBackOrForward(_ sender: NSSegmentedControl?) -> Void {
        if sender?.selectedSegment == 0 {
            webView.goBack()
        } else if sender?.selectedSegment == 1 {
            webView.goForward()
        }
    }

    // MARK: - WKNavigationDelegate
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("error: \(error)")
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("error: \(error)")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Not actually sufficient, for testing purposes now.
        ((view.window?.delegate as? WindowController)?.document as? Document)?.invalidateRestorableState()
        updateNavigationSegments()
    }
    
    // MARK: - Key/Value Observing
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if webView.estimatedProgress >= 1.0 {
                urlField?.noteProgressComplete()
            } else {
                urlField?.progress = webView.estimatedProgress
            }
        } else if keyPath == "URL" {
            urlField?.urlValue = webView.url
        } else if keyPath == "favoriteIcon" {
            urlField?.icon = webView.favoriteIcon
        } else if keyPath == "canGoBack" {
            updateNavigationSegments()
        } else if keyPath == "canGoForward" {
            updateNavigationSegments()
        } else if keyPath == "currentItem" {
            updateNavigationSegments()
        } else if keyPath == "title" {
            view.window?.title = webView.title ?? webView.url?.absoluteString ?? "Unknown"
            urlField?.titleForDrag = webView.title
        }
    }
    

}

