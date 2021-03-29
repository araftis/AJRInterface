/*
NSMenu+Extensions.m
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
