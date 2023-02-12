/*
 AJRBookmark.swift
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

import Cocoa

import AJRFoundation

public extension AJRUserDefaultsKey {
    
    static var bookmarksURL : AJRUserDefaultsKey<URL> {
        return AJRUserDefaultsKey<URL>.key(named: "bookmarksURL", defaultValue: AJRApplicationSupportURL()?.appendingPathComponent("Bookmarks.html"))
    }
    
}

public enum AJRBookmarkError : Error {
    case invalidFormat
}

@objc
public enum AJRBookmarkType : Int, CustomStringConvertible {
    
    case unknown
    case list
    case leaf
    case proxy

    public var description: String {
        switch self {
        case .unknown:
            return "WebBookmarkTypeUnknown"
        case .list:
            return "WebBookmarkTypeList"
        case .leaf:
            return "WebBookmarkTypeLeaf"
        case .proxy:
            return "WebBookmarkTypeProxy"
        }
    }

}

@objcMembers
public class AJRBookmark: NSObject {

    open var type : AJRBookmarkType { preconditionFailure("Subclasses must implement \(#function)") }
    open var title : String
    open var uuid : String
    open var children = [AJRBookmark]()
    open var url : URL?
    
    private static var _hasLoadedBookmarks = false
    private static var _bookmarks : AJRBookmark? = nil
    public class var bookmarks : AJRBookmark? {
        get {
            if !_hasLoadedBookmarks {
                if let url = UserDefaults.standard[.bookmarksURL] {
                    do {
                        _bookmarks = try bookmark(from: url)
                    } catch {
                        AJRLog.error("Failed to read bookmarks: \(error)")
                    }
                    _hasLoadedBookmarks = true
                }
            }
            return _bookmarks
        }
        set {
            _bookmarks = newValue
            _hasLoadedBookmarks = true
            
            if let bookmarks = _bookmarks {
                do {
                    let propertyList = bookmarks.propertyList()
                    let data = try PropertyListSerialization.data(fromPropertyList: propertyList, format: .binary, options: 0)
                    if let url = UserDefaults.standard[.bookmarksURL] {
                        let directory = url.deletingLastPathComponent()
                        print("creating: \(directory.path)")
                        try FileManager.default.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: [:])
                        print("writing to: \(url.path)")
                        try data.write(to: url, options: [.atomic])
                    }
                } catch {
                    AJRLog.error("Failed to save bookmarks: \(error)")
                }
            } else {
            }
        }
    }
    
    @objc(bookmarkFromURL:error:)
    public class func bookmark(from url: URL) throws -> AJRBookmark {
        do {
            let data = try Data(contentsOf: url)
            if let propertyList = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any],
                let bookmark = AJRBookmark.bookmark(from: propertyList) {
                return bookmark
            }
        } catch {
            AJRLog.error("Failed to read data: \(error)")
            throw error
        }
        return AJRBookmarkList(title: "root")
    }
    
    @objc(bookmarkFromPropertyList:)
    public class func bookmark(from propertyList: [String:Any]) -> AJRBookmark? {
        if let type = propertyList["WebBookmarkType"] as? String {
            switch type {
            case "WebBookmarkTypeProxy":
                return AJRBookmarkProxy(propertyList: propertyList)
            case "WebBookmarkTypeLeaf":
                return AJRBookmarkLeaf(propertyList: propertyList)
            case "WebBookmarkTypeList":
                return AJRBookmarkList(propertyList: propertyList)
            default:
                break
            }
        }
        return nil
    }
    
    internal init(title: String) {
        self.title = title;
        self.uuid = ProcessInfo.processInfo.globallyUniqueString
    }
    
    public init?(propertyList: [String:Any]) {
        if let uuid = propertyList["WebBookmarkUUID"] as? String {
            self.uuid = uuid
        } else {
            self.uuid = ProcessInfo.processInfo.globallyUniqueString
        }
        if let title = propertyList["Title"] as? String {
            self.title = title
        } else {
            self.title = ""
        }
    }
    
    public func menuItem(target: AnyObject? = nil, action: Selector? = #selector(AJRGoToBookmarkProtocol.goToBookmark(_:))) -> NSMenuItem? {
        return nil
    }
    
    public func menu(target: AnyObject? = nil, action: Selector? = #selector(AJRGoToBookmarkProtocol.goToBookmark(_:))) -> NSMenu? {
        return nil
    }
    
    public func add(child: AJRBookmark) -> Void {
        children.append(child)
    }
    
    public func remove(child: AJRBookmark) -> Void {
        children.remove(element: child)
    }
    
    public func child(at index: Int) -> AJRBookmark {
        return children[index]
    }

    public func populate(propertyList: inout [String:Any]) -> Void {
        propertyList["WebBookmarkUUID"] = uuid
        propertyList["Title"] = title
        propertyList["WebBookmarkType"] = type.description
    }
    
    public func propertyList() -> [String:Any] {
        var propertyList = [String:Any]()
        populate(propertyList: &propertyList)
        return propertyList
    }
    
    public func append(to string: inout String, indent: Int = 0) -> Void {
    }
    
    public func html() -> String {
        var string = ""
        string += "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n"
        string += "   <META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n"
        string += "   <Title>Bookmarks</Title>\n"
        append(to: &string)
        string += "</HTML>\n"
        return string
    }
    
    // MARK: - Conveniences
    
    public var favorites : AJRBookmark? {
        return children.first(where: { (bookmark) -> Bool in
            return bookmark.title == "BookmarksBar"
        })
    }

}

@objcMembers
public class AJRBookmarkProxy : AJRBookmark {
    
    open override var type : AJRBookmarkType { return .proxy }
    open var identifier : String

    public override init?(propertyList: [String:Any]) {
        if let identifier = propertyList["WebBookmarkIdentifier"] as? String {
            self.identifier = identifier
        } else {
            return nil
        }
        super.init(propertyList: propertyList)
    }
    
    public override func populate(propertyList: inout [String:Any]) -> Void {
        super.populate(propertyList: &propertyList)
        propertyList["WebBookmarkIdentifier"] = identifier
    }
    
    public override func append(to string: inout String, indent: Int = 1) -> Void {
        // Adds nothing. Basically, we don't include these in the export.
    }
    
}

@objcMembers
public class AJRBookmarkList : AJRBookmark {
    
    open override var type : AJRBookmarkType { return .list }

    internal override init(title: String) {
        super.init(title: title)
    }
    
    public override init?(propertyList: [String:Any]) {
        super.init(propertyList: propertyList)
        if let children = propertyList["Children"] as? [[String:Any]] {
            for child in children {
                if let newChild = AJRBookmark.bookmark(from: child) {
                    self.children.append(newChild)
                }
            }
        }
    }
    
    private static var _folderImage : NSImage? = nil
    public class var folderImage : NSImage {
        if _folderImage == nil {
            _folderImage = NSImage(named: NSImage.folderName)?.copy() as? NSImage
            _folderImage?.size = NSSize(width: 16.0, height: 16.0)
        }
        return _folderImage!
    }
    
    public override func menuItem(target: AnyObject? = nil, action: Selector? = #selector(AJRGoToBookmarkProtocol.goToBookmark(_:))) -> NSMenuItem? {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.submenu = self.menu(target: target, action: action)
        menuItem.image = AJRBookmarkList.folderImage
        return menuItem
    }
    
    public override func menu(target: AnyObject? = nil, action: Selector? = #selector(AJRGoToBookmarkProtocol.goToBookmark(_:))) -> NSMenu? {
        let menu = NSMenu(title: title)
        
        for bookmark in children {
            if let menuItem = bookmark.menuItem(target: target, action: action) {
                menu.addItem(menuItem)
            }
        }
        
        menu.font = NSFontManager.shared.convert(menu.font, toSize: 13.0)
        
        return menu
    }
    
    public func bookmark(with title: String) -> AJRBookmark? {
        return children.first(where: { (bookmark) -> Bool in
            bookmark.title == title
        })
    }
    
    public override func populate(propertyList: inout [String:Any]) -> Void {
        super.populate(propertyList: &propertyList)
        var children = [[String:Any]]()
        for child in self.children {
            children.append(child.propertyList())
        }
        propertyList["Children"] = children
    }
    
    public override func append(to string: inout String, indent: Int = 0) -> Void {
        var title = self.title
        if title == "BookmarksBar" {
            title = "Favorites"
        }

        string += "".padding(toLength: indent * 3, withPad: " ", startingAt: 0)
        string += "<DT><H3 FOLDED>\(title)</H3>\n"
        string += "".padding(toLength: indent * 3, withPad: " ", startingAt: 0)
        string += "<DL><p>\n"
        for child in children {
            child.append(to: &string, indent: indent + 1)
        }
        string += "".padding(toLength: indent * 3, withPad: " ", startingAt: 0)
        string += "</DL><p>\n"
    }
    
}

@objcMembers
public class AJRBookmarkLeaf : AJRBookmark {
    
    open override var type : AJRBookmarkType { return .leaf }

    public override init?(propertyList: [String:Any]) {
        super.init(propertyList: propertyList)
        
        if let urlString = propertyList["URLString"] as? String,
            let url = URL(string: urlString) {
            self.url = url
        } else {
            return nil
        }
        
        // Because our title is stored differently
        if let uriDictionary = propertyList["URIDictionary"] as? [String:Any],
            let title = uriDictionary["title"] as? String {
            self.title = title
        }
    }
    
    public init(title: String, url: URL) {
        super.init(title: title)
        self.url = url
    }
    
    public override func menuItem(target: AnyObject? = nil, action: Selector? = #selector(AJRGoToBookmarkProtocol.goToBookmark(_:))) -> NSMenuItem? {
        if let url = url {
            var workTitle = title
            if workTitle.count > 75 {
                workTitle = String(workTitle.prefix(75))
            }
            let menuItem = NSMenuItem(title: workTitle, action: action, keyEquivalent: "")
            menuItem.target = target
            menuItem.image = AJRWebView.favoriteIcon(for: url) ?? AJRWebView.defaultFavoriteIcon
            menuItem.representedObject = self
            return menuItem
        }
        return nil
    }
    
    public override func populate(propertyList: inout [String:Any]) -> Void {
        super.populate(propertyList: &propertyList)
        propertyList.removeValue(forKey: "Title")
        if let url = url {
            propertyList["URLString"] = url.absoluteString
        }
        propertyList["URIDictionary"] = ["title":title]
    }
    
    public override func append(to string: inout String, indent: Int = 0) -> Void {
        string += "".padding(toLength: indent * 3, withPad: " ", startingAt: 0)
        string += "<A HREF=\"\(url?.absoluteString ?? "")\">\(title)</A>\n"
    }
    
}

@objc
public protocol AJRGoToBookmarkProtocol {
    
    func goToBookmark(_ sender: Any?) -> Void
    
}
