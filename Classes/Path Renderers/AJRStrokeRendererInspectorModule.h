
#import <AJRInterface/AJRPathRendererInspectorModule.h>

@interface AJRStrokeRendererInspectorModule : AJRPathRendererInspectorModule
{
   IBOutlet NSColorWell        *colorWell;
   IBOutlet NSTextField        *widthField;
}

- (void)setColor:(id)sender;
- (void)setWidth:(id)sender;

@end
