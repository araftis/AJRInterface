
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@class AJRInspector;

@interface AJRInspectorModule : NSObject
{
   // view that gets shown
   IBOutlet NSView        *view;

   // "parent" controller.  this pointer is not retained
   AJRInspector            *inspectorController;
}

// The class the inspector inspects. If just one class, it's sufficient to implement this method.
- (Class)inspectedClass;
// returns whether this inspector handles anObject
- (BOOL)canInspectObject:(id)anObject;

- (BOOL)handlesEmptySelection;
- (BOOL)handlesMultipleSelection;

- (NSString *)title;
- (NSImage *)icon;
- (NSView *)view;
- (NSSize)size;

// "parent" controller
- (AJRInspector *)inspectorController;
- (void)setInspectorController:(AJRInspector *)aController;

// items being inspected. You custom subclass will need to override this method to provide the array of objects being inspected.
- (NSArray *)selection;

// gets the items being inspected from the parent controller and
// updates what is displayed.
- (void)update;

- (BOOL)inspectorShouldSwitchView:(AJRInspector *)inspector;

- (void)setObjectValue:(id)aValue withSelector:(SEL)selector;
- (void)setIntValue:(NSInteger)aValue withSelector:(SEL)selector;
- (void)setFloatValue:(float)aValue withSelector:(SEL)selector;
- (void)setBOOLValue:(BOOL)aValue withSelector:(SEL)selector;

- (void)performInvocation:(NSInvocation *)invocation;

@end
