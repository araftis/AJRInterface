/*
AJRHaloRenderer.m
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

#import "AJRHaloRenderer.h"

const CGFloat AJRMinHaloWidth = 3.0;

@implementation AJRHaloRenderer

+ (void)load
{
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name
{
    return @"Halo";
}

- (id)init
{
    self = [super init];
    
    width = AJRMinHaloWidth;
    haloColor = [NSColor colorWithCalibratedRed:1.0 green:0.85 blue:0.1 alpha:1.0 / width];
    
    return self;
}


#pragma mark AJRPathRenderer

- (void)renderPath:(NSBezierPath *)path
{
    CGFloat            lineWidth = [path lineWidth];
    NSInteger        lineJoin = [path lineJoinStyle];
    NSInteger        x;
    NSColor            *color;
    
    if (width <= 3) width = 3;
    
    if (haloColor) {
        color = haloColor;
    } else {
        color = [NSColor colorWithCalibratedRed:1.0 green:0.85 blue:0.1 alpha:1.0 / (CGFloat)width];
    }
    color = [color colorWithAlphaComponent:1.0];
    
    [path setLineJoinStyle:NSLineJoinStyleRound];
    for (x = width; x >= 2; x--) {
        [path setLineWidth:x];
        [[color colorWithAlphaComponent:1.1 - x / width] set];
        [path stroke];
    }
    [path setLineWidth:lineWidth];
    [path setLineJoinStyle:lineJoin];
}

#pragma mark Properties

- (void)setHaloColor:(NSColor *)aColor
{
    if (haloColor != aColor) {
        haloColor = aColor;
        [self didChange];
    }
}

- (NSColor *)haloColor
{
    return haloColor;
}

- (void)setWidth:(CGFloat)aWidth
{
    if (width != aWidth) {
        width = aWidth;
        if (width < AJRMinHaloWidth) {
            width = AJRMinHaloWidth;
        }
        [self didChange];
    }
}

- (CGFloat)width
{
    return width;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"haloColor"]) {
        haloColor = [coder decodeObjectForKey:@"haloColor"];
        width = [coder decodeFloatForKey:@"width"];
    } else {
        haloColor = [coder decodeObject];
        [coder decodeValueOfObjCType:@encode(CGFloat) at:&width];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:haloColor forKey:@"haloColor"];
        [coder encodeFloat:width forKey:@"width"];
    } else {
        [coder encodeObject:haloColor];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&width];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    AJRHaloRenderer    *copy = [super copyWithZone:zone];
    
    copy->haloColor = [haloColor copyWithZone:zone];
    copy->width = width;
    
    return copy;
}

@end
