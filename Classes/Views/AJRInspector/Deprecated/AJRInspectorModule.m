
#import "AJRInspectorModule.h"
#import "AJRInspector.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRInspectorModule

- (Class)inspectedClass {
    return Nil;
}

- (BOOL)canInspectObject:(id)anObject {
    Class class = [self inspectedClass];
    
    if (class != Nil) {
        return [anObject isKindOfClass:class];
    }
    
    return NO;
}

- (BOOL)handlesEmptySelection {
    return NO;
}

- (BOOL)handlesMultipleSelection {
    return NO;
}

- (NSString *)title {
    return nil;
}

- (NSImage *)icon {
    NSImage *icon = [NSImage imageNamed:NSStringFromClass([self class])];
    
    if (!icon) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:NSStringFromClass([self class]) ofType:@"tiff"];
        
        if (path) {
            icon = [[NSImage allocWithZone:nil] initWithContentsOfFile:path];
        }
        
        if (!icon) {
            bundle = [NSBundle bundleForClass:[AJRInspectorModule class]];
            path = [bundle pathForResource:@"AJRInspectorIcon" ofType:@"tiff"];
            if (path) {
                icon = [[NSImage allocWithZone:nil] initWithContentsOfFile:path];
            }
        }
    }
    
    return icon;
}

- (NSView *)view {
    NSView *aView = nil;
    NSArray *selection = [self selection];
    NSInteger index;
    
    if (!view) {
        // load nib
        if (![[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self topLevelObjects:NULL]) {
            AJRPrintf(@"WARNING: Unable to load nib %@", [self class]);
        }
    }
    
    // see if inspector handles at least one of the objects
    for (index = 0; (index < [selection count]) && !aView; index++) {
        id object = [selection objectAtIndex:index];
        
        if ([self canInspectObject:object]) {
            aView = view;
        }
    }
    
    if (!aView) {
        // inspector does not handle any of the objects.  see how many
        // objects there are
        if ([selection count] > 1) {
            // multiple objects
            if (![self handlesMultipleSelection]) aView = [[self inspectorController] multipleSelectionView];
            else aView = view;
        } else {
            // zero or one object
            if (![self handlesEmptySelection]) aView = [[self inspectorController] emptySelectionView];
            else aView = view;
        }
    }
    
    return aView;
}

- (NSSize)size {
    return [[self view] frame].size;
}

- (AJRInspector *)inspectorController {
    return inspectorController;
}

- (void)setInspectorController:(AJRInspector *)aController {
    // This value is not being retained to prevent a retain loop.
    // The inspector controller has its inspectors retained in an array.
    inspectorController = aController;
}

- (NSArray *)selection {
    return [NSArray array];
}

- (void)update {
}

- (BOOL)inspectorShouldSwitchView:(AJRInspector *)inspector {
    return YES;
}

- (void)setObjectValue:(id)aValue withSelector:(SEL)selector {
    NSMethodSignature *signature = [[self inspectedClass] instanceMethodSignatureForSelector:selector];
    __unsafe_unretained id retypedValue = aValue;
    
    if (signature) {
        NSInvocation *invocation;
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setArgument:&retypedValue atIndex:2];
        [invocation setSelector:selector];
        [self performInvocation:invocation];
    }
}

- (void)setIntValue:(NSInteger)aValue withSelector:(SEL)selector {
    NSMethodSignature *signature = [[self inspectedClass] instanceMethodSignatureForSelector:selector];
    
    if (signature) {
        NSInvocation *invocation;
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setArgument:&aValue atIndex:2];
        [invocation setSelector:selector];
        [self performInvocation:invocation];
    }
}

- (void)setFloatValue:(float)aValue withSelector:(SEL)selector {
    NSMethodSignature *signature = [[self inspectedClass] instanceMethodSignatureForSelector:selector];
    
    if (signature) {
        NSInvocation *invocation;
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setArgument:&aValue atIndex:2];
        [invocation setSelector:selector];
        [self performInvocation:invocation];
    }
}

- (void)setBOOLValue:(BOOL)aValue withSelector:(SEL)selector {
    NSMethodSignature *signature = [[self inspectedClass] instanceMethodSignatureForSelector:selector];
    
    if (signature) {
        NSInvocation *invocation;
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setArgument:&aValue atIndex:2];
        [invocation setSelector:selector];
        [self performInvocation:invocation];
    }
}

- (void)performInvocation:(NSInvocation *)invocation {
    NSArray *selection = [self selection];
    NSInteger x;
    
    for (x = 0; x < (const NSInteger)[selection count]; x++) {
        NSObject *anObject = [selection objectAtIndex:x];
        
        if ([self canInspectObject:anObject]) {
            [invocation invokeWithTarget:anObject];
        }
    }
}

@end
