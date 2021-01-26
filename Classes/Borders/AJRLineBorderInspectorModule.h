
#import <AJRInterface/AJRBorderInspectorModule.h>

@interface AJRLineBorderInspectorModule : AJRBorderInspectorModule
{
    IBOutlet NSColorWell        *colorWell;
    IBOutlet NSTextField        *widthText;
    IBOutlet NSTextField        *radiusText;
    IBOutlet NSSlider            *radiusSlider;
}

- (void)setColor:(id)sender;
- (void)setWidth:(id)sender;
- (void)setRadius:(id)sender;

@end
