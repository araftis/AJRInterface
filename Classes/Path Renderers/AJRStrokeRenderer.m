
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
