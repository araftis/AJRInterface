
#import <AJRInterface/AJRBorder.h>

@interface AJRLineBorder : AJRBorder
{
    CGFloat        width;
    NSColor        *color;
    CGFloat        radius;
}

- (void)setWidth:(CGFloat)aWidth;
- (CGFloat)width;
- (void)setColor:(NSColor *)color;
- (NSColor *)color;
- (void)setRadius:(CGFloat)aRadius;
- (CGFloat)radius;

@end
