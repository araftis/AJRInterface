
#import <AJRInterface/AJRPathRenderer.h>

@interface AJRFillRenderer : AJRPathRenderer
{
    NSColor        *_fillColor;
}

@property (nonatomic,strong) NSColor *fillColor;

@end
