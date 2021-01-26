
#import <AJRInterface/AJRPathRenderer.h>

@interface AJRHaloRenderer : AJRPathRenderer
{
   NSColor        *haloColor;
   CGFloat        width;
}

- (void)setHaloColor:(NSColor *)aColor;
- (NSColor *)haloColor;
- (void)setWidth:(CGFloat)aWidth;
- (CGFloat)width;

@end
