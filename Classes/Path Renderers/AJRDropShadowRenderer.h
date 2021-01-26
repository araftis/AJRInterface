
#import <AJRInterface/AJRPathRenderer.h>

@interface AJRDropShadowRenderer : AJRPathRenderer
{
   NSColor        *shadowColor;
}

- (void)setShadowColor:(NSColor *)aColor;
- (NSColor *)shadowColor;

@end
