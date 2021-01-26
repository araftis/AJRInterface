//
//  AJRPopUpTextFieldCell.m
//  Meta Monkey
//
//  Created by A.J. Raftis on 3/11/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRPopUpTextFieldCell.h"

@implementation AJRPopUpTextFieldCell
{
	NSMenu *_menu;
}

#pragma mark Properties

@synthesize menu = _menu;

- (NSGradient *)activeGradient {
	if (_activeGradient == nil) {
		_activeGradient = [[NSGradient alloc] initWithColorsAndLocations:
                           [[NSColor controlAccentColor] highlightWithLevel:0.33], 0.0,
						   [[NSColor controlAccentColor] shadowWithLevel:0.1], 1.0,
						   nil];
	}
	return _activeGradient;
}

- (NSGradient *)inactiveGradient {
	if (_inactiveGradient == nil) {
        _inactiveGradient = [[NSGradient alloc] initWithColorsAndLocations:
                             [NSColor textBackgroundColor], 0.0,
                             [NSColor textBackgroundColor], 1.0,
                             nil];
	}
	return _inactiveGradient;
}

- (NSGradient *)disabledGradient {
	if (_disabledGradient == nil) {
        _disabledGradient = [[NSGradient alloc] initWithColorsAndLocations:
                             [NSColor textBackgroundColor], 0.0,
                             [NSColor textBackgroundColor], 1.0,
                             nil];
	}
	return _disabledGradient;
}

#pragma mark Layout

- (NSRect)textRectForFrame:(NSRect)cellFrame {
	cellFrame.origin.x += 2.0;
	cellFrame.size.width -= 19.0;
	cellFrame.origin.y += 3.0;
	
	return cellFrame;
}

- (NSRect)buttonRectForFrame:(NSRect)cellFrame {
	NSRect	buttonRect = cellFrame;
	
	buttonRect.origin.x = cellFrame.origin.x + cellFrame.size.width - 15.0;
	buttonRect.origin.y += 1;
	buttonRect.size.width = 14.0;
	buttonRect.size.height -= 2.0;
	
	return buttonRect;
}

#pragma mark NSCell

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	
	if (_menu) {
		NSRect	frame;
		
		frame = [[textObj superview] frame];
		frame.size.width -= 17.0;
		[[textObj superview] setFrame:frame];
	}
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	if (_menu) {
        CGFloat lineWidth = controlView.window.screen != nil ? (1.0 / controlView.window.screen.backingScaleFactor) : 1.0;
		NSRect buttonRect = [self buttonRectForFrame:cellFrame];
		NSBezierPath *path;
		NSGradient *gradient;
		NSPoint center;

		if ([self isEnabled]) {
			if ([NSApp isActive] && [[controlView window] isKeyWindow]) {
				gradient = [self activeGradient];
			} else {
				//gradient = [self inactiveGradient];
			}
		} else {
			//gradient = [self disabledGradient];
		}
		
		[gradient drawInRect:buttonRect angle:90.0];
		
		path = [[NSBezierPath alloc] init];
		
		if ([self isEnabled] && [NSApp isActive] && [[controlView window] isKeyWindow]) {
            [path moveToPoint:(NSPoint){buttonRect.origin.x, buttonRect.origin.y - (lineWidth / 2.0)}];
            [path relativeLineToPoint:(NSPoint){buttonRect.size.width + (lineWidth / 2.0), 0.0}];
            [path relativeLineToPoint:(NSPoint){0.0, buttonRect.size.height + lineWidth}];
            [path relativeLineToPoint:(NSPoint){-(buttonRect.size.width + (lineWidth / 2.0)), 0.0}];
            [[NSColor controlAccentColor] set];
            [path setLineWidth:lineWidth];
			[path stroke];
		}
		
		center.x = NSMidX(buttonRect) + lineWidth;
		center.y = NSMidY(buttonRect);
		[path removeAllPoints];
		
		CGFloat halfWidth = 3.0;
		[path moveToPoint:(NSPoint){center.x - halfWidth, center.y - 1.5}];
		[path relativeLineToPoint:(NSPoint){halfWidth, -3.0}];
		[path relativeLineToPoint:(NSPoint){halfWidth, 3.0}];
		
		[path moveToPoint:(NSPoint){center.x - halfWidth, center.y + 1.5}];
		[path relativeLineToPoint:(NSPoint){halfWidth, 3.0}];
        [path relativeLineToPoint:(NSPoint){halfWidth, -3.0}];
		
		if ([self isEnabled]) {
            if ([NSApp isActive] && [[controlView window] isKeyWindow]) {
                [[NSColor alternateSelectedControlTextColor] set];
            } else {
                [[NSColor controlTextColor] set];
            }
		} else {
            [[NSColor controlTextColor] set];
		}
        [path setLineWidth:1.25];
        [path setLineCapStyle:NSLineCapStyleRound];
		[path stroke];
	}
}

- (void)popUpMenuWithEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	NSEvent *newEvent;
	NSPoint newWhere;
	
	newWhere = [controlView convertPoint:(NSPoint){0.0, cellFrame.origin.y + cellFrame.size.height + 4.0} toView:nil];
	newEvent = [NSEvent mouseEventWithType:[event type]
								  location:newWhere
							 modifierFlags:[event modifierFlags]
								 timestamp:[event timestamp]
							  windowNumber:[event windowNumber]
								   context:[NSGraphicsContext currentContext]
							   eventNumber:[event eventNumber]
								clickCount:[event clickCount]
								  pressure:[event pressure]];
	
	[NSMenu popUpContextMenu:self.menu withEvent:newEvent forView:controlView];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
	if (_menu && NSMouseInRect([controlView convertPoint:[theEvent locationInWindow] fromView:nil], [self buttonRectForFrame:cellFrame], [controlView isFlipped])) {
		[self popUpMenuWithEvent:theEvent inRect:cellFrame ofView:controlView];
		return NO;
	}
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}

- (void)viewDidChangeEffectiveAppearance {
    _activeGradient = nil;
    _disabledGradient = nil;
    _inactiveGradient = nil;
}

@end
