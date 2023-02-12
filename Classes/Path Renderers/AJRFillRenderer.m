/*
 AJRFillRenderer.m
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

#import "AJRFillRenderer.h"

@implementation AJRFillRenderer

+ (void)load
{
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name
{
   return @"Fill";
}

- (id)init
{
   self = [super init];

   _fillColor = [NSColor blackColor];

   return self;
}


- (void)renderPath:(NSBezierPath *)path
{
   if (_fillColor) {
      [_fillColor set];
   } else {
      [[NSColor blackColor] set];
   }

   [path fill];
}

@synthesize fillColor = _fillColor;

- (void)setFillColor:(NSColor *)aColor
{
   if (_fillColor != aColor) {
      _fillColor = aColor;
      [self didChange];
   }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
   self = [super initWithCoder:coder];

   if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"fillColor"]) {
      _fillColor = [coder decodeObjectForKey:@"fillColor"];
   } else {
      _fillColor = [coder decodeObject];
   }

   return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [super encodeWithCoder:coder];

   if ([coder allowsKeyedCoding]) {
      [coder encodeObject:_fillColor forKey:@"fillColor"];
   } else {
      [coder encodeObject:_fillColor];
   }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    AJRFillRenderer    *copy = [super copyWithZone:zone];
    
    copy->_fillColor = [_fillColor copyWithZone:zone];
    
    return copy;
}

@end
