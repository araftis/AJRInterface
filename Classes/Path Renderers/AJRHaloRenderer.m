
#import "AJRHaloRenderer.h"

const CGFloat AJRMinHaloWidth = 3.0;

@implementation AJRHaloRenderer

+ (void)load
{
    [AJRPathRenderer registerRenderer:self];
}

+ (NSString *)name
{
    return @"Halo";
}

- (id)init
{
    self = [super init];
    
    width = AJRMinHaloWidth;
    haloColor = [NSColor colorWithCalibratedRed:1.0 green:0.85 blue:0.1 alpha:1.0 / width];
    
    return self;
}


#pragma mark AJRPathRenderer

- (void)renderPath:(NSBezierPath *)path
{
    CGFloat            lineWidth = [path lineWidth];
    NSInteger        lineJoin = [path lineJoinStyle];
    NSInteger        x;
    NSColor            *color;
    
    if (width <= 3) width = 3;
    
    if (haloColor) {
        color = haloColor;
    } else {
        color = [NSColor colorWithCalibratedRed:1.0 green:0.85 blue:0.1 alpha:1.0 / (CGFloat)width];
    }
    color = [color colorWithAlphaComponent:1.0];
    
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    for (x = width; x >= 2; x--) {
        [path setLineWidth:x];
        [[color colorWithAlphaComponent:1.1 - x / width] set];
        [path stroke];
    }
    [path setLineWidth:lineWidth];
    [path setLineJoinStyle:lineJoin];
}

#pragma mark Properties

- (void)setHaloColor:(NSColor *)aColor
{
    if (haloColor != aColor) {
        haloColor = aColor;
        [self didChange];
    }
}

- (NSColor *)haloColor
{
    return haloColor;
}

- (void)setWidth:(CGFloat)aWidth
{
    if (width != aWidth) {
        width = aWidth;
        if (width < AJRMinHaloWidth) {
            width = AJRMinHaloWidth;
        }
        [self didChange];
    }
}

- (CGFloat)width
{
    return width;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"haloColor"]) {
        haloColor = [coder decodeObjectForKey:@"haloColor"];
        width = [coder decodeFloatForKey:@"width"];
    } else {
        haloColor = [coder decodeObject];
        [coder decodeValueOfObjCType:@encode(CGFloat) at:&width];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:haloColor forKey:@"haloColor"];
        [coder encodeFloat:width forKey:@"width"];
    } else {
        [coder encodeObject:haloColor];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&width];
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    AJRHaloRenderer    *copy = [super copyWithZone:zone];
    
    copy->haloColor = [haloColor copyWithZone:zone];
    copy->width = width;
    
    return copy;
}

@end
