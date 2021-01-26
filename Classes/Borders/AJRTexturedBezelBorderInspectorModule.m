
#import "AJRTexturedBezelBorderInspectorModule.h"

#import "AJRTexturedBezelBorder.h"

@implementation AJRTexturedBezelBorderInspectorModule

- (void)update
{
    [widthField setFloatValue:[(AJRTexturedBezelBorder *)border width]];
    [radiusField setFloatValue:[(AJRTexturedBezelBorder *)border radius]];
}

- (void)setWidth:(id)sender
{
    float        width = [sender floatValue];
    
    if (width < 1.0) width = 1.0;
    if (width > 10.0) width = 10.0;
    
    [sender setFloatValue:width];
    [(AJRTexturedBezelBorder *)border setWidth:width];
}

- (void)setRadius:(id)sender
{
    float        radius = [sender floatValue];
    
    if (radius < 0.0) radius = 0.0;
    if (radius > 30.0) radius = 30.0;
    
    [sender setFloatValue:radius];
    [(AJRTexturedBezelBorder *)border setRadius:radius];
}

@end
