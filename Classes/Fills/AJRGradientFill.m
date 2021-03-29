/*
AJRGradientFill.m
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

#import "AJRGradientFill.h"

#import <AJRInterfaceFoundation/AJRTrigonometry.h>

@implementation AJRGradientFill

+ (void)load {
    [AJRFill registerFill:self];
}

+ (NSString *)name {
    return @"Gradient Fill";
}

- (id)init {
	if ((self = [super init])) {
        _gradient = [[NSGradient alloc] initWithStartingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.25] endingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.75]];
		_angle = 335.0;
	}
    return self;
}


- (void)setGradient:(NSGradient *)gradient {
    if (_gradient != gradient) {
        [self willUpdate];
        _gradient = gradient;
        [self didUpdate];
    }
}

- (void)setAngle:(CGFloat)angle {
    if (_angle != angle) {
        [self willUpdate];
        _angle = angle;
        [self didUpdate];
    }
}

- (void)setColor:(NSColor *)aColor {
    NSGradient *old = _gradient;
    NSColor *endingColor;
    
    [old getColor:&endingColor location:NULL atIndex:[old numberOfColorStops] - 1];
    
    [self willUpdate];
    
    _gradient = [[NSGradient alloc] initWithStartingColor:aColor endingColor:endingColor];
    
    [self didUpdate];
}

- (NSColor *)color {
    NSColor *color = nil;
    
    [_gradient getColor:&color location:NULL atIndex:0];
    
    return color;
}

- (void)setSecondaryColor:(NSColor *)aColor {
    NSGradient *old = _gradient;
    NSColor *startingColor;
    
    [old getColor:&startingColor location:NULL atIndex:0];
    
    [self willUpdate];
    
    _gradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:aColor];

    [self didUpdate];
}

- (NSColor *)secondaryColor {
    NSColor *color = nil;
    
    [_gradient getColor:&color location:NULL atIndex:[_gradient numberOfColorStops] - 1];
    
    return color;
}

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView {
    [_gradient drawInBezierPath:path angle:_angle];
}

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView {
    [_gradient drawInRect:rect angle:_angle];
}

- (BOOL)isOpaque {
    return [[self color] alphaComponent] == 1.0 || [[self secondaryColor] alphaComponent] == 1.0;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding]) {
			_gradient = [coder decodeObjectForKey:@"gradient"];
			_angle = [coder decodeFloatForKey:@"angle"];
		} else {
			_gradient = [coder decodeObject];
			[coder decodeValueOfObjCType:@encode(CGFloat) at:&_angle];
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_gradient forKey:@"gradient"];
        [coder encodeFloat:_angle forKey:@"angle"];
    } else {
        [coder encodeObject:_gradient];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&_angle];
    }
}

@end
