//
//  NSView-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 2/19/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "NSView+Extensions.h"

#import "NSWindow+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <objc/runtime.h>

@interface NSView (AJRForwardDeclarations)
- (void)ajr_viewWillMoveToWindow:(NSWindow *)window;
- (void)ajr_viewDidMoveToWindow;
- (NSString *)_subtreeDescription;
@end

@interface AJRViewLoader : NSObject
@end

@implementation AJRViewLoader

+ (void)load {
    AJRSwizzleMethods(self, @selector(viewWillMoveToWindow:), self, @selector(ajr_viewWillMoveToWindow:));
    AJRSwizzleMethods(self, @selector(viewDidMoveToWindow), self, @selector(ajr_viewDidMoveToWindow));
}

@end

@implementation NSView (AJRInterfaceExtensions)

- (NSPoint)ajr_convertPointFromScreen:(NSPoint)p {
    NSAssert([self window], @"A window is required to convert to screen coordinates");
    return [self convertPoint:[[self window] ajr_convertPointFromScreen:p] fromView:nil];
}

- (NSPoint)ajr_convertPointToScreen:(NSPoint)p {
    NSAssert([self window], @"A window is required to convert to screen coordinates");
    return [[self window] ajr_convertPointToScreen:[self convertPoint:p toView:nil]];
}

- (NSRect)ajr_convertRectToScreen:(NSRect)local {
    NSAssert([self window], @"A window is required to convert to screen coordinates");
    NSRect window = [self convertRect:local toView:nil];
    NSRect screen = {.size = window.size, .origin = [[self window] ajr_convertPointToScreen:window.origin]};
    return screen;
}

- (NSRect)ajr_convertRectFromScreen:(NSRect)screen {
    NSAssert([self window], @"A window is required to convert to screen coordinates");
    return [self convertRect:[[self window] convertRectFromScreen:screen] fromView:nil];
}

- (NSRect)frameInScreenCoordinates {
    NSRect frame = [self convertRect:[self bounds] toView:nil];
    
    frame.origin = [[self window] ajr_convertPointToScreen:frame.origin];

    return frame;
}

- (BOOL)isActive {
    return [NSApp isActive];
}

- (BOOL)isActiveAndKey {
    return [NSApp isActive] && [[self window] isKeyWindow];
}

- (BOOL)isActiveKeyAndFirstResponder {
    return [NSApp isActive] && [[self window] isKeyWindow] && [[self window] firstResponder] == self;
}

