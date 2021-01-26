//
//  NSTabView-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 4/3/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

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
