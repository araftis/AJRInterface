//
//  NSMutableAttributedString+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 11/12/22.
//

import AJRInterfaceFoundation

@objc
public extension NSMutableAttributedString {

    func applyMarkdownStyles() -> Void {
        self.enumerateAttribute(.presentationIntentAttributeName, in: NSRange(location: 0, length: self.length)) { value, range, stop in
            if let value {
                print("\(range): \(value)")
                self.insert(NSAttributedString(string: "\n"), at: range.upperBound)
            }
        }
    }

}

