/*!
 @header NSWindow+Extensions.h

 @author A.J. Raftis
 @updated 2/11/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Defines a category and functions for doing window transitions.
 @discussion Defines the various window transition effects you can do on a window.
 */

#import <Cocoa/Cocoa.h>

/*!
 @constant AJRWindowDidChangeFirstResponderNotification
 @discussion Notification sent when a window's first responder changes.
 */
extern NSString *AJRWindowDidChangeFirstResponderNotification;

/*!
 @function AJRCocoaWindowFrameToCarbon
 @discussion Converts between a Cocoa window frame and a Carbon window frame. This is necessary because Cocoa applications use the lower left corner of the screen as the origin, while Carbon applications use the upper left corner of the screen. Since the screen is important in the computation, that is why it's a required parameter. If you do pass in nil for screen, the function will use the main screen. Keep in mind that if you don't supply a screen, you will not be properly supporting multiple monitors.
 */
extern CGRect AJRCocoaWindowFrameToCarbon(NSRect frame, NSScreen *screen);

/*!
 @enum AJRWindowTransitionEffect
 @discussion Defines the various window transition effects you can do on a window.
 */
typedef enum _ajrWindowTransitionEffect {
    /*!
     @constant AJRWindowZoomTransitionEffect
     @discussion Specifies an animation that displays the window zooming between the open and closed states. The direction of the animation, whether from open to closed, or closed to open, depends upon the WindowTransitionAction constant specified in conjunction with the WindowTransitionEffect constant.
     */
    AJRWindowZoomTransitionEffect = 1,
    /*!
     @constant AJRWindowSheetTransitionEffect
     @discussion Zoom in or out from the parent window. Use with TransitionWindowAndParent and Show or Hide transition actions.
     */
    AJRWindowSheetTransitionEffect = 2,
    /*!
     @constant AJRWindowSlideTransitionEffect
     @discussion Slide the window into its new position. Use with TransitionWindow and Move or Resize transition actions.
     */
    AJRWindowSlideTransitionEffect = 3,
    /*!
     @constant AJRWindowFadeTransitionEffect
     @discussion Fade the window into or out of visibility. Use with the Show or Hide transition action.
     */
    AJRWindowFadeTransitionEffect = 4,
    /*!
     @constant AJRWindowGenieTransitionEffect
     @discussion Use the Genie effect that the Dock uses to minimize or maximize a window to show or hide the window. Use with the Show or Hide transition action.
     */
    AJRWindowGenieTransitionEffect = 5
} AJRWindowTransitionEffect;

/*!
 @category NSWindow (Extensions)
 @abstract Adds access to Carbon window transitions.
 @discussion This category adds the ability to do various Aqua window transitions when opening and closing your windows. These include things like the genie and fade effects seen in many Aqua applications.
 */
@interface NSWindow (AJRInterfaceExtensions)

- (NSPoint)ajr_convertPointToScreen:(NSPoint)point;

- (NSPoint)ajr_convertPointFromScreen:(NSPoint)point;

/*!
 @discussion Animates the window closing.
 @param effect The effect to use. For open transitions, you can use AJRWindowZoomTransitionEffect, AJRWindowFadeTransitionEffect, and AJRWindowGenieTransitionEffect.
 @param destinationRect When appropriate, this is the initial rectangle of the animation.
 @param duration The time you'd like the animation to take in seconds. Generally use want to use a small number, like 0.5. Note: if the user is holding down the shift key when you call this method, the duration will be multiplied by 10.0.
 */
- (void)orderOutWithTransition:(AJRWindowTransitionEffect)effect
                        toRect:(NSRect)destinationRect
                      duration:(NSTimeInterval)duration;
/*!
 @discussion Animates the window opening.
 @param effect The effect to use. For open transitions, you can use AJRWindowZoomTransitionEffect, AJRWindowFadeTransitionEffect, and AJRWindowGenieTransitionEffect.
 @param originRect When appropriate, this is the initial rectangle of the animation.
 @param duration The time you'd like the animation to take in seconds. Generally use want to use a small number, like 0.5. Note: if the user is holding down the shift key when you call this method, the duration will be multiplied by 10.0.
 @param screen The screen where the origin of the animation is to occur. If you pass nil, the main screen will be used, but doing so means your code is not properly supporting multiple monitors.
 */
- (void)orderFrontWithTransition:(AJRWindowTransitionEffect)effect
                        fromRect:(NSRect)originRect
                        duration:(NSTimeInterval)duration
                        onScreen:(NSScreen *)screen;
/*!
 @discussion Animates the window opening and then makes the window the key window.
 @param effect The effect to use. For open transitions, you can use AJRWindowZoomTransitionEffect, AJRWindowFadeTransitionEffect, and AJRWindowGenieTransitionEffect.
 @param originRect When appropriate, this is the initial rectangle of the animation.
 @param duration The time you'd like the animation to take in seconds. Generally use want to use a small number, like 0.5. Note: if the user is holding down the shift key when you call this method, the duration will be multiplied by 10.0.
 @param screen The screen where the origin of the animation is to occur. If you pass nil, the main screen will be used, but doing so means your code is not properly supporting multiple monitors.
 */
- (void)makeKeyAndOrderFrontWithTransition:(AJRWindowTransitionEffect)effect
                                  fromRect:(NSRect)originRect
                                  duration:(NSTimeInterval)duration
                                  onScreen:(NSScreen *)screen;

@end
