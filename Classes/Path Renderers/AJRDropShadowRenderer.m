
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
