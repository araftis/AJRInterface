/*
NSTabView+Extensions.m
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

#import "NSTabView+Extensions.h"

#import <objc/objc-runtime.h>

@implementation NSTabView (Extensions)

typedef void (*MMActionIMP)(id self, SEL _cmd, id sender);

static MMActionIMP _originalTakeSelectedTabViewItemFrom = NULL;

+ (void)load {
    if (_originalTakeSelectedTabViewItemFrom == NULL) {
        Method	method = class_getInstanceMethod(objc_getClass("NSTabView"), @selector(takeSelectedTabViewItemFromSender:));
        Method	replacement = class_getInstanceMethod(self, @selector(fixed_takeSelectedTabViewItemFromSender:));
        if (method && replacement) {
            _originalTakeSelectedTabViewItemFrom = (MMActionIMP)method_getImplementation(method);
            method_setImplementation(method, method_getImplementation(replacement));
        }
    }
}

- (IBAction)fixed_takeSelectedTabViewItemFromSender:(id)sender {
    if ([sender isKindOfClass:[NSToolbarItem class]]) {
        NSInteger	index = [sender tag];
        if (index >= 0 && index < [self numberOfTabViewItems]) {
            [self selectTabViewItemAtIndex:index];
        }
    } else {
        _originalTakeSelectedTabViewItemFrom(self, _cmd, sender);
    }
}

- (NSUInteger)indexOfSelectedTab {
    return [self indexOfTabViewItem:[self selectedTabViewItem]];
}

@end
