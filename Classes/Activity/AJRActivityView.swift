/*
 AJRActivityView.m
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

import AJRInterfaceFoundation

@objcMembers
open class AJRActivityView : NSControl {

    public var activities : [AJRActivity]
    public var selectedActivity : AJRActivity? {
        willSet {
            assert(activities.contains(where: { activity in
                return activity == newValue
            }))
        }
        didSet {
            needsDisplay = true
        }
    }

    internal var lock : NSLocking

    public override init(frame: NSRect) {
        self.activities = [AJRActivity]()
        self.lock = NSRecursiveLock()

        super.init(frame: frame)

        tile()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    open override var isFlipped : Bool {
        return true
    }

    open override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    open func tile() -> Void {
        var rect = NSRect(x: 0.0, y: 0.0, width: frame.size.width, height: 0.0)

        lock.lock()
        for activity in activities {
            if let view = activity.view as? NSView {
                rect.size.height = view.frame.size.height
                view.frame = rect
                rect.origin.y += rect.size.height + 1
            }
        }

        frame = NSRect(x: 0.0, y: 0.0, width: frame.size.width, height: rect.origin.y + 1.0)
        lock.unlock()

        needsDisplay = true
    }

    open override func draw(_ dirtyRect: NSRect) {
        var rect = NSRect(x: 0.0, y: 0.0, width: frame.size.width, height: 1.0)
        NSColor.lightGray.set()
        for (x, activity) in activities.enumerated() {
            if let view = activity.view as? NSView {
                var frame = view.frame
                rect.origin.y = frame.origin.y + frame.size.height + 1
                rect.fill()
                if selectedActivity == activity {
                    if x == 0 {
                        frame.size.height += 1.0
                    } else {
                        frame.origin.y += 1.0
                    }
                    NSColor.selectedControlColor.set()
                    frame.fill()
                    NSColor.lightGray.set()
                }
            }
        }
    }

    open func addActivity(_ activity: AJRActivity) -> Void {
        lock.lock()
        activities.append(activity)
        if let view = activity.view as? NSView {
            addSubview(view)
            //activity.addObserver(self, forKeyPath: "messages", options:[], context: nil)
        }
        tile()
        lock.unlock()
    }

    open func removeActivity(_ activity: AJRActivity) -> Void {
        lock.lock()
        if let view = activity.view as? NSView {
            view.removeFromSuperview()
        }
        if selectedActivity == activity {
            selectedActivity = nil
            //do {
            //    [activity removeObserver:self forKeyPath:@"messages"];
            //} catch { }
        }
        activities.remove(identicalTo: activity)
        tile()
        lock.unlock()
    }

    open func selectActivity(at index: Int) -> Void {
        selectedActivity = activities[index]
    }

    open func activity(for point: NSPoint) -> AJRActivity? {
        lock.lock()
        defer  { lock.unlock() }
        for activity in activities {
            if let view = activity.view as? NSView {
                if NSPointInRect(point, view.frame) {
                    return activity
                }
            }
        }

        return nil
    }

    open override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let activity = activity(for: location)

        if selectedActivity != activity {
            selectedActivity = activity
        }
    }

    open override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let activity = activity(for: location)

        if selectedActivity != activity {
            selectedActivity = activity
        }
    }

    open override func mouseUp(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)

        selectedActivity = activity(for: location)
        if let action {
            NSApp.sendAction(action, to: target, from: self)
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tile()
    }

}
