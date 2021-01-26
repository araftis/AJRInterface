
#import "AJRStrokeRendererInspectorModule.h"

#import "AJRStrokeRenderer.h"

@implementation AJRStrokeRendererInspectorModule

- (void)update
{
   [colorWell setColor:[(AJRStrokeRenderer *)renderer strokeColor]];
   [widthField setFloatValue:[(AJRStrokeRenderer *)renderer width]];
}

- (void)setColor:(id)sender
{
   [(AJRStrokeRenderer *)renderer setStrokeColor:[sender color]];
}

- (void)setWidth:(id)sender
{
   [(AJRStrokeRenderer *)renderer setWidth:[sender floatValue]];
}

@end
