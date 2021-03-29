/*
AJRPipeBorder.m
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

#import "AJRPipeBorder.h"

#import "AJREmbossRenderer.h"

@implementation AJRPipeBorder

+ (void)load
{
    [AJRBorder registerBorder:self];
}

+ (void)initialize
{
}

+ (NSString *)name
{
    return @"Pipe";
}

- (id)init
{
    self = [super init];
    
    renderer = [[AJREmbossRenderer alloc] init];
    [self setColor:[NSColor colorWithCalibratedRed:11.0 / 255.0 green:84.0 / 255.0 blue:177.0 / 255.0 alpha:1.0]];
    radius = 10;
    width = 1.0;
    
    return self;
}

- (BOOL)isOpaque
{
    return (radius == 0.0) && ([color alphaComponent] == 1.0);
}

- (void)setColor:(NSColor *)aColor
{
    if (color != aColor) {
        color = aColor;
        [renderer setColor:color];
        [renderer setHighlightColor:[color blendedColorWithFraction:0.85 ofColor:[NSColor whiteColor]]];
        [renderer setShadowColor:[color blendedColorWithFraction:0.85 ofColor:[NSColor blackColor]]];
        [self didUpdate];
    }
}

- (NSColor *)color
{
    return color;
}

- (void)setRadius:(float)aRadius
{
    if (radius != aRadius) {
        radius = aRadius;
        [self didUpdate];
    }
}

- (float)radius
{
    return radius;
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    rect = [super contentRectForRect:rect];
    
    rect.origin.x += 6;
    rect.origin.y += 6;
    rect.size.width -= 12.0;
    rect.size.height -= 12.0;
    
    return rect;
}

- (NSBezierPath *)pathForRadius:(float)aRadius inRect:(NSRect)rect
{
    NSBezierPath    *path;
    
    path = [[NSBezierPath allocWithZone:nil] init];
    if (aRadius == 0.0) {
        [path appendBezierPathWithRect:(NSRect){{rect.origin.x + width / 2.0, rect.origin.y + width / 2.0}, {rect.size.width - width, rect.size.height - width}}];
    } else {
        [path moveToPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height / 2.0 - width / 2.0}];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0} radius:aRadius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0} radius:aRadius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} radius:aRadius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - width / 2.0} radius:aRadius];
        [path closePath];
    }
    
    return path;
}

- (NSBezierPath *)clippingPathForRect:(NSRect)rect
{
    return [self pathForRadius:radius inRect:rect];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    [renderer setAngle:45.0];
    [renderer setHighlightColor:color];
    [renderer setShadowColor:[color blendedColorWithFraction:0.85 ofColor:[NSColor blackColor]]];
    [renderer renderPath:[self pathForRadius:radius - 0.0 inRect:rect]];
    [renderer setColor:[color blendedColorWithFraction:0.3 ofColor:[NSColor whiteColor]]];
    [renderer setHighlightColor:[color blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]]];
    [renderer setShadowColor:[color blendedColorWithFraction:0.50 ofColor:[NSColor blackColor]]];
    [renderer renderPath:[self pathForRadius:radius - 1.0 inRect:NSInsetRect(rect, 1.0, 1.0)]];
    [renderer setColor:[color blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]]];
    [renderer setHighlightColor:[color blendedColorWithFraction:0.67 ofColor:[NSColor whiteColor]]];
    [renderer setShadowColor:color];
    [renderer renderPath:[self pathForRadius:radius - 2.0 inRect:NSInsetRect(rect, 2.0, 2.0)]];
    
    [renderer setAngle:225.0];
    [renderer renderPath:[self pathForRadius:radius - 3.0 inRect:NSInsetRect(rect, 3.0, 3.0)]];
    [renderer setColor:[color blendedColorWithFraction:0.3 ofColor:[NSColor whiteColor]]];
    [renderer setHighlightColor:[color blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]]];
    [renderer setShadowColor:[color blendedColorWithFraction:0.50 ofColor:[NSColor blackColor]]];
    [renderer renderPath:[self pathForRadius:radius - 4.0 inRect:NSInsetRect(rect, 4.0, 4.0)]];
    [renderer setColor:color];
    [renderer setHighlightColor:color];
    [renderer setShadowColor:[color blendedColorWithFraction:0.85 ofColor:[NSColor blackColor]]];
    [renderer renderPath:[self pathForRadius:radius - 5.0 inRect:NSInsetRect(rect, 5.0, 5.0)]];
    
    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    renderer = [[AJREmbossRenderer alloc] init];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"width"]) {
        width = [coder decodeFloatForKey:@"width"];
        color = [coder decodeObjectForKey:@"color"];
        radius = [coder decodeFloatForKey:@"radius"];
    } else {
        [coder decodeValueOfObjCType:@encode(float) at:&width];
        [self setColor:[coder decodeObject]];
        [coder decodeValueOfObjCType:@encode(float) at:&radius];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeFloat:width forKey:@"width"];
        [coder encodeObject:color forKey:@"color"];
        [coder encodeFloat:radius forKey:@"radius"];
    } else {
        [coder encodeValueOfObjCType:@encode(float) at:&width];
        [coder encodeObject:color];
        [coder encodeValueOfObjCType:@encode(float) at:&radius];
    }
}

@end
