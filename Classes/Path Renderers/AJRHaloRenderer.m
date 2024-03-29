/*
 AJRHaloRenderer.m
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

#import "AJRHaloRenderer.h"

const CGFloat AJRMinHaloWidth = 3.0;

@implementation AJRHaloRenderer

+ (void)load {
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name {
    return @"Halo";
}

+ (NSColor *)defaultColor {
    return [NSColor controlAccentColor];
}

- (id)init {
    if ((self = [super init])) {
        _width = AJRMinHaloWidth;
        _color = [[self class] defaultColor];
    }
    
    return self;
}


#pragma mark AJRPathRenderer

- (void)renderPath:(NSBezierPath *)path {
    CGFloat lineWidth = [path lineWidth];
    NSInteger lineJoin = [path lineJoinStyle];
    NSColor *color;
    
    if (_width <= 3) {
        _width = 3;
    }
    
    if (_color) {
        color = _color;
    } else {
        color = [NSColor colorWithCalibratedRed:1.0 green:0.85 blue:0.1 alpha:1.0];
    }
    color = [color colorWithAlphaComponent:1.0];
    
    [path setLineJoinStyle:NSLineJoinStyleRound];
    for (NSInteger x = _width; x >= 2; x--) {
        [path setLineWidth:x];
        [[color colorWithAlphaComponent:1.1 - x / _width] set];
        [path stroke];
    }
    [path setLineWidth:lineWidth];
    [path setLineJoinStyle:lineJoin];
}

#pragma mark Properties

- (void)setColor:(NSColor *)color {
    if (_color != color) {
        _color = color;
        [self didChange];
    }
}

- (void)setWidth:(CGFloat)width {
    if (_width != width) {
        _width = width;
        if (_width < AJRMinHaloWidth) {
            _width = AJRMinHaloWidth;
        }
        [self didChange];
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"color"]) {
            _color = [coder decodeObjectForKey:@"color"];
            _width = [coder decodeFloatForKey:@"width"];
        } else {
            _color = [coder decodeObject];
            [coder decodeValueOfObjCType:@encode(CGFloat) at:&_width];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_color forKey:@"color"];
        [coder encodeFloat:_width forKey:@"width"];
    } else {
        [coder encodeObject:_color];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&_width];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AJRHaloRenderer *copy = [super copyWithZone:zone];
    
    copy->_color = [_color copyWithZone:zone];
    copy->_width = _width;
    
    return copy;
}

@end
