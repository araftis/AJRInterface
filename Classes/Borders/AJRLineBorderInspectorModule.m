
#import "AJRLineBorderInspectorModule.h"

#import "AJRLineBorder.h"

@implementation AJRLineBorderInspectorModule

- (void)update
{
    [colorWell setColor:[(AJRLineBorder *)border color]];
    [widthText setFloatValue:[(AJRLineBorder *)border width]];
    [radiusText setFloatValue:[(AJRLineBorder *)border radius]];
    [radiusSlider setFloatValue:[(AJRLineBorder *)border radius]];
}

- (void)setColor:(id)sender
{
    [(AJRLineBorder *)border setColor:[sender color]];
}

- (void)setWidth:(id)sender
{
    float    width = [sender floatValue];
    
    if (width < 1.0) width = 1.0;
    if (width > 20.0) width = 20.0;
    [sender setFloatValue:width];
    [(AJRLineBorder *)border setWidth:width];
}

- (void)setRadius:(id)sender
{
    float    radius = [sender intValue];
    
    if (radius < 0.0) radius = 0.0;
    if (radius > 30.0) radius = 30.0;
    [radiusText setFloatValue:radius];
    [radiusSlider setFloatValue:radius];
    [(AJRLineBorder *)border setRadius:radius];
}

@end
