
#import "NSAlert+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation NSAlert (AJRInterfaceExtensions)

+ (NSAlert *)ajr_alertWithMessageText:(NSString *)message defaultButton:(NSString *)defaultButton alternateButton:(NSString *)alternateButton otherButton:(NSString *)otherButton informativeTextWithFormat:(NSString *)format, ... {
    NSAlert *alert = [[NSAlert alloc] init];
    va_list ap;

    alert.messageText = message;
    va_start(ap, format);
    alert.informativeText = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if (defaultButton) {
        [alert addButtonWithTitle:defaultButton];
    }
    if (alternateButton) {
        [alert addButtonWithTitle:alternateButton];
    }
    if (otherButton) {
        [alert addButtonWithTitle:otherButton];
    }

    return alert;
}

- (void)setInformativeFormat:(NSString *)format, ... {
    NSString *string;
    va_list ap;
    
    va_start(ap, format);
    string = AJRFormatv(format, ap);
    va_end(ap);
    
    [self setInformativeText:string];
}

- (void)setMessageFormat:(NSString *)format, ... {
    NSString *string;
    va_list ap;
    
    va_start(ap, format);
    string = AJRFormatv(format, ap);
    va_end(ap);
    
    [self setMessageText:string];
}

- (void)addButtonWithFormat:(NSString *)format, ... {
    NSString *string;
    va_list ap;
    
    va_start(ap, format);
    string = AJRFormatv(format, ap);
    va_end(ap);
    
    [self addButtonWithTitle:string];
}

@end

void AJRBeginAlertPanel(NSAlertStyle style, NSString *messageText, NSString *button1Title, NSString *button2Title, NSString *button3Title, NSWindow *window, void (^handler)(NSModalResponse returnCode)) {
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setMessageText:messageText];
    if (button1Title) {
        [alert addButtonWithTitle:button1Title];
    } else {
        [alert addButtonWithTitle:@"OK"];
    }
    if (button2Title) {
        [alert addButtonWithTitle:button2Title];
    }
    if (button3Title) {
        [alert addButtonWithTitle:button3Title];
    }
    [alert setAlertStyle:style];
    
    if (window) {
        [alert beginSheetModalForWindow:window completionHandler:handler];
    } else {
        [alert runModal];
    }
}

NSInteger AJRRunAlertPanel(NSString *title, NSString *msgFormat, NSString *defaultButton, NSString *alternateButton, NSString *otherButton, ...) {
    NSAlert *alert = [[NSAlert alloc] init];
    NSString *message;
    va_list ap;
    
    [alert setMessageText:title];
    
    va_start(ap, otherButton);
    message = [[NSString alloc] initWithFormat:msgFormat arguments:ap];
    va_end(ap);
    [alert setInformativeText:message];
    
    if (defaultButton) {
        [alert addButtonWithTitle:defaultButton];
    } else {
        [alert addButtonWithTitle:@"OK"];
    }
    if (alternateButton) {
        [alert addButtonWithTitle:alternateButton];
    }
    if (otherButton) {
        [alert addButtonWithTitle:otherButton];
    }
    
    return [alert runModal];
}
