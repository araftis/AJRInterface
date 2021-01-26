
#import "AJRHaloRendererInspectorModule.h"

#import "AJRHaloRenderer.h"

@implementation AJRHaloRendererInspectorModule

- (void)update
{
   [colorWell setColor:[(AJRHaloRenderer *)renderer haloColor]];
   [widthField setFloatValue:[(AJRHaloRenderer *)renderer width]];
}

- (void)setColor:(id)sender
{
   [(AJRHaloRenderer *)renderer setHaloColor:[sender color]];
}

- (void)setWidth:(id)sender
{
   [(AJRHaloRenderer *)renderer setWidth:[sender floatValue]];
}

@end
