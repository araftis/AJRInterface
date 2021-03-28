
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRTranslator;

@interface NSMenu (AJRInterfaceExtensions)

- (nullable NSMenu *)menuWithTag:(NSInteger)tag;
- (nullable NSMenu *)menuWithTag:(NSInteger)tag in:(NSMenu *)menu;
- (nullable NSMenuItem *)menuItemWithTag:(NSInteger)tag;
- (nullable NSMenuItem *)menuItemWithTag:(NSInteger)tag in:(NSMenu *)menu;
- (nullable NSMenuItem *)menuItemWithAction:(SEL)action;
- (nullable NSMenuItem *)menuItemWithAction:(SEL)action in:(NSMenu *)menu;

- (NSMenuItem *)itemWithRepresentedObject:(id)object;

- (NSMenuItem *)addItemWithImage:(NSImage *)image action:(SEL _Nullable)selector keyEquivalent:(NSString *)charCode;

- (void)translateWithTranslator:(AJRTranslator *)translator andRecurse:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
