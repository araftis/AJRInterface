//
//  NSMenu-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 2/24/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "NSMenu+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation NSMenu (AJRInterfaceExtensions)

- (NSMenu *)menuWithTag:(NSInteger)tag {
    return [self menuWithTag:tag in:self];
}

- (NSMenu *)menuWithTag:(NSInteger)tag in:(NSMenu *)menu {
    NSMenuItem    *item = [self menuItemWithTag:tag in:menu];
    
    if (item) {
        return [item submenu];
    }
    
    return nil;
}

- (NSMenuItem *)menuItemWithTag:(NSInteger)tag {
    return [self menuItemWithTag:tag in:self];
}

- (NSMenuItem *)menuItemWithTag:(NSInteger)tag in:(NSMenu *)menu {
    for (__strong NSMenuItem *item in [menu itemArray]) {
        if ([item tag] == tag) return item;
        if ([item hasSubmenu]) {
            item = [self menuItemWithTag:tag in:[item submenu]];
            if (item) return item;
        }
    }
    return nil;
}

- (NSMenuItem *)menuItemWithAction:(SEL)action {
    return [self menuItemWithAction:action in:self];
}

- (NSMenuItem *)menuItemWithAction:(SEL)action in:(NSMenu *)menu {
    for (__strong NSMenuItem *item in [menu itemArray]) {
        if ([item action] == action) return item;
        if ([item hasSubmenu]) {
            item = [self menuItemWithAction:action in:[item submenu]];
            if (item) return item;
        }
    }
    return nil;
}

- (NSMenuItem *)itemWithRepresentedObject:(id)object {
    for (NSMenuItem *item in [self itemArray]) {
        if ([item representedObject] == object) {
            return item;
        }
    }
    return nil;
}

- (NSMenuItem *)addItemWithImage:(NSImage *)image action:(SEL)selector keyEquivalent:(NSString *)charCode {
    NSMenuItem *item = [self addItemWithTitle:@"" action:selector keyEquivalent:charCode];
    [item setImage:image];
    return item;
}

- (void)translateWithTranslator:(AJRTranslator *)translator andRecurse:(BOOL)flag {
	for (NSMenuItem *item in [self itemArray]) {
		NSString	*title = [item title];
		NSString    *key = [item translationKey];
		if (key == nil) {
			key = title;
			[item setTranslationKey:key];
		}
		[item setTitle:[translator valueForKey:key]];
		if ([item hasSubmenu]) {
			key = [[item submenu] translationKey];
			if (key == nil) {
				key = [[item submenu] title];
				[[item submenu] setTranslationKey:key];
			}
			[[item submenu] setTitle:[translator valueForKey:key]];
			if (flag) {
				[[item submenu] translateWithTranslator:translator andRecurse:flag];
			}
		}
	}
}

@end
