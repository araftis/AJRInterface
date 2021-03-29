/*
AJRStrokeRenderer.m
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

#import "AJRStrokeRenderer.h"

@implementation AJRStrokeRenderer

+ (void)load
{
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name
{
   return @"Stroke";
}

- (id)init
{
   self = [super init];

   strokeColor = [NSColor blackColor];
   width = 1.0;

   return self;
}


- (void)renderPath:(NSBezierPath *)path
{
   float        widthSave;
   
   if (strokeColor) {
      [strokeColor set];
   } else {
      [[NSColor blackColor] set];
   }
   if (width != 0.0) {
      widthSave = [path lineWidth];
      [path setLineWidth:width];
   }
   [path stroke];
   if (width != 0.0) {
      [path setLineWidth:width];
   }
}

- (void)setStrokeColor:(NSColor *)aColor
{
   if (strokeColor != aColor) {
      strokeColor = aColor;
      [self didChange];
   }
}

- (NSColor *)strokeColor
{
   if (strokeColor) {
      return strokeColor;
   }
   return [NSColor blackColor];
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

- (id)initWithCoder:(NSCoder *)coder
{
   self = [super initWithCoder:coder];

   if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"strokeColor"]) {
      strokeColor = [coder decodeObjectForKey:@"strokeColor"];
      width = [coder decodeFloatForKey:@"width"];
   } else {
      strokeColor = [coder decodeObject];
      [coder decodeValueOfObjCType:@encode(float) at:&width];
   }

   return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [super encodeWithCoder:coder];

   if ([coder allowsKeyedCoding]) {
      [coder encodeObject:strokeColor forKey:@"strokeColor"];
      [coder encodeFloat:width forKey:@"width"];
   } else {
      [coder encodeObject:strokeColor];
      [coder encodeValueOfObjCType:@encode(float) at:&width];
   }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    AJRStrokeRenderer    *copy = [super copyWithZone:zone];
    
    copy->strokeColor = [strokeColor copyWithZone:zone];
    copy->width = width;
    
    return copy;
}

@end
