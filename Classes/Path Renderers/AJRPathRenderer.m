
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
