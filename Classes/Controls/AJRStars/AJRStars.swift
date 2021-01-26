//
//  AJRStars.m
//
//  Created by A.J. Raftis on 3/15/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

import AppKit
import AJRFoundation

open class AJRStars : NSLevelIndicator {

    // MARK: - Properties

    @IBInspectable open var backgroundColor : NSColor? {
        get {
            return starsCell?.backgroundColor
        }
        set {
            starsCell?.backgroundColor = newValue
            needsDisplay = true
        }
    }
    @IBInspectable open var borderColor : NSColor? {
        get {
            return starsCell?.borderColor
        }
        set {
            starsCell?.borderColor = newValue
            needsDisplay = true
        }
    }
    
    open override var baselineOffsetFromBottom : CGFloat {
        get {
            Swift.print("baseline: \(super.baselineOffsetFromBottom)")
            return 0.0
        }
    }

    // MARK: - NSCell

    open class override var cellClass : AnyClass? {
        get {
            return AJRStarsCell.self
        }
        set {
            super.cellClass = newValue
        }
    }

    open var starsCell : AJRStarsCell? {
        return cell as? AJRStarsCell
    }

}
