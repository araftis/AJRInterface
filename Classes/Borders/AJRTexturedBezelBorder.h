
#import <AJRInterface/AJRBorder.h>

@class AJREmbossRenderer;

@interface AJRTexturedBezelBorder : AJRBorder
{
    float             radius;
    float                    width;
    AJREmbossRenderer    *renderer;
}

- (void)setRadius:(float)aRadius;
- (float)radius;
- (void)setWidth:(float)aWidth;
- (float)width;

@end
