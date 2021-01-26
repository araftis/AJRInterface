
#import <AJRInterface/AJRBorderInspectorModule.h>

@interface AJRPipeBorderInspectorModule : AJRBorderInspectorModule
{
    NSColorWell        *_colorWell;
    NSTextField        *_radiusText;
    NSSlider        *_radiusSlider;
}

@property (nonatomic,strong) IBOutlet NSColorWell *colorWell;
@property (nonatomic,strong) IBOutlet NSTextField *radiusText;
@property (nonatomic,strong) IBOutlet NSSlider *radiusSlider;

- (IBAction)setColor:(id)sender;
- (IBAction)setRadius:(id)sender;

@end
