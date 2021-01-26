
#import <AppKit/AppKit.h>

#import <AJRInterface/AJRInterfaceDefines.h>

extern NSString *NSApplicationWillAbnormallyTerminateNotification;
extern NSString *AJRApplicationExceptionKey;

@interface NSApplication (AJRInterfaceExtensions)

- (NSInteger)runFixedModalForWindow: (NSWindow*)theWindow;
- (void)criticallyTerminateWithException:(NSException *)exception;

@end

@interface NSApplication(AJRAppleBugFixes)

- (void)_setCurrentEvent: (NSEvent*)theEvent;

@end

@interface NSObject (AJRApplicationDelegateExtensions)

// This message is sent just prior to the application quiting. You should attempt any clean up that might be possible during a critical failure. Any code you implement should be in it's own exception handler, and it _should_not_ ever raise an exception.
- (void)application:(NSApplication *)application willAbnormallyTerminateWithException:(NSException *)anException;

@end
