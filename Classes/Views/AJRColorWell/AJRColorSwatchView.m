/*
AJRColorSwatchView.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#import "AJRColorSwatchView.h"

#import <AJRFoundation/AJRLogging.h>

@implementation AJRColorSwatchView {
    NSSize _swatchSize;
    NSInteger _width;
    NSInteger _height;
    NSInteger _highlightX;
    NSInteger _highlightY;
    __strong NSColor **_colors;
    
    __weak NSColor *_selectedColor;
    __weak id _target;
    SEL _action;
}

static CGFloat _leftMargin = 5.0;
static CGFloat _rightMargin = 5.0;
static CGFloat _topMargin = 5.0;
static CGFloat _bottomMargin = 5.0;

#pragma mark - Creation

- (id)initWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    NSSize swatchSize = (NSSize){12.0, 12.0};
    
    if ((self = [super initWithFrame:(NSRect){NSZeroPoint, {(swatchSize.width + 1) * width + 1 + (_leftMargin + _rightMargin), (swatchSize.height + 1) * height + 1 + (_topMargin + _bottomMargin)}}])) {
        NSInteger    x, y;
        
        _width = width;
        _height = height;
        _swatchSize = swatchSize;
        _highlightX = -1;
        _highlightY = -1;
        
        _colors = (__strong NSColor **)calloc(sizeof(NSColor *), width * height);
        for (y = 0; y < height; y++) {
            if (y == 0) {
                [self setColor:nil atX:0 andY:y];
                for (x = 1; x < _width; x++) {
                    [self setColor:[NSColor colorWithCalibratedWhite:1.0 - ((CGFloat)(x - 1) / (CGFloat)(_width - 2)) alpha:1.0] atX:x andY:y];
                }
            } else {
                NSInteger twoThirds = floor((CGFloat)_height * (2.0 / 3.0));
                
                for (x = 0; x < _width; x++) {
                    CGFloat    hue, saturation, brightness;
                    
                    hue = (196.0 + (360.0 * ((CGFloat)x / (CGFloat)(_width + 1)))) / 360.0;
                    while (hue > 1.0) hue -= 1.0;
                    if (y > twoThirds) {
                        saturation = 1.0 - (((CGFloat)y - (CGFloat)twoThirds) / ((CGFloat)_height - (CGFloat)twoThirds));
                    } else {
                        saturation = 1.0;
                    }
                    if (y <= twoThirds) {
                        brightness = 0.2 + ((CGFloat)(y - 1) / (CGFloat)twoThirds);
                    } else {
                        brightness = 1.0;
                    }
                    
                    [self setColor:[NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:1.0] atX:x andY:y];
                }
            }
        }
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil]];
    }
    return self;
}

#pragma mark - Destruction

- (void)dealloc {
    NSInteger index;
    
    for (index = 0; index < _height * _width; index++) {
        _colors[index] = nil;
    }
    free(_colors);
}

#pragma mark - Properties

- (void)setColor:(NSColor *)color atX:(NSInteger)x andY:(NSInteger)y {
    _colors[y * _width + x] = color;
}

- (NSColor *)colorAtX:(NSInteger)x andY:(NSInteger)y {
    return _colors[y * _width + x];
}

- (BOOL)getX:(NSInteger *)x andY:(NSInteger *)y forPoint:(NSPoint)point {
    BOOL valid = YES;
    
    *x = floor((point.x - _leftMargin) / (_swatchSize.width + 1.0));
    *y = floor((point.y - _topMargin) / (_swatchSize.height + 1.0));
    
    if (*x < 0 || *x >= _width) {
        valid = NO;
        *x = -1;
    }
    if (*y < 0 || *y >= _height) {
        valid = NO;
        *y = -1;
    }
    
    return valid;
}

- (NSRect)rectForSwatchAtX:(NSInteger)x andY:(NSInteger)y {
    NSRect swatchRect;
    
    swatchRect.origin.x = x * (_swatchSize.width + 1) + _leftMargin + 1.0;
    swatchRect.origin.y = y * (_swatchSize.height + 1) + _topMargin;
    swatchRect.size = _swatchSize;
    
    return swatchRect;
}

- (void)hilightColorAtX:(NSInteger)x andY:(NSInteger)y {
    _highlightX = x;
    _highlightY = y;
    [self setNeedsDisplay:YES];
}

#pragma mark - NSView

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSInteger x, y;
    NSRect swatchRect;
    
    for (y = 0; y < _height; y++) {
        for (x = 0; x < _width; x++) {
            NSColor *color = [self colorAtX:x andY:y];
            
            swatchRect = [self rectForSwatchAtX:x andY:y];
            
            if (color) {
                [color drawSwatchInRect:swatchRect];
            } else {
                [[NSColor whiteColor] set];
                NSRectFill(swatchRect);
                [[NSColor redColor] set];
                [NSBezierPath strokeLineFromPoint:(NSPoint){NSMinX(swatchRect), NSMaxY(swatchRect)} toPoint:(NSPoint){NSMaxX(swatchRect), NSMinY(swatchRect)}];
            }
            
            [[NSColor blackColor] set];
            NSFrameRect(NSInsetRect(swatchRect, -1.0, -1.0));
        }
    }
    if (_highlightX != -1 && _highlightY != -1) {
        NSRect frameRect = [self rectForSwatchAtX:_highlightX andY:_highlightY];
        NSColor *color = [self colorAtX:_highlightX andY:_highlightY];
        CGFloat hue, saturation, brightness, alpha;
        
        [[color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        if (brightness > 0.8 || color == nil) {
            [[NSColor blackColor] set];
        } else {
            [[NSColor whiteColor] set];
        }
        NSFrameRect(NSInsetRect(frameRect, -1.0, -1.0));
        NSFrameRect(NSInsetRect(frameRect, -2.0, -2.0));
    }
}

#pragma mark - NSResponder

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger x, y;
    
    if ([self getX:&x andY:&y forPoint:where]) {
        [self hilightColorAtX:x andY:y];
    } else {
        [self hilightColorAtX:-1 andY:-1];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger x, y;
    
    if ([self getX:&x andY:&y forPoint:where]) {
        [self hilightColorAtX:x andY:y];
    } else {
        [self hilightColorAtX:-1 andY:-1];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger x, y;
    
    if ([self getX:&x andY:&y forPoint:where]) {
        _selectedColor = [self colorAtX:x andY:y];
    } else {
        _selectedColor = nil;
    }
    [self hilightColorAtX:-1 andY:-1];

    [NSApp sendAction:_action to:_target from:self];
}

@end
