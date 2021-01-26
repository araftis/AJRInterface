
#import "AJRDropShadowRendererInspectorModule.h"

#import "AJRDropShadowRenderer.h"

@implementation AJRDropShadowRendererInspectorModule

- (void)update
{
   [colorWell setColor:[(AJRDropShadowRenderer *)renderer shadowColor]];
}

- (void)setColor:(id)sender
{
   [(AJRDropShadowRenderer *)renderer setShadowColor:[sender color]];
}

@end
