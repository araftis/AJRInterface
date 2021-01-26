
#import <AJRInterface/AJRBorderInspectorModule.h>

@interface AJRDropShadowBorderInspectorModule : AJRBorderInspectorModule
{
   IBOutlet NSButton        *shallowCheckBox;
   IBOutlet NSButton        *clipCheckBox;
   IBOutlet NSSlider        *radiusSlider;    
   IBOutlet NSTextField        *radiusText;
}

- (void)setIsShallow:(id)sender;
- (void)setDoesClip:(id)sender;
- (void)setRadius:(id)sender;


@end
