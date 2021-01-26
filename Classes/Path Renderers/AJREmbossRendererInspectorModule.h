
#import <AJRInterface/AJRPathRendererInspectorModule.h>

@interface AJREmbossRendererInspectorModule : AJRPathRendererInspectorModule
{
   IBOutlet NSColorWell        *colorWell;
   IBOutlet NSColorWell        *highlightColorWell;
   IBOutlet NSColorWell        *shadowColorWell;
   IBOutlet NSTextField        *angleField;
   IBOutlet NSTextField        *widthField;
   IBOutlet NSTextField        *errorField;
}

- (void)setColor:(id)sender;
- (void)setHighlightColor:(id)sender;
- (void)setShadowColor:(id)sender;
- (void)setAngle:(id)sender;
- (void)setWidth:(id)sender;
- (void)setError:(id)sender;

@end
