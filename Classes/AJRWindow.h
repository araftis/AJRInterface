
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRWindow : NSWindow

- (void)addTargetBypassTo:(id)receiver forAction:(SEL)action;
- (void)removeTargetBypassForAction:(SEL)action;
- (nullable id)targetBypassForAction:(SEL)action defaultTarget:(nullable id)defaultTarget;

- (void)addKeyBypassTo:(id)receiver forKeyCode:(NSInteger)key withModifiers:(NSEventModifierFlags)modifiers;
- (void)removeKeyBypassForKeyCode:(NSInteger)key withModifiers:(NSEventModifierFlags)modifiers;

@end


@protocol AJRKeyDispatchWindow

@optional - (BOOL)keyDownInWindow:(NSEvent *)event;

@end

NS_ASSUME_NONNULL_END
