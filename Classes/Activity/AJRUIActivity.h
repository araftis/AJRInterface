
#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRActivity.h>

@interface AJRUIActivity : AJRActivity
{
   IBOutlet NSView                *view;
   IBOutlet NSProgressIndicator    *progressView;
   IBOutlet NSTextField            *messageText;
}

@end
