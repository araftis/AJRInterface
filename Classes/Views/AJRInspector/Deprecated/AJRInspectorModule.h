/*
 AJRInspectorModule.h
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
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
