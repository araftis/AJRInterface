
#import <AJRInterface/AJRPathRenderer.h>

@interface AJRStrokeRenderer : AJRPathRenderer
{
   NSColor        *strokeColor;
   float        width;
}

- (void)setStrokeColor:(NSColor *)aColor;
- (NSColor *)strokeColor;
- (void)setWidth:(float)width;
- (float)width;

@end
