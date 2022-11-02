/*
 AJRSeparatorBorder.m
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

#import "AJRSeparatorBorder.h"

#import "AJRGradientColor.h"

@implementation AJRSeparatorBorder

#pragma mark - Loading

+ (void)load {
    [AJRBorder registerBorder:self];
}

#pragma mark - Properties

- (void)setLeftColor:(AJRGradientColor *)color {
    if (_leftColor != color) {
        [self willUpdate];
        _leftColor = color;
        [self didUpdate];
    }
}

- (void)setRightColor:(AJRGradientColor *)color {
    if (_rightColor != color) {
        [self willUpdate];
        _rightColor = color;
        [self didUpdate];
    }
}

- (void)setTopColor:(AJRGradientColor *)color {
    if (_topColor != color) {
        [self willUpdate];
        _topColor = color;
        [self didUpdate];
    }
}

- (void)setBottomColor:(AJRGradientColor *)color {
    if (_bottomColor != color) {
        [self willUpdate];
        _bottomColor = color;
        [self didUpdate];
    }
}

- (void)setBackgroundColor:(AJRGradientColor *)color {
    if (_backgroundColor != color) {
        [self willUpdate];
        _backgroundColor = color;
        [self didUpdate];
    }
}

#pragma mark - Border

- (BOOL)isOpaque {
    return _backgroundColor && ([[_backgroundColor color] alphaComponent] == 1.0);
}

- (NSRect)contentRectForRect:(NSRect)rect {
    NSRect      result = rect;
    
    if (_topColor || _inactiveTopColor) {
        result.size.height -= 1.0;
    }
    if (_bottomColor || _inactiveBottomColor) {
        result.origin.y += 1.0;
        result.size.height -= 1.0;
    }
    if (_leftColor || _inactiveLeftColor) {
        result.size.width -= 1.0;
        result.origin.x += 1.0;
    }
    if (_rightColor || _inactiveRightColor) {
        result.size.width -= 1.0;
    }
    
    return result;
}

- (AJRGradientColor *)colorForColor:(AJRGradientColor *)activeColor or:(AJRGradientColor *)inactiveColor for:(NSView *)controlView {
    return [self isControlViewActive:controlView] ? activeColor : (inactiveColor ? inactiveColor : activeColor);
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    [[self colorForColor:_backgroundColor or:_inactiveBackgroundColor for:controlView] drawInRect:[self contentRectForRect:rect]];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    NSRect work;

    if (_topColor || _inactiveTopColor) {
        work.origin.x = NSMinX(rect);
        work.size.width = rect.size.width;
        work.origin.y = NSMaxY(rect) - 1.0;
        work.size.height = 1.0;
        [[self colorForColor:_topColor or:_inactiveTopColor for:controlView] drawInRect:work];
    }
    if (_bottomColor || _inactiveBottomColor) {
        work.origin.x = NSMinX(rect);
        work.size.width = rect.size.width;
        work.origin.y = NSMinY(rect);
        work.size.height = 1.0;
        [[self colorForColor:_bottomColor or:_inactiveBottomColor for:controlView] drawInRect:work];
    }
    if (_leftColor || _inactiveLeftColor) {
        work.origin.x = NSMinX(rect);
        work.size.width = 1.0;
        work.origin.y = NSMinY(rect);
        work.size.height = rect.size.height;
        [[self colorForColor:_leftColor or:_inactiveLeftColor for:controlView] drawInRect:work];
    }
    if (_rightColor || _inactiveRightColor) {
        work.origin.x = NSMaxX(rect) - 1.0;
        work.size.width = 1.0;
        work.origin.y = NSMinY(rect);
        work.size.height = rect.size.height;
        [[self colorForColor:_rightColor or:_inactiveRightColor for:controlView] drawInRect:work];
    }
}

@end
