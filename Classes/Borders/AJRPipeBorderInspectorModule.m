
#import "AJRPipeBorderInspectorModule.h"

#import "AJRPipeBorder.h"

@implementation AJRPipeBorderInspectorModule


@synthesize colorWell = _colorWell;
@synthesize radiusText = _radiusText;
@synthesize radiusSlider = _radiusSlider;

- (void)update
{
    [self.colorWell setColor:[(AJRPipeBorder *)border color]];
    [self.radiusText setFloatValue:[(AJRPipeBorder *)border radius]];
    [self.radiusSlider setFloatValue:[(AJRPipeBorder *)border radius]];
}

- (void)setColor:(id)sender
{
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [(AJRPipeBorder *)border setColor:[sender color]];
}

- (void)setRadius:(id)sender
{
    float        radius = [sender floatValue];
    
    if (radius < 0.0) radius = 0.0;
    if (radius > 30.0) radius = 30.0;
    
    [sender setFloatValue:radius];
    [(AJRPipeBorder *)border setRadius:radius];

    [self.radiusText setFloatValue:[(AJRPipeBorder *)border radius]];
    [self.radiusSlider setFloatValue:[(AJRPipeBorder *)border radius]];
}

@end
