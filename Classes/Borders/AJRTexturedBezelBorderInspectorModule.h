
#import <AJRInterface/AJRBorderInspectorModule.h>

@interface AJRTexturedBezelBorderInspectorModule : AJRBorderInspectorModule
{
    IBOutlet NSTextField       *widthField;
    IBOutlet NSTextField       *radiusField;
}

- (void)setWidth:(id)sender;
- (void)setRadius:(id)sender;

@end
