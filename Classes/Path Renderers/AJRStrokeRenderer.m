/*
 AJRStrokeRenderer.m
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

#import "AJRStrokeRenderer.h"

@implementation AJRStrokeRenderer {
    NSColor *_strokeColor; // Because we implement set and get.
}

+ (void)load {
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name {
    return @"Stroke";
}

- (id)init {
    if ((self = [super init])) {
        _strokeColor = [NSColor blackColor];
        _width = 1.0;
    }
    return self;
}


- (void)renderPath:(NSBezierPath *)path {
    float widthSave;

    if (_strokeColor) {
        [_strokeColor set];
    } else {
        [[NSColor blackColor] set];
    }
    if (_width != 0.0) {
        widthSave = [path lineWidth];
        [path setLineWidth:_width];
    }
    [path stroke];
    if (_width != 0.0) {
        [path setLineWidth:_width];
    }
}

- (void)setStrokeColor:(NSColor *)color {
    if (_strokeColor != color) {
        _strokeColor = color;
        [self didChange];
    }
}

- (NSColor *)strokeColor {
    if (_strokeColor) {
        return _strokeColor;
    }
    return [NSColor blackColor];
}

- (void)setWidth:(CGFloat)aWidth {
    if (_width != aWidth) {
        _width = aWidth;
        [self didChange];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"strokeColor"]) {
            _strokeColor = [coder decodeObjectForKey:@"strokeColor"];
            _width = [coder decodeFloatForKey:@"width"];
        } else {
            _strokeColor = [coder decodeObject];
            [coder decodeValueOfObjCType:@encode(float) at:&_width];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_strokeColor forKey:@"strokeColor"];
        [coder encodeFloat:_width forKey:@"width"];
    } else {
        [coder encodeObject:_strokeColor];
        [coder encodeValueOfObjCType:@encode(float) at:&_width];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AJRStrokeRenderer *copy = [super copyWithZone:zone];
    
    copy->_strokeColor = [_strokeColor copyWithZone:zone];
    copy->_width = _width;
    
    return copy;
}

@end
