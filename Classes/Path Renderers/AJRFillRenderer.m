
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
