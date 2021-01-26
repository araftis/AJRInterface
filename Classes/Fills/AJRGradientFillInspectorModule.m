
#import "AJRGradientFillInspectorModule.h"

#import "AJRGradientFill.h"

@implementation AJRGradientFillInspectorModule


@synthesize colorWell = _colorWell;
@synthesize secondaryColorWell = _secondaryColorWell;
@synthesize angleSlider = _angleSlider;
@synthesize angleText = _angleText;

- (void)update
{
    [_colorWell setColor:[(AJRGradientFill *)fill color]];
    [_secondaryColorWell setColor:[(AJRGradientFill *)fill secondaryColor]];
    [_angleText setFloatValue:[(AJRGradientFill *)fill angle]];
    [_angleSlider setFloatValue:[(AJRGradientFill *)fill angle]];
}

- (IBAction)updateColor:(NSColorWell *)sender
{
    [(AJRGradientFill *)fill setColor:[sender color]];
}

- (IBAction)updateSecondaryColor:(NSColorWell *)sender
{
    [(AJRGradientFill *)fill setSecondaryColor:[sender color]];
}

- (void)updateAngle:(id)sender
{
    [(AJRGradientFill *)fill setAngle:[sender floatValue]];
    [_angleText setFloatValue:[sender floatValue]];
    [_angleSlider setFloatValue:[sender floatValue]];
}

@end
