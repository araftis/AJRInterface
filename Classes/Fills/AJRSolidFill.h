
#import <AJRInterface/AJRFill.h>

@interface AJRSolidFill : AJRFill
{
    NSColor        *_color;
    NSColor        *_unfocusedColor;
}

@property (nonatomic,strong) NSColor *color;
@property (nonatomic,strong) NSColor *unfocusedColor;

@end
