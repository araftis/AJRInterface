/*
AJREmbossRenderer.m
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

#import "AJREmbossRenderer.h"

#import <AJRInterfaceFoundation/AJRPathEnumerator.h>
#import "NSBezierPath+Extensions.h"

@implementation AJREmbossRenderer

+ (void)load
{
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name
{
   return @"Emboss";
}

- (id)init
{
   self = [super init];
   
   [self setColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0]];
   [self setHighlightColor:[NSColor whiteColor]];
   [self setShadowColor:[NSColor blackColor]];
   [self setAngle:45.0];
   [self setWidth:1.5];
   [self setError:0.25];
   
   return self;
}


- (void)setColor:(NSColor *)aColor
{
   if (color != aColor) {
      color = aColor;
      [self didChange];
   }
}

- (NSColor *)color
{
   return color;
}

- (void)setHighlightColor:(NSColor *)aColor
{
   if (highlightColor != aColor) {
      highlightColor = aColor;
      [self didChange];
   }
}

- (NSColor *)highlightColor
{
   return highlightColor;
}

- (void)setShadowColor:(NSColor *)aColor
{
   if (shadowColor != aColor) {
      shadowColor = aColor;
      [self didChange];
   }
}

- (NSColor *)shadowColor
{
   return shadowColor;
}

- (void)setAngle:(float)anAngle
{
   if (angle != anAngle) {
      angle = anAngle;
      [self didChange];
   }
}

- (float)angle
{
   return angle;
}

- (void)setWidth:(float)aWidth
{
   if (width != aWidth) {
      width = aWidth;
      [self didChange];
   }
}

- (float)width
{
   return width;
}

- (void)setError:(float)anError
{
   if (error != anError) {
      error = anError;
      [self didChange];
   }
}

- (float)error
{
   return error;
}

- (void)renderPath:(NSBezierPath *)path
{
   CGFloat            arctan;
   AJRPathEnumerator    *enumerator;
   AJRLine            *line;
   CGFloat            intensity;
   
   enumerator = [path pathEnumerator];
   [enumerator setError:error];
   [NSBezierPath setDefaultLineWidth:width];
   while ((line = [enumerator nextLineSegment])) {
      [[NSColor blackColor] set];
      if (!NSEqualPoints(line->start, line->end)) {
         arctan = AJRArctan(line->end.y - line->start.y, line->end.x - line->start.x);
         intensity = AJRCos(arctan - angle);
         //AJRPrintf(@"%.1f: %.1f %.1f\n", arctan, arctan - angle, intensity);
         if (intensity >= 0) {
            [[color blendedColorWithFraction:intensity ofColor:highlightColor] set];
         } else {
            [[color blendedColorWithFraction:-intensity ofColor:shadowColor] set];
         }
         [NSBezierPath strokeLineFromPoint:line->start toPoint:line->end];
      }
   }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
   self = [super initWithCoder:coder];

   if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"color"]) {
      color = [coder decodeObjectForKey:@"color"];
      highlightColor = [coder decodeObjectForKey:@"highlightColor"];
      shadowColor = [coder decodeObjectForKey:@"shadowColor"];
      angle = [coder decodeIntForKey:@"angle"];
      width = [coder decodeIntForKey:@"width"];
      if (width < 0.0) width = 0.0;
      error = [coder decodeIntForKey:@"error"];
      if (error < 0.1) error = 0.1;
   } else {
      color = [coder decodeObject];
      highlightColor = [coder decodeObject];
      shadowColor = [coder decodeObject];
      [coder decodeValueOfObjCType:@encode(float) at:&angle];
      [coder decodeValueOfObjCType:@encode(float) at:&width];
      [coder decodeValueOfObjCType:@encode(float) at:&error];
   }
      
   return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [super encodeWithCoder:coder];

   if ([coder allowsKeyedCoding]) {
      [coder encodeObject:color forKey:@"color"];
      [coder encodeObject:highlightColor forKey:@"highlightColor"];
      [coder encodeObject:shadowColor forKey:@"shadowColor"];
      [coder encodeInt:angle forKey:@"angle"];
      [coder encodeInt:width forKey:@"width"];
      [coder encodeInt:error forKey:@"error"];
   } else {
      [coder encodeObject:color];
      [coder encodeObject:highlightColor];
      [coder encodeObject:shadowColor];
      [coder encodeValueOfObjCType:@encode(float) at:&angle];
      [coder encodeValueOfObjCType:@encode(float) at:&width];
      [coder encodeValueOfObjCType:@encode(float) at:&error];
   }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    AJREmbossRenderer    *copy = [super copyWithZone:zone];
    
    copy->color = [color copyWithZone:zone];
    copy->highlightColor = [highlightColor copyWithZone:zone];
    copy->shadowColor = [shadowColor copyWithZone:zone];
    copy->angle = angle;
    copy->width = width;
    copy->error = error;
    
    return copy;
}

@end
