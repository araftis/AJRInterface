
#import <AJRInterface/AJRPathRendererInspectorModule.h>

@interface AJRDropShadowRendererInspectorModule : AJRPathRendererInspectorModule
{
   IBOutlet NSColorWell        *colorWell;
}

- (void)setColor:(id)sender;

@end
