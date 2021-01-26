
#import <AJRInterface/AJRPathRendererInspectorModule.h>

@interface AJRHaloRendererInspectorModule : AJRPathRendererInspectorModule
{
   IBOutlet NSColorWell        *colorWell;
   IBOutlet NSTextField        *widthField;
}

- (void)setColor:(id)sender;
- (void)setWidth:(id)sender;

@end
