
#import <AJRInterface/AJRFill.h>

@interface AJRGradientFill : AJRFill
{
    NSGradient    *_gradient;
    CGFloat        _angle;
}

@property (nonatomic,strong) NSGradient *gradient;
@property (nonatomic,assign) CGFloat angle;

- (void)setColor:(NSColor *)aColor;
- (NSColor *)color;
- (void)setSecondaryColor:(NSColor *)aColor;
- (NSColor *)secondaryColor;

@end
