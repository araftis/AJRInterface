
#import <AJRInterface/AJRBorder.h>

@class AJREmbossRenderer;

@interface AJRPipeBorder : AJRBorder
{
    NSColor                *color;
    float                radius;
    float                width;
    AJREmbossRenderer    *renderer;
}

- (void)setColor:(NSColor *)aColor;
- (NSColor *)color;
- (void)setRadius:(float)aRadius;
- (float)radius;

@end
