/*
AJRInspectorModule.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
