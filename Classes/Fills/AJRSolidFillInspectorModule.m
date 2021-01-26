
#import "AJRSolidFillInspectorModule.h"

#import "AJRSolidFill.h"

@implementation AJRSolidFillInspectorModule


@synthesize colorWell = _colorWell;

- (void)update
{
    [_colorWell setColor:[(AJRSolidFill *)fill color]];
}

- (IBAction)updateColor:(NSColorWell *)sender
{
    [(AJRSolidFill *)fill setColor:[sender color]];
}

@end
