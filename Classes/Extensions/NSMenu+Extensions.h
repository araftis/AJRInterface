/*
 NSMenu+Extensions.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

- (NSMenuItem *)addItemWithImage:(NSImage *)image action:(SEL _Nullable)selector keyEquivalent:(NSString *)charCode NS_SWIFT_NAME(addItem(withImage:action:keyEquivalent:));

- (void)translateWithTranslator:(AJRTranslator *)translator andRecurse:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
