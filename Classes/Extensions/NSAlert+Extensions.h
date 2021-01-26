//
//  NSAlert+Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 5/9/14.
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAlert (AJRInterfaceExtensions)

+ (NSAlert *)ajr_alertWithMessageText:(NSString *)message defaultButton:(nullable NSString *)defaultButton alternateButton:(nullable NSString *)alternateButton otherButton:(nullable NSString *)otherButton informativeTextWithFormat:(NSString *)format, ...;

- (void)setInformativeFormat:(NSString *)format, ...;
- (void)setMessageFormat:(NSString *)format, ...;

- (void)addButtonWithFormat:(NSString *)format, ...;

@end

extern void AJRBeginAlertPanel(NSAlertStyle style, NSString *message, NSString * __nullable button1Title, NSString * __nullable button2Title, NSString * __nullable button3Title, NSWindow * __nullable window, void (^ __nullable handler)(NSModalResponse returnCode));
extern NSInteger AJRRunAlertPanel(NSString *title, NSString *msgFormat, NSString * __nullable defaultButton, NSString * __nullable alternateButton, NSString * __nullable otherButton, ...);


NS_ASSUME_NONNULL_END
