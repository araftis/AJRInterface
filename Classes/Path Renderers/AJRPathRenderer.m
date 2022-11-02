/*
 AJRPathRenderer.m
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

#import "AJRPathRenderer.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterface/NSUserDefaults+Extensions.h>

NSString *AJRPathRendererDidUpdateNotification = @"AJRPathRendererDidUpdateNotification";

static NSMutableDictionary    *_renderers = nil;

@implementation AJRPathRenderer

+ (void)initialize
{
   if (_renderers == nil) {
      _renderers = [[NSMutableDictionary alloc] init];
   }
}

#pragma mark Renderer Management

+ (void)registerRenderer:(Class)aClass
{
    [_renderers setObject:aClass forKey:[aClass name]];
}

+ (NSString *)name
{
   return @"";
}

+ (NSArray *)renderers
{
   return [[_renderers allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (AJRPathRenderer *)rendererForName:(NSString *)name
{
   return [[[_renderers objectForKey:name] alloc] init];
}

+ (AJRPathRenderer *)rendererForDictionary:(NSDictionary *)dictionary
{
   AJRPathRenderer    *renderer = [self rendererForName:[dictionary objectForKey:@"name"]];
   NSArray                *keys;
   NSString                *key;
   id                        value;
   NSInteger                    x;

   keys = [dictionary allKeys];
   for (x = 0; x < (const NSInteger)[keys count]; x++) {
      key = [keys objectAtIndex:x];
      if ([key isEqualToString:@"name"]) continue;
      value = [dictionary objectForKey:key];
      if ([value hasPrefix:@"(NSColor *)"]) {
         value = AJRColorFromString([value substringFromIndex:11]);
         [renderer setValue:value forKey:key];
      } else {
         AJRPrintf(@"WARNING: Didn't handle %@ = '%@'", key, value);
      }
   }

   return renderer;
}

#pragma mark Change Notification

- (void)didChange
{
   [[NSNotificationCenter defaultCenter] postNotificationName:AJRPathRendererDidUpdateNotification object:self];
}

#pragma mark Drawing

- (void)renderPath:(NSBezierPath *)path
{
   [[NSColor blackColor] set];
   [path stroke];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
   return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] alloc];
}

@end
