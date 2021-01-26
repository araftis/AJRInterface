
#import "AJRFillRendererInspectorModule.h"

#import "AJRFillRenderer.h"

@implementation AJRFillRendererInspectorModule

- (void)update
{
   [colorWell setColor:[(AJRFillRenderer *)renderer fillColor]];
}

- (void)setColor:(id)sender
{
   [(AJRFillRenderer *)renderer setFillColor:[sender color]];
}

@end
