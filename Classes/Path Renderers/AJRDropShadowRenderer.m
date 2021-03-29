/*
AJRDropShadowRenderer.m
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

#import "AJRDropShadowRenderer.h"

#import "NSAffineTransform+Extensions.h"

@implementation AJRDropShadowRenderer

+ (void)load {
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name {
   return @"Drop Shadow";
}

- (id)init {
   self = [super init];

   shadowColor = [NSColor blackColor];

   return self;
}


- (void)renderPath:(NSBezierPath *)path {
   NSColor    *color = nil;
   NSInteger        lineJoin;
   float        lineWidth;

   if (shadowColor) {
      color = shadowColor;
   } else {
      color = [NSColor blackColor];
   }

   [[NSGraphicsContext currentContext] saveGraphicsState];
   
   lineJoin = [path lineJoinStyle];
   lineWidth = [path lineWidth];

   [path setLineJoinStyle:1];

   if ([[NSView focusView] isFlipped]) {
      [NSAffineTransform translateXBy:0 yBy:1.0];
   } else {
      [NSAffineTransform translateXBy:0 yBy:-1.0];
   }
   [path setLineWidth:6];
   [[color colorWithAlphaComponent:0.05] set];
   [path stroke];

   [path setLineWidth:4];
   [[color colorWithAlphaComponent:0.10] set];
   [path stroke];

   [path setLineWidth:2];
   [[color colorWithAlphaComponent:0.15] set];
   [path stroke];

   [path setLineJoinStyle:lineJoin];
   [path setLineWidth:lineWidth];

   [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)setShadowColor:(NSColor *)aColor {
   if (shadowColor != aColor) {
      shadowColor = aColor;
      [self didChange];
   }
}

- (NSColor *)shadowColor {
   return shadowColor;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
   self = [super initWithCoder:coder];

   if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"shadowColor"]) {
      shadowColor = [coder decodeObjectForKey:@"shadowColor"];
   } else {
      shadowColor = [coder decodeObject];
   }

   return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
   [super encodeWithCoder:coder];

   if ([coder allowsKeyedCoding]) {
      [coder encodeObject:shadowColor forKey:@"shadowColor"];
   } else {
      [coder encodeObject:shadowColor];
   }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AJRDropShadowRenderer *copy = [super copyWithZone:zone];
    
    copy->shadowColor = [shadowColor copyWithZone:zone];
    
    return copy;
}

@end
