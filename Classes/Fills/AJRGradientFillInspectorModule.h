
#import <AJRInterface/AJRFillInspectorModule.h>

@interface AJRGradientFillInspectorModule : AJRFillInspectorModule
{
    NSColorWell        *_colorWell;
    NSColorWell        *_secondaryColorWell;
    NSSlider        *_angleSlider;
    NSTextField        *_angleText;
}

@property (nonatomic,strong) IBOutlet NSColorWell *colorWell;
@property (nonatomic,strong) IBOutlet NSColorWell *secondaryColorWell;
@property (nonatomic,strong) IBOutlet NSSlider *angleSlider;
@property (nonatomic,strong) IBOutlet NSTextField *angleText;

- (IBAction)updateColor:(NSColorWell *)sender;
- (IBAction)updateSecondaryColor:(NSColorWell *)sender;
- (IBAction)updateAngle:(id)sender;

@end
