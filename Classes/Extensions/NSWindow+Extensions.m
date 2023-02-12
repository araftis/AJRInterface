/*
 NSWindow+Extensions.m
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
