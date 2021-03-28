
#import "AJRExceptionPanel.h"

#import "AJRReportView.h"
#import "NSBundle+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>

@implementation AJRExceptionPanel

+ (id)exceptionPanelWithException:(NSException *)exception {
    return [[AJRExceptionPanel alloc] initWithException:exception];
}

- (id)initWithException:(NSException *)exception {
    if ((self = [super init])) {
        self.exception = exception;
    }
    return self;
}


@synthesize panel = _panel;
@synthesize titleText = _titleText;
@synthesize messageText = _messageText;
@synthesize exceptionReport = _exceptionReport;
@synthesize exitButton = _exitButton;
@synthesize continueButton = _continueButton;
@synthesize printButton = _printButton;
@synthesize emailButton = _emailButton;
@synthesize exception = _exception;

- (NSInteger)run {
    NSString    *path;
    
    if (_panel == nil) {
        [NSBundle ajr_loadNibNamed:@"AJRExceptionPanel" owner:self];
    }
    [_panel center];

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"AJRExceptionReport" ofType:@"osmreport"];
    if (path) {
        [self.exceptionReport setReportPath:path];
        [self.exceptionReport setRootObject:_exception];
        [self.exceptionReport setEditable:YES];
        AJRPrintf(@"DEBUG: Node: %@", [[[self.exceptionReport mainFrame] DOMDocument] getElementById:@"problemReport"]);
    }
    [self.titleText setStringValue:AJRFormat(@"Uncaught %@", [_exception name])];
    [self.panel makeFirstResponder:self.exceptionReport];
    
    [_panel makeKeyAndOrderFront:self];

    return [NSApp runModalForWindow:_panel];
}

- (IBAction)exitApplication:(id)sender {
    [_panel orderOut:self];
    [NSApp stopModalWithCode:NSAlertFirstButtonReturn];
}

- (IBAction)continueApplication:(id)sender {
    [_panel orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (IBAction)printException:(id)sender {
}

- (IBAction)emailException:(id)sender {
}

@end
