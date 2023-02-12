/*
 AJRToggleButtonCell.m
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

#import "AJRToggleButtonCell.h"

#import "AJRToggleButtonAnimation.h"

#import <AJRFoundation/AJRFunctions.h>

@interface AJRToggleButtonCell (Private)

- (void)startThumbAnimationInControlView:(NSView *)controlView durationPercentage:(CGFloat)percentage;
- (void)_updateThumbOffsetForAnimationProgress:(NSAnimationProgress)progress;

@end

@implementation AJRToggleButtonCell

- (void)dealloc {
    if (_animation) {
        // This will stop the animation, and free up any resources it's using.
        [_animation stopAnimation];
    }
    

}

#pragma mark Properties

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = [backgroundColor copy];
}

- (NSColor *)backgroundColor {
    if (_backgroundColor == nil) {
        return [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
    }
    return _backgroundColor;
}

- (NSColor *)alternateBackgroundColor {
    if (_alternateBackgroundColor == nil) {
        return [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
    }
    return _alternateBackgroundColor;
}

- (NSGradient *)shineGradient {
    if (_shineGradient == nil) {
        _shineGradient = [[NSGradient alloc] initWithColorsAndLocations:
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.3], 0.0, 
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.1], 0.5, 
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.0], 0.51, nil];
    }
    return _shineGradient;
}

- (NSShadow *)backgroundShadow {
    if (_backgroundShadow == nil) {
        _backgroundShadow = [[NSShadow alloc] init];
        [_backgroundShadow setShadowOffset:(NSSize){0.0, -2.0}];
        [_backgroundShadow setShadowBlurRadius:3.0];
        [_backgroundShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.7]];
    }
    return _backgroundShadow;
}

#pragma mark Computational Utilities

- (NSRect)textRectForCellFrame:(NSRect)cellFrame controlView:(NSView *)controlView {
    NSRect    thumbRect = NSInsetRect(cellFrame, 1.0, 1.0);
    
    thumbRect.size.width = round(thumbRect.size.width / 2.0) - 2.0;
    thumbRect.origin.x = cellFrame.origin.x + cellFrame.size.width - (thumbRect.size.width + 1.0) + 2.0;
    thumbRect.size.height -= 2.0;
    thumbRect.origin.y += 2.0;
    
    return thumbRect;
}

- (NSRect)alternateTextRectForCellFrame:(NSRect)cellFrame controlView:(NSView *)controlView {
    NSRect    thumbRect = NSInsetRect(cellFrame, 1.0, 1.0);
    
    thumbRect.size.width = round((thumbRect.size.width - 5.0) / 2.0);
    thumbRect.size.height -= 2.0;
    thumbRect.origin.y += 2.0;
    
    return thumbRect;
}

- (NSRect)thumbRectForCellFrame:(NSRect)cellFrame {
    NSRect    thumbRect = NSInsetRect(cellFrame, 0.5, 0.5);
    
    thumbRect.size.width = round(thumbRect.size.width / 2.0) + 5.0;
    
	if ([self state] == NSControlStateValueOn) {
        thumbRect.origin.x = cellFrame.origin.x + cellFrame.size.width - (thumbRect.size.width + 0.5);
    }
    
    if (_trackingMouse || _animation != nil) {
        thumbRect.origin.x -= _thumbOffset;
        if (thumbRect.origin.x < cellFrame.origin.x + 0.5) {
            thumbRect.origin.x = cellFrame.origin.x + 0.5;
        }
        if (thumbRect.origin.x + thumbRect.size.width > cellFrame.origin.x + cellFrame.size.width - 1.0) {
            thumbRect.origin.x = cellFrame.origin.x + cellFrame.size.width - (thumbRect.size.width + 0.5);
        }
    }
    
    return thumbRect;
}

- (NSGradient *)thumbGradient {
    if (_thumbGradient == nil) {
        _thumbGradient = [[NSGradient alloc] initWithColorsAndLocations:
                          [NSColor colorWithCalibratedWhite:0.667 alpha:1.0], 0.0,
                          [NSColor colorWithCalibratedWhite:0.900 alpha:1.0], 1.0,
                          nil];
    }
    return _thumbGradient;
}

- (NSGradient *)thumbDarkGradient {
    if (_thumbDarkGradient == nil) {
        _thumbDarkGradient = [[NSGradient alloc] initWithColorsAndLocations:
                          [NSColor colorWithCalibratedWhite:0.567 alpha:1.0], 0.0,
                          [NSColor colorWithCalibratedWhite:0.800 alpha:1.0], 1.0,
                          nil];
    }
    return _thumbDarkGradient;
}

- (NSShadow *)thumbInnerShadow {
    if (_thumbInnerShadow == nil) {
        _thumbInnerShadow = [[NSShadow alloc] init];
        [_thumbInnerShadow setShadowOffset:(NSSize){0.0, -1.0}];
        [_thumbInnerShadow setShadowBlurRadius:1.0];
        [_thumbInnerShadow setShadowColor:[NSColor whiteColor]];
    }
    return _thumbInnerShadow;
}

- (NSShadow *)textShadow {
    if (_textShadow == nil) {
        _textShadow = [[NSShadow alloc] init];
        [_textShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
        [_textShadow setShadowOffset:(NSSize){0.0, 1.0}];
        [_textShadow setShadowBlurRadius:1.0];
    }
    return _textShadow;
}

- (NSDictionary *)textAttributes {
    if (_textAttributes == nil) {
        _textAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSColor colorWithCalibratedWhite:0.2 alpha:1.0], NSForegroundColorAttributeName, 
                                  nil];
    }
    return _textAttributes;
}

- (NSDictionary *)textColoredAttributes {
    if (_textColoredAttributes == nil) {
        _textColoredAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSColor whiteColor], NSForegroundColorAttributeName, 
                                  [self textShadow], NSShadowAttributeName, 
                                  nil];
    }
    return _textColoredAttributes;
}

#pragma mark NSCell

- (NSSize)cellSize {
    NSSize        size1 = [[self attributedTitle] size];
    NSSize        size2 = [[self attributedTitle] size];
    NSSize        size;
    
    if (size1.width > size2.width) {
        size = size1;
    } else {
        size = size2;
    }
    size.width = (size.width + 40.0) * 2.0;
    switch ([self controlSize]) {
        case NSControlSizeMini:
            size.height = 15.0;
            break;
        case NSControlSizeSmall:
            size.height = 18.0;
            break;
        case NSControlSizeRegular:
            size.height = 25.0;
            break;
        default:
            size.height = 25.0;
            break;
    }
    
    return size;
}

- (NSAttributedString *)attributedTitle {
    NSMutableAttributedString    *title = (NSMutableAttributedString *)[super attributedTitle];
    
    title = [title mutableCopy];
    if (_backgroundColor != nil) {
        [title addAttributes:[self textColoredAttributes] range:(NSRange){0, [title length]}];
    } else {
        [title addAttributes:[self textAttributes] range:(NSRange){0, [title length]}];
    }
    
    return title;
}

- (NSAttributedString *)attributedAlternateTitle {
    NSMutableAttributedString    *title = (NSMutableAttributedString *)[super attributedAlternateTitle];
    
    title = [title mutableCopy];    
    if (_alternateBackgroundColor != nil) {
        [title addAttributes:[self textColoredAttributes] range:(NSRange){0, [title length]}];
    } else {
        [title addAttributes:[self textAttributes] range:(NSRange){0, [title length]}];
    }
    
    return title;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect                tempRect;
    NSBezierPath        *background;
    NSBezierPath        *backgroundShadowPath;
    NSBezierPath        *border;
    NSBezierPath        *thumb;
    NSColor                *grayBorderColor;
    NSColor                *backgroundColor = [self backgroundColor];
    NSColor                *alternateBackgroundColor = [self alternateBackgroundColor];
    
    grayBorderColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
    
    border = [[NSBezierPath alloc] init];
    [border appendBezierPathWithRoundedRect:NSInsetRect(cellFrame, 0.5, 0.5) xRadius:3.0 yRadius:3.0];
    
    thumb = [[NSBezierPath alloc] init];
    [thumb appendBezierPathWithRoundedRect:[self thumbRectForCellFrame:cellFrame] xRadius:2.0 yRadius:2.0];
    
    tempRect = cellFrame;
    tempRect.size.width /= 2.0;
    background = [[NSBezierPath alloc] init];
    [background appendBezierPathWithRoundedRect:tempRect xRadius:3.0 yRadius:3.0];
    [alternateBackgroundColor set];
    [background fill];
    [[self shineGradient] drawInBezierPath:background angle:270.0];
    
    tempRect.origin.x = cellFrame.origin.x + cellFrame.size.width - tempRect.size.width;
    [background removeAllPoints];
    [background appendBezierPathWithRoundedRect:tempRect xRadius:3.0 yRadius:3.0];
    [backgroundColor set];
    [background fill];
    [[self shineGradient] drawInBezierPath:background angle:270.0];
     background = nil;
     
    [NSGraphicsContext saveGraphicsState];
    backgroundShadowPath = [[NSBezierPath alloc] init];
    [backgroundShadowPath appendBezierPathWithRect:NSInsetRect(cellFrame, -10.0, -10.0)];
    [backgroundShadowPath appendBezierPath:border];
    [backgroundShadowPath appendBezierPath:thumb];
    [backgroundShadowPath setWindingRule:NSWindingRuleEvenOdd];
    [border addClip];
    [grayBorderColor set];
    [[self backgroundShadow] set];
    [backgroundShadowPath fill];
    [NSGraphicsContext restoreGraphicsState];
    
    [grayBorderColor set];
    [border stroke];

    // Draw the text. This comes before the thumb.
    [[self attributedAlternateTitle] drawInRect:[self alternateTextRectForCellFrame:cellFrame controlView:controlView]];
    [[self attributedTitle] drawInRect:[self textRectForCellFrame:cellFrame controlView:controlView]];
    
    if (_trackingMouse && _mouseInThumb) {
        [[self thumbDarkGradient] drawInBezierPath:thumb angle:90.0];
    } else {
        [[self thumbGradient] drawInBezierPath:thumb angle:90.0];
    }
    [NSGraphicsContext saveGraphicsState];
    backgroundShadowPath = [[NSBezierPath alloc] init];
    [backgroundShadowPath appendBezierPathWithRect:NSInsetRect(cellFrame, -10.0, -10.0)];
    [backgroundShadowPath appendBezierPath:thumb];
    [backgroundShadowPath setWindingRule:NSWindingRuleEvenOdd];
    [thumb addClip];
    [grayBorderColor set];
    [[self thumbInnerShadow] set];
    [backgroundShadowPath fill];
    [NSGraphicsContext restoreGraphicsState];
    [grayBorderColor set];
    [thumb stroke];
    
    if (![self isEnabled]) {
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.33] set];
        [border fill];
    }
    
}


#pragma mark NSCell - Mouse Tracking

+ (BOOL)prefersTrackingUntilMouseUp {
    return YES;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
    if (!_trackingMouse) {
        NSRect    rect = [self thumbRectForCellFrame:cellFrame];
        
        //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
        //AJRPrintf(@"%C:    state: %d\n", self, [self state]);
        
        _startPoint = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
        _thumbOffset = 0.0;
        _cellFrame = cellFrame;
        if (NSMouseInRect(_startPoint, rect, [controlView isFlipped])) {
            _mouseInThumb = YES;
        } else {
            _mouseInThumb = NO;
        }
        _trackingMouse = YES;
    }
    
    return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    
    // There's nothing to do visually if the user didn't click in the thumb
    if (!_mouseInThumb) return YES;
    
    return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    
    // There's nothing to do visually if the user didn't click in the thumb
    if (!_mouseInThumb) return YES;
    
    _thumbOffset = _startPoint.x - currentPoint.x;
    [controlView setNeedsDisplay:YES];

    return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    //AJRPrintf(@"%C:    state: %d\n", self, [self state]);

    if (flag) {
        NSRect        thumbRect = [self thumbRectForCellFrame:_cellFrame];
        NSRect        newThumbRect;
        CGFloat        percentage = 1.0;

        //AJRPrintf(@"%C:    mouseInThumb: %B\n", self, _mouseInThumb);
        // We only do something if the mouse is up. This can be NO when we're part of a matrix.
        if (_mouseInThumb && _startPoint.x != stopPoint.x) {
            // See if the thumb is over the halfway mark to the secondary state, and if it is, then
            // animate the thumb to its resting point in the new state.
            NSInteger    desiredState;
            
            if (thumbRect.size.width > thumbRect.origin.x - _cellFrame.origin.x + thumbRect.size.width / 2.0) {
				desiredState = NSControlStateValueOff;
            } else {
                desiredState = NSControlStateValueOn;
            }
            //AJRPrintf(@"%C:    desired state: %d\n", self, desiredState);
            
            [self setState:desiredState];
        } else {
            // Just animate the thumb to its new state. Note our superclass seems to flip our state
            // for us.
			[self setState:[self state] == NSControlStateValueOff];
        }
        
        _trackingMouse = NO;
        _ignoreNextSetState = YES;
        
        newThumbRect = [self thumbRectForCellFrame:_cellFrame];
        
        _animationOffset = newThumbRect.origin.x - thumbRect.origin.x;
        percentage = (fabs(_animationOffset) / (_cellFrame.size.width / 2.0 - 5.5)) / 2.0 + 0.5;
        //AJRPrintf(@"%C:    _animationOffset: %.1f, percentage: %.1f\n", self, _animationOffset, percentage);
        
        if (percentage > 0.0) {
            [self startThumbAnimationInControlView:controlView durationPercentage:percentage];
        }
    }
}

- (void)setState:(NSInteger)value {
    if (_ignoreNextSetState) {
        _ignoreNextSetState = NO;
    } else {
        [super setState:value];
    }
}

#pragma mark Animation

- (void)startThumbAnimationInControlView:(NSView *)controlView durationPercentage:(CGFloat)percentage {
    if (_animation) {
        [_animation stopAnimation];
    }
    
    _animationControlView = (NSControl *)controlView;
    _animation = [[AJRToggleButtonAnimation alloc] initWithDuration:0.125 * percentage animationCurve:NSAnimationEaseInOut];
    [_animation setToggleButtonCell:self];
    [_animation setAnimationBlockingMode:NSAnimationNonblocking];
    [_animation setFrameRate:60.0];
    [_animation setDelegate:self];

    // The initial offset to draw the thumb at.
    _thumbOffset = _animationOffset;

    [NSAnimationContext beginGrouping];
    [_animation startAnimation];
    [NSAnimationContext endGrouping];
}

#pragma mark NSAnimationDelegate

- (void)_updateThumbOffsetForAnimationProgress:(NSAnimationProgress)progress {
    _thumbOffset = (1.0 - progress) * _animationOffset;
    //AJRPrintf(@"%C: animation progress: %.3f, offset: %.3f\n", self, progress, _thumbOffset);
    [_animationControlView setNeedsDisplay:YES];
}

- (void)animationDidStop:(NSAnimation *)animation {
    //AJRPrintf(@"%C: animation stop\n", self);
     _animationControlView = nil;
     _animation = nil;
    _animationOffset = 0.0;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        _backgroundColor = [coder decodeObjectForKey:@"backgroundColor"];
        _alternateBackgroundColor = [coder decodeObjectForKey:@"alternateBackgroundColor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_backgroundColor forKey:@"backgroundColor"];
    [coder encodeObject:_alternateBackgroundColor forKey:@"alternateBackgroundColor"];
}

- (id)copyWithZone:(NSZone *)zone {
    NSAssert(NO, @"%@ needs to implement %s.", NSStringFromClass(self.class), __FUNCTION__);
    return nil;
}

@end
