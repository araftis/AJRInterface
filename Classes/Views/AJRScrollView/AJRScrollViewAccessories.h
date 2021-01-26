
#import <AppKit/AppKit.h>

@interface AJRScrollViewAccessories : NSObject
{
    IBOutlet NSPanel        *window;
    IBOutlet NSSlider        *slider;
    IBOutlet NSTextField    *textField;
    IBOutlet NSButton        *okButton;
    IBOutlet NSButton        *cancelButton;
}

+ (id)sharedInstance;

- (NSInteger)runWithPercent:(NSInteger)percent;

- (void)takeIntValueFrom:(id)sender;

- (void)ok:sender;
- (void)cancel:sender;

- (NSInteger)percent;

@end
