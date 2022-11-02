/*
 AJRURLFieldCell.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import "AJRURLFieldCell.h"

#import "AJRImages.h"
#import "NSAffineTransform+Extensions.h"
#import "NSGradient+Extensions.h"
#import "NSGraphicsContext+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

@interface _NSKeyboardFocusClipView : NSClipView

- (void)_adjustFocusRingLocation:(NSPoint)offset;

@end

@implementation AJRURLFieldCell {
	NSImage *_icon;
	CGFloat _progress;
}

+ (NSImage *)backgroundImage {
	static NSImage *backgroundImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		backgroundImage = [AJRImages imageNamed:@"AJRWebURLFieldFrame" forClass:[AJRURLFieldCell class]];
	});
	return backgroundImage;
}

- (id)initTextCell:(NSString *)aString {
	if ((self = [super initTextCell:aString])) {
		[self setPlaceholderString:@"Go to this address"];
	}
	return self;
}

- (void)setIcon:(NSImage *)anIcon {
	if (_icon != anIcon) {
		_icon = anIcon;
	}
}

- (NSImage *)icon {
	return _icon;
}

- (NSImage *)displayIcon {
	if (_icon == nil) {
		return [AJRImages imageNamed:@"AJRWebGenericLocation" forClass:[AJRURLFieldCell class]];
	}
	return _icon;
}

- (void)setProgress:(double)value {
	_progress = value;
}

- (double)progress {
	return _progress;
}

- (void)noteProgressComplete {
	[self setProgress:0.0];
}

- (NSRect)textRectForBounds:(NSRect)cellFrame {
    NSRect frame = [self titleRectForBounds:cellFrame];
    frame.origin.x += 20.0;
    frame.size.width -= 40.0;
    return frame;
}

- (NSRect)iconRectForBounds:(NSRect)cellFrame {
	NSImage	*locationImage = [self displayIcon];
	NSRect imageFrame = cellFrame;
	
	imageFrame.origin.x += 3;
	imageFrame.origin.y += (cellFrame.size.height - 16.0) / 2.0;
	imageFrame.size.height = 16.0;
	imageFrame.size.width = 16.0;
	
	return AJRRectByCenteringInRect((NSRect){NSZeroPoint, [locationImage size]}, imageFrame, AJRRectCenteringScaleWidthAndHeight);
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	NSRect	frame;
	
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	
	frame = [[textObj superview] frame];
	frame.origin.x += 18.0;
	frame.size.width -= 40.0;
	[[textObj superview] setFrame:frame];
	[(_NSKeyboardFocusClipView *)[textObj superview] _adjustFocusRingLocation:(NSPoint){-18, 0}];
}

- (NSBezierPath *)pathForBorderWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:4.0 yRadius:4.0];
	[path setLineWidth:1.0 / [[[controlView window] screen] backingScaleFactor]];
	return path;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[[NSGraphicsContext currentContext] drawWithSavedGraphicsState:^(NSGraphicsContext *context) {
		NSImage *locationImage;
		id first;
		NSBezierPath *path = [self pathForBorderWithFrame:cellFrame inView:controlView];
		
		[path addClip];
		
		if (self->_progress > 0.0) {
			[[NSColor controlBackgroundColor] set];
			NSRect progressFrame = cellFrame;
			progressFrame.origin.x += 1;
            progressFrame.origin.y += progressFrame.size.height - 2.0;
			progressFrame.size.width -= 2;
			progressFrame.size.width *= self->_progress;
			progressFrame.size.height = 2.0;
			NSRectFill(progressFrame);
            [[NSColor selectedContentBackgroundColor] set];
            NSRectFill(progressFrame);
		}
		
		locationImage = [self displayIcon];
		if (locationImage) {
			NSRect iconRect = [self iconRectForBounds:cellFrame];
			[locationImage drawInRect:iconRect fromRect:(NSRect){{0.0, 0.0}, [locationImage size]} operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
		}
		
		first = [[controlView window] firstResponder];
		if ([first isKindOfClass:[NSTextView class]] && [first delegate] == (id)controlView) {
			[super drawInteriorWithFrame:cellFrame inView:controlView];
		} else {
			NSAttributedString *string = [self attributedStringValue];
			
			if ([string length] == 0) {
				string = [self placeholderAttributedString];
				//AJRPrintf(@"%C: %@, %@\n", self, [self placeholderString], [self placeholderAttributedString]);
			} else if (![self isEnabled]) {
				string = [string mutableCopy];
				[(NSMutableAttributedString *)string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor disabledControlTextColor], NSForegroundColorAttributeName, nil] range:(NSRange){0, [string length]}];
			}
			[string drawInRect:[self textRectForBounds:cellFrame]];
		}
	}];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[[NSGraphicsContext currentContext] drawWithSavedGraphicsState:^(NSGraphicsContext *context) {
        if ([NSApp isActive] && [[controlView window] isKeyWindow]) {
            [[NSColor textBackgroundColor] set];
            [[self pathForBorderWithFrame:cellFrame inView:controlView] fill];
        }
		NSImage *image = [[self class] backgroundImage];
		[NSAffineTransform flipCoordinateSystemInRect:cellFrame];
		[image drawInRect:cellFrame];
	}];
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawFocusRingMaskWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	CGFloat inset = 1.0 / [[[controlView window] screen] backingScaleFactor];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, inset, inset) xRadius:3.0 yRadius:3.0];
	[path setLineWidth:1.0];
	[[NSColor blackColor] set];
	[path fill];
}

- (NSAttributedString *)placeholderAttributedString {
	NSAttributedString *string = [super placeholderAttributedString];
	
	if (string == nil && [self placeholderString] != nil) {
		return [[NSAttributedString alloc] initWithString:[self placeholderString] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[self font], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil]];
	}
	
	return string;
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj {
    NSText *editor = [super setUpFieldEditorAttributes:textObj];
    
    [editor setDrawsBackground:NO];
    [editor unregisterDraggedTypes];
    
    return editor;
}

@end


