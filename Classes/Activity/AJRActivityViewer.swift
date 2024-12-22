/*
 AJRActivityViewer.m
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

public extension AJRUserDefaultsKey {
    static var activityViewerVisible : AJRUserDefaultsKey<Bool> {
        return AJRUserDefaultsKey<Bool>(named: "ActivityViewerVisible", defaultValue: false)
    }
}

// TODO: This is internal, because it doesn't account for localization.
internal extension Int {
    var pluralString : String {
        return self == 1 ? "" : "s"
    }
}

@objcMembers
open class AJRActivityViewer : NSObject {

    @IBOutlet open var window: NSWindow!
    @IBOutlet open var view: AJRActivityView!
    @IBOutlet open var scrollView: NSScrollView!
    @IBOutlet open var statusText: NSTextField!
    @IBOutlet open var progressText: NSTextField!
    @IBOutlet open var stopButton: NSButton!

    internal var timer : Timer!

    @objc(sharedInstance)
    public static var shared = AJRActivityView.init()

    internal override init() {
        super.init()

        Bundle.ajr_loadNibNamed("AJRActivityViewer", owner:self)

        statusText.stringValue = ""
        progressText.stringValue = ""
        stopButton.isEnabled = false
        scrollView.backgroundColor = .white

        weak var weakSelf = self
        timer = Timer(timeInterval: 1.0, repeats: true) { timer in
            if let strongSelf = weakSelf {
                if strongSelf.window.isVisible {
                    strongSelf.update()
                }
            }
        }

        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: nil) { notification in
            if let strongSelf = weakSelf {
                UserDefaults[.activityViewerVisible] = strongSelf.window.isVisible
            }
        }
    }

    internal func timeIntervalString(for ts: TimeInterval) -> String {
        let tsi = Int(ts).abs

        if tsi < 60 {
            return "\(tsi) second\(tsi.pluralString)"
        } else if (tsi < 60 * 60) {
            let seconds = tsi % 60
            let minutes = tsi / 60
            return "\(minutes) minute\(minutes.pluralString) \(seconds) second\(seconds.pluralString)"
        } else {
            let seconds = tsi % 60
            let minutes = (tsi / 60) % 60
            let hours = tsi / (60 * 60)
            return "\(hours) hour\(hours.pluralString) \(minutes) minute\(minutes.pluralString) \(seconds) second\(seconds.pluralString)"
        }
    }

    /**
     Allows the viewer to update its active view state. This is generally called for the user when changed are made or observed.
     */
    open func update() {
        if let activity = view.selectedActivity {
            if activity.isStopRequested {
                statusText.stringValue = "Stopping"
                stopButton.isEnabled = false
            } else if activity.isStopped {
                statusText.stringValue = "Stopped"
                stopButton.isEnabled = false
            } else {
                statusText.stringValue = "Active"
                stopButton.isEnabled = true
            }
            if activity.messages.count > 0 {
                progressText.stringValue = "\(timeIntervalString(for: activity.ellapsedTime))\n\(activity.messages.first!)"
            } else {
                progressText.stringValue = timeIntervalString(for: activity.ellapsedTime)
            }
        } else {
            statusText.stringValue = ""
            progressText.stringValue = ""
            stopButton.isEnabled = false
        }
    }

    /**
     Returns the current, active activities.
     */
    public var activities : [AJRActivity] {
        return view.activities
    }

    /**
     Adds `activity` to the viewer. This is usually called when the owner of the activity "pushes" the activity to make it active. As such, the user rarely needs to call this method directly.

     - Parameter activity: The activity to remove.
     */
    public func addActivity(_ activity: AJRActivity) {
        view.addActivity(activity)
        update()
    }

    /**
     Removes `activity` from the viewer. This is usually called when the owner of the activity pops the completed activity. As such the user rarely needs to call this method directly.

     - Parameter activity: The activity to remove.
     */
    public func removeActivity(_ activity: AJRActivity) {
        view.removeActivity(activity)
        update()
    }

    // MARK: - Actions

    /**
     Requests the the selected activity stop. This doesn't immediately stop the activity, but rather just requests that the activity should stop. When the activities owner notices the stop request, it should shut itself down and transition to a stopped state.
     */
    @IBAction public func stopActivity(_ sender: Any?) {
        view.selectedActivity?.stop()
        update()
    }

    /**
     Mostly called to forward `update()` when selection occurred.
     */
    @IBAction public func selectActivity(_ sender: Any?) {
        update()
    }

    /**
     Make the activity viewer visible to the user.
     */
    @IBAction public func showActivityPanel(_ sender: Any?) {
        window.orderFront(sender)
    }

}


public extension NSResponder  {

    @IBAction func showActivityPanel(_ sender: Any?) -> Void {
        AJRActivityViewer.shared.showActivityPanel(sender)
    }

}
