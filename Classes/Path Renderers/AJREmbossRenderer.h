
#import <AJRInterface/AJRPathRenderer.h>

@interface AJREmbossRenderer : AJRPathRenderer
{
    NSColor            *color;
    NSColor            *highlightColor;
    NSColor            *shadowColor;
    float            angle;
    float            width;
    float            error;
}

- (void)setColor:(NSColor *)aColor;
- (NSColor *)color;
- (void)setHighlightColor:(NSColor *)aColor;
- (NSColor *)highlightColor;
- (void)setShadowColor:(NSColor *)aColor;
- (NSColor *)shadowColor;
- (void)setAngle:(float)anAngle;
- (float)angle;
- (void)setWidth:(float)aWidth;
- (float)width;
- (void)setError:(float)anError;
- (float)error;

@end
