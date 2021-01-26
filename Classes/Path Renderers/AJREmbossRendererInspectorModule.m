
#import "AJREmbossRendererInspectorModule.h"

#import "AJREmbossRenderer.h"

@implementation AJREmbossRendererInspectorModule

- (void)update
{
   [colorWell setColor:[(AJREmbossRenderer *)renderer color]];
   [highlightColorWell setColor:[(AJREmbossRenderer *)renderer highlightColor]];
   [shadowColorWell setColor:[(AJREmbossRenderer *)renderer shadowColor]];
   [angleField setFloatValue:[(AJREmbossRenderer *)renderer angle]];
   [errorField setFloatValue:[(AJREmbossRenderer *)renderer error]];
   [widthField setFloatValue:[(AJREmbossRenderer *)renderer width]];
}

- (void)setColor:(id)sender
{
   [(AJREmbossRenderer *)renderer setColor:[sender color]];
}

- (void)setHighlightColor:(id)sender
{
   [(AJREmbossRenderer *)renderer setHighlightColor:[sender color]];
}

- (void)setShadowColor:(id)sender
{
   [(AJREmbossRenderer *)renderer setShadowColor:[sender color]];
}

- (void)setAngle:(id)sender
{
   [(AJREmbossRenderer *)renderer setAngle:[sender floatValue]];
}

- (void)setWidth:(id)sender
{
   [(AJREmbossRenderer *)renderer setWidth:[sender floatValue]];
}

- (void)setError:(id)sender
{
   [(AJREmbossRenderer *)renderer setError:[sender floatValue]];
}

@end
