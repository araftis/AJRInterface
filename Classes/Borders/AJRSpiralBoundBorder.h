
#import <AJRInterface/AJRDropShadowBorder.h>

@interface AJRSpiralBoundBorder : AJRDropShadowBorder
{
    NSUInteger            edge;
}

- (void)setEdge:(NSUInteger)anEdge;
- (NSUInteger)edge;

@end