- (void)ajr_addStatusObservations {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSWindow *window = [self window];
    
    if (window) {
        [center addObserver:self selector:@selector(ajr_updateDisplay:) name:NSWindowDidBecomeKeyNotification object:window];
        [center addObserver:self selector:@selector(ajr_updateDisplay:) name:NSWindowDidResignKeyNotification object:window];
    }
    [center addObserver:self selector:@selector(ajr_updateDisplay:) name:NSApplicationDidResignActiveNotification object:NSApp];
    [center addObserver:self selector:@selector(ajr_updateDisplay:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

- (void)ajr_removeStatusObservations {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSWindow *window = [self window];
    
    if (window) {
        [center removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
        [center removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
    }
    [center removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
    [center removeObserver:self name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

static const NSInteger AJRStatusChangeKey = 0;

- (void)setRedrawOnApplicationOrWindowStatusChange:(BOOL)flag {
    BOOL redraws = [self redrawsOnApplicationOrWindowStatusChange];
    
    if ((redraws && !flag) || (!redraws && flag)) {
        if (redraws) {
            [self ajr_removeStatusObservations];
        }
        objc_setAssociatedObject(self, &AJRStatusChangeKey, [NSNumber numberWithBool:flag], OBJC_ASSOCIATION_RETAIN);
        if (flag) {
            [self ajr_addStatusObservations];
        }
    }
}

- (BOOL)redrawsOnApplicationOrWindowStatusChange; {
    return [objc_getAssociatedObject(self, &AJRStatusChangeKey) boolValue];
}

- (void)ajr_updateDisplay:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

- (void)ajr_viewWillMoveToWindow:(NSWindow *)window {
    if ([self redrawsOnApplicationOrWindowStatusChange]) {
        [self ajr_removeStatusObservations];
    }
    [self ajr_viewWillMoveToWindow:window];
}

- (void)ajr_viewDidMoveToWindow {
    if ([self redrawsOnApplicationOrWindowStatusChange]) {
        [self ajr_addStatusObservations];
    }
    [self ajr_viewDidMoveToWindow];
}

- (NSView *)findViewWithIdentifier:(NSString *)identifier {
	if (AJREqual([self identifier], identifier)) {
		return self;
	}
	NSView *found = nil;
	for (NSView *subview in [self subviews]) {
		found = [subview findViewWithIdentifier:identifier];
		if (found) break;
	}
	return found;
}

- (void)moveChildrenFromOldFrame:(NSRect)oldFrame {
	NSRect frame;
	NSRect parentFrame;
	NSArray *children;
	NSWindow *child;
	NSInteger x;
	
	children = [[self window] childWindows];
	parentFrame = [[self window] frame];
	for (x = 0; x < (const int)[children count]; x++) {
		child = [children objectAtIndex:x];
		frame = [child frame];
		frame.origin.x = parentFrame.origin.x + (frame.origin.x - oldFrame.origin.x);
		frame.origin.y = parentFrame.origin.y + (frame.origin.y - oldFrame.origin.y);
		[child setFrame:frame display:YES];
		[child orderWindow:NSWindowAbove relativeTo:[[self window] windowNumber]];
	}
}

- (void)trackMouseForOperation:(AJRWindowOperation)dragAction fromEvent:(NSEvent *)event {
	BOOL done = NO;
	NSPoint start;
	NSPoint newLocation;
	NSWindow *window = [self window];
	NSRect frame, previousFrame;
	NSRect startFrame = [window frame];
	NSSize minSize = [window minSize];
	BOOL cx, cy;
	
	[window makeKeyWindow];
	[window orderFront:self];
	start = [event locationInWindow];
	frame = startFrame;
	
	while (!done) {
		event = [NSApp nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged
								   untilDate:[NSDate distantFuture]
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];
		cx = NO;
		cy = NO;
		switch ([event type]) {
			case NSEventTypeLeftMouseUp:
				done = YES;
				break;
			case NSEventTypeLeftMouseDragged:
				newLocation = [event locationInWindow];
				previousFrame = frame;
				frame = [window frame];
				switch (dragAction) {
					case AJRWindowOperationResizeTopLeft:
						frame.origin.x = frame.origin.x + newLocation.x - start.x;
						frame.origin.y = frame.origin.y;
						frame.size.width = frame.size.width + start.x - newLocation.x;
						frame.size.height = startFrame.size.height + newLocation.y - start.y;
						cx = YES;
						break;
					case AJRWindowOperationResizeTop:
						frame.origin.x = frame.origin.x;
						frame.origin.y = frame.origin.y;
						frame.size.width = frame.size.width;
						frame.size.height = startFrame.size.height + newLocation.y - start.y;
						break;
					case AJRWindowOperationResizeTopRight:
						frame.origin.x = startFrame.origin.x;
						frame.origin.y = startFrame.origin.y;
						frame.size.width = startFrame.size.width + newLocation.x - start.x;
						frame.size.height = startFrame.size.height + newLocation.y - start.y;
						break;
					case AJRWindowOperationResizeLeft:
						frame.origin.x = frame.origin.x + newLocation.x - start.x;
						frame.origin.y = frame.origin.y;
						frame.size.width = frame.size.width + start.x - newLocation.x;
						frame.size.height = frame.size.height;
						cx = YES;
						break;
					case AJRWindowOperationMove:
						[window setFrameOrigin:
						 NSMakePoint(frame.origin.x + newLocation.x - start.x,
									 frame.origin.y + newLocation.y - start.y)];
						continue;
					case AJRWindowOperationResizeRight:
						frame.origin.x = startFrame.origin.x;
						frame.origin.y = startFrame.origin.y;
						frame.size.width = startFrame.size.width + newLocation.x - start.x;
						frame.size.height = startFrame.size.height;
						break;
					case AJRWindowOperationResizeBottomLeft:
						frame.origin.x = frame.origin.x + newLocation.x - start.x;
						frame.origin.y = frame.origin.y + newLocation.y - start.y;
						frame.size.width = frame.size.width + start.x - newLocation.x;
						frame.size.height = frame.size.height + start.y - newLocation.y;
						cx = YES;
						cy = YES;
						break;
					case AJRWindowOperationResizeBottom:
						frame.origin.x = frame.origin.x;
						frame.origin.y = frame.origin.y + newLocation.y - start.y;
						frame.size.width = frame.size.width;
						frame.size.height = frame.size.height + start.y - newLocation.y;
						cy = YES;
						break;
					case AJRWindowOperationResizeBottomRight:
						frame.origin.x = frame.origin.x;
						frame.origin.y = frame.origin.y + newLocation.y - start.y;
						frame.size.width = startFrame.size.width + newLocation.x - start.x;
						frame.size.height = frame.size.height + start.y - newLocation.y;
						cy = YES;
						break;
				}
				if ([[window delegate] respondsToSelector:@selector(windowWillResize:toSize:)]) {
					frame.size = [[window delegate] windowWillResize:window toSize:frame.size];
				}
				if (frame.size.width < minSize.width) {
					if (cx) frame.origin.x -= minSize.width - frame.size.width;
					frame.size.width = minSize.width;
				}
				if (frame.size.height < minSize.height) {
					if (cy) frame.origin.y -= minSize.height - frame.size.height;
					frame.size.height = minSize.height;
				}
				[window setFrame:frame display:YES];
				[self moveChildrenFromOldFrame:previousFrame];
				break;
			default:
				break;
		}
	}
}

- (NSButton *)selectedRadioButtonTargetting:(id)target withAction:(SEL)action {
    for (NSView *subview in self.subviews) {
        NSButton *button = AJRObjectIfKindOfClass(subview, NSButton);
        if (button != nil) {
            if (button.target == target && button.action == action && button.state == NSControlStateValueOn) {
                return button;
            }
        }
        button = [subview selectedRadioButtonTargetting:target withAction:action];
        if (button) {
            return button;
        }
    }
    return nil;
}

- (void)selectRadioButtonTargetting:(nullable id)target withAction:(SEL)action andIdentifier:(NSUserInterfaceItemIdentifier)identifier {
    for (NSView *subview in self.subviews) {
        NSButton *button = AJRObjectIfKindOfClass(subview, NSButton);
        if (button != nil) {
            if (button.target == target && button.action == action) {
                if ([identifier isEqualToString:button.identifier]) {
                    button.state = NSControlStateValueOn;
                } else {
                    button.state = NSControlStateValueOff;
                }
            }
        }
        [subview selectRadioButtonTargetting:target withAction:action andIdentifier:identifier];
    }
}

- (NSString *)subtreeDescription {
    return [self _subtreeDescription];
}

@end

@implementation NSButton (Extensions)

- (void)ajr_updateRadioGroup {
	for (NSView *subview in [[self superview] subviews]) {
		NSButton *button = AJRObjectIfKindOfClass(subview, NSButton);
		if (button && [button target] == [self target] && [button action] == [self action]) {
			[button setState:button == self ? NSControlStateValueOn : NSControlStateValueOff];
		}
	}
}

@end
