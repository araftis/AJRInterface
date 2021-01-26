
#import <AJRInterface/AJRBorder.h>

@interface AJRDropShadowBorder : AJRBorder
{
    BOOL        shallow:1;
    BOOL        clip:1;
    CGFloat        radius;

}

- (void)setShallow:(BOOL)flag;
- (BOOL)isShallow;
- (void)setClip:(BOOL)flag;
- (BOOL)doesClip;
- (void)setRadius:(CGFloat)aRadius;
- (CGFloat)radius;

@end
