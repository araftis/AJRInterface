
#import <AJRInterface/AJRFillInspectorModule.h>

@interface AJRSolidFillInspectorModule : AJRFillInspectorModule
{
    NSColorWell        *_colorWell;
}

@property (nonatomic,strong) IBOutlet NSColorWell *colorWell;

- (IBAction)updateColor:(NSColorWell *)sender;

@end
