
#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRUniqueObject.h>

@interface AJROptionalAlertPanel : AJRUniqueObject
{
    IBOutlet NSPanel    *panel;
    IBOutlet NSTextView    *messageText;
    IBOutlet NSButton    *defaultButton;
    IBOutlet NSButton    *alternateButton;
    IBOutlet NSButton    *otherButton;
    IBOutlet NSButton    *optionButton;
    
    NSString            *defaultsName;
    CGFloat                maxWidth;
    NSRect                origTextFrame;
    NSRect                origContentRect;
    CGFloat                buttonMargin;
    CGFloat                buttonSpacing;
    CGFloat                buttonY;
    CGFloat                minButtonWidth;
    CGFloat                buttonHeight;
}

+ (id)sharedInstance;

- (NSInteger)runModalWithTitle: (NSString*)title message: (NSString*)message defaultReturnValue: (NSInteger)defaultReturnValue defaultsName: (NSString*)theDefaultsName defaultButton: (NSString*)defaultButtonTitle alternateButton: (NSString*)alternateButtonTitle otherButton: (NSString*)otherButtonTitle;

- (IBAction)defaultButtonPushed: (id)sender;
- (IBAction)alternateButtonPushed: (id)sender;
- (IBAction)otherButtonPushed: (id)sender;

- (IBAction)optionButtonPushed: (id)sender;

@end
