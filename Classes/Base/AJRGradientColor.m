/*
 AJRGradientColor.m
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

#import "AJRGradientColor.h"

#import "NSBezierPath+Extensions.h"

@implementation AJRGradientColor {
	BOOL _linearGradient;
}
#pragma mark - Creation

+ (id)gradientColorWithColor:(NSColor *)color {
    return [[self alloc] initWithColor:color];
}

+ (id)gradientColorWithGradient:(NSGradient *)gradient angle:(CGFloat)angle {
    return [[self alloc] initWithGradient:gradient angle:angle];
}

+ (id)gradientColorWithGradient:(NSGradient *)gradient relativeCenterPosition:(NSPoint)relativeCenterPosition {
    return [[self alloc] initWithGradient:gradient relativeCenterPosition:relativeCenterPosition];
}

- (id)initWithColor:(NSColor *)color {
    if ((self = [super init])) {
        _color = color;
    }
    return self;
}

- (id)initWithGradient:(NSGradient *)gradient angle:(CGFloat)angle {
    if ((self = [super init])) {
        _gradient = gradient;
        _angle = angle;
        _linearGradient = YES;
    }
    return self;
}

- (id)initWithGradient:(NSGradient *)gradient relativeCenterPosition:(NSPoint)relativeCenterPosition {
    if ((self = [super init])) {
        _gradient = gradient;
        _relativeCenterPosition = relativeCenterPosition;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawBezierPath:(NSBezierPath *)path {
    if (_color) {
        [_color set];
        [path stroke];
    } else {
        if (_linearGradient) {
            [_gradient drawInBezierPath:[path bezierPathFromStrokedPath] angle:_angle];
        } else {
            [_gradient drawInBezierPath:[path bezierPathFromStrokedPath] relativeCenterPosition:_relativeCenterPosition];
        }
    }
}

- (void)drawInBezierPath:(NSBezierPath *)path {
    if (_color) {
        [_color set];
        [path fill];
    } else {
        if (_linearGradient) {
            [_gradient drawInBezierPath:path angle:_angle];
        } else {
            [_gradient drawInBezierPath:path relativeCenterPosition:_relativeCenterPosition];
        }
    }
}

- (void)drawInRect:(NSRect)rect {
    if (_color) {
        [_color set];
        NSRectFill(rect);
    } else {
        if (_linearGradient) {
            [_gradient drawInRect:rect angle:_angle];
        } else {
            [_gradient drawInRect:rect relativeCenterPosition:_relativeCenterPosition];
        }
    }
}

@end
