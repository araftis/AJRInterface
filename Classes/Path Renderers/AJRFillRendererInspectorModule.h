
#import <AJRInterface/AJRPathRendererInspectorModule.h>

@interface AJRFillRendererInspectorModule : AJRPathRendererInspectorModule
{
   IBOutlet NSColorWell        *colorWell;
}

- (void)setColor:(id)sender;

@end
