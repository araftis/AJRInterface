//
//  NSWindow-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 2/11/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "NSWindow+Extensions.h"

#import <Carbon/Carbon.h>

#import <AJRFoundation/AJRFoundation.h>
#import <objc/runtime.h>

NSString *AJRWindowDidChangeFirstResponderNotification = @"AJRWindowDidChangeFirstResponderNotification";

CGRect AJRCocoaWindowFrameToCarbon(NSRect frame, NSScreen *screen) {
    CGRect        newFrame;
    
    if (screen == nil) {
        screen = [NSScreen mainScreen];
    }
    
    newFrame.origin.x = frame.origin.x;
    newFrame.origin.y = [screen frame].size.height - frame.origin.y - frame.size.height;
    newFrame.size.width = frame.size.width;
    newFrame.size.height = frame.size.height;
    
    return newFrame;
}

@interface NSWindow (AJRForwardDelcarations)
- (BOOL)ajr_makeFirstResponder:(id)object;
@end

@interface AJRWindowInitialization : NSObject
@end

@implementation AJRWindowInitialization

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AJRSwizzleMethods(objc_getClass("NSWindow"), @selector(makeFirstResponder:), objc_getClass("NSWindow"), @selector(ajr_makeFirstResponder:));
    });
}

@end


@implementation NSWindow (AJRInterfaceExtensions)

- (NSPoint)ajr_convertPointToScreen:(NSPoint)point {
    return [self convertRectToScreen:(NSRect){point, NSZeroSize}].origin;
}

- (NSPoint)ajr_convertPointFromScreen:(NSPoint)point {
    return [self convertRectFromScreen:(NSRect){point, NSZeroSize}].origin;
}

- (BOOL)ajr_makeFirstResponder:(id)object {
    BOOL result = [self ajr_makeFirstResponder:object];
    
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AJRWindowDidChangeFirstResponderNotification object:self];
    }
    
    return result;
}

- (void)__orderOut:(NSWindow *)window {
    [window orderFront:self];
}

- (void)orderOutWithTransition:(AJRWindowTransitionEffect)effect
                        toRect:(NSRect)destinationRect
                      duration:(NSTimeInterval)duration {
    HIRect start;
    TransitionWindowOptions options;
    
    duration *= (self.currentEvent.modifierFlags & NSEventModifierFlagShift ? 10.0 : 1.0);
    
    start = AJRCocoaWindowFrameToCarbon(destinationRect, [self screen]);
    options.version = 0;
    options.duration = duration;
    options.window = [self windowRef];
    options.userData = NULL;

    [self orderOut:self];
}

- (void)_orderFrontWithTransition:(AJRWindowTransitionEffect)effect
                         fromRect:(NSRect)originRect
                         duration:(NSTimeInterval)duration
                         onScreen:(NSScreen *)screen {
    HIRect start;
    TransitionWindowOptions options;
    
    duration *= (self.currentEvent.modifierFlags & NSEventModifierFlagShift ? 10.0 : 1.0);
    
    start = AJRCocoaWindowFrameToCarbon(originRect, screen);
    options.version = 0;
    options.duration = duration;
    options.window = [self windowRef];
    options.userData = NULL;
    
    [self orderFront:self];
}

- (void)__orderFront:(NSWindow *)window {
    [window orderFront:self];
}

- (void)orderFrontWithTransition:(AJRWindowTransitionEffect)effect
                        fromRect:(NSRect)originRect
                        duration:(NSTimeInterval)duration
                        onScreen:(NSScreen *)screen {
    [self _orderFrontWithTransition:effect fromRect:originRect duration:duration onScreen:screen];
    [self performSelector:@selector(__orderFront:) withObject:self afterDelay:duration];
}

- (void)__makeKeyAndOrderFront:(NSWindow *)window {
    [window makeKeyAndOrderFront:self];
}

- (void)makeKeyAndOrderFrontWithTransition:(AJRWindowTransitionEffect)effect
                                  fromRect:(NSRect)originRect
                                  duration:(NSTimeInterval)duration
                                  onScreen:(NSScreen *)screen {
    [self _orderFrontWithTransition:effect fromRect:originRect duration:duration onScreen:screen];
    [self performSelector:@selector(__makeKeyAndOrderFront:) withObject:self afterDelay:duration];
}

@end
