
#import "AJRDropShadowBorderInspectorModule.h"

#import "AJRDropShadowBorder.h"

@implementation AJRDropShadowBorderInspectorModule

- (void)update
{
    [shallowCheckBox setState:[(AJRDropShadowBorder *)border isShallow]];
    [clipCheckBox setState:[(AJRDropShadowBorder *)border doesClip]];
    [radiusSlider setFloatValue:[(AJRDropShadowBorder *)border radius]];
    [radiusText setFloatValue:[(AJRDropShadowBorder *)border radius]];    
}

- (void)setIsShallow:(id)sender
{
    [(AJRDropShadowBorder *)border setShallow:[sender state]];
}

- (void)setDoesClip:(id)sender
{
    [(AJRDropShadowBorder *)border setClip:[sender state]];
}

- (void)setRadius:(id)sender
{
    float    radius = [sender intValue];
    
    if (radius < 0.0) radius = 0.0;
    if (radius > 30.0) radius = 30.0;
    [radiusText setFloatValue:radius];
    [radiusSlider setFloatValue:radius];
    [(AJRDropShadowBorder *)border setRadius:radius];
}

@end
