//
//  WKBackForewardList+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 2/24/19.
//

import Foundation
import WebKit

@objc
public extension WKBackForwardList {
    
    internal func buildMenu(for history: [WKBackForwardListItem], target: AnyObject?, action: Selector, title: String? = nil) -> NSMenu? {
        var menu : NSMenu?
        let finalTitle = title ?? AJRWebView.translator["History"];
        
        if history.count > 0 {
            menu = NSMenu(title: finalTitle)
            for (index, item) in history.enumerated() {
                if index > 20 {
                    break
                }
                let menuItem = menu!.addItem(withTitle: item.title ?? item.url.absoluteString, action: action, keyEquivalent: "")
                menuItem.target = target
                menuItem.image = AJRWebView.favoriteIcon(for: item.url) ?? AJRWebView.defaultFavoriteIcon
                menuItem.representedObject = item
            }
        }
        
        return menu
    }
    
    @objc
    func buildBackMenu(target: AnyObject?, action: Selector) -> NSMenu? {
        return buildMenu(for: self.backList.reversed(), target: target, action: action, title: AJRWebView.translator["Back"])
    }
    
    @objc
    func buildForwardMenu(target: AnyObject?, action: Selector) -> NSMenu? {
        return buildMenu(for: self.forwardList, target: target, action: action, title: AJRWebView.translator["Forward"])
    }
    
}
