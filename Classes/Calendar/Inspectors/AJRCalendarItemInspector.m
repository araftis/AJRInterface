/*
 AJRCalendarItemInspector.m
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

#import "AJRCalendarItemInspector.h"

#import "AJRCalendarView.h"
#import "NSBundle+Extensions.h"

#import <CalendarStore/CalendarStore.h>
#import <AJRFoundation/AJRTranslator.h>

@implementation AJRCalendarItemInspector

#pragma mark Initialization

- (id)initWithOwner:(AJRCalendarItemInspectorController *)owner
{
    if ((self = [super init])) {
        _owner = owner;
    }
    return self;
}


#pragma mark Properties

@synthesize owner = _owner;
@synthesize view = _view;
@synthesize itemController = _itemController;

- (NSView *)view
{
    if (_view == nil) {
        [NSBundle ajr_loadNibNamed:NSStringFromClass([self class]) owner:self];
    }
    return _view;
}

- (NSObjectController *)itemController
{
    if (_itemController == nil) {
        _itemController = [[NSObjectController alloc] init];
    }
    return _itemController;
}

- (void)setItem:(CalCalendarItem *)item
{
    [self.itemController setContent:item];
}

- (EKCalendarItem *)item
{
    return [self.itemController content];
}

- (NSString *)title
{
    if ([[self item] respondsToSelector:@selector(title)]) {
        return [[self item] title];
    }
    return @"Unknown";
}

- (BOOL)isTitleEditable
{
    return NO;
}

- (BOOL)editTitleOnFirstAppearance
{
    return YES;
}

- (void)titleDidChange:(NSString *)title
{
}

- (NSString *)rightButtonTitle
{
    return [[AJRTranslator translatorForClass:[AJRCalendarView class]] valueForKey:@"Done"];
}

- (NSString *)rightButtonKeyEquivalent
{
    return @"";
}

- (BOOL)rightButtonEnabled
{
    return YES;
}

- (id)rightButtonTarget
{
    return [[self view] window];
}

- (SEL)rightButtonAction
{
    return @selector(dismiss:);
}

- (NSString *)middleButtonTitle
{
    return nil;
}

- (NSString *)middleButtonKeyEquivalent
{
    return @"";
}

- (BOOL)middleButtonEnabled
{
    return YES;
}

- (id)middleButtonTarget
{
    return nil;
}

- (SEL)middleButtonAction
{
    return NULL;
}

- (NSString *)leftButtonTitle
{
    return nil;
}

- (NSString *)leftButtonKeyEquivalent
{
    return @"";
}

- (id)leftButtonTarget
{
    return nil;
}

- (SEL)leftButtonAction
{
    return NULL;
}

- (BOOL)leftButtonEnabled
{
    return YES;
}

- (id)initialFirstResponder
{
    return nil;
}

#pragma mark Actions

- (void)dismiss:(id)sender
{
    NSView        *view = [self view];
    NSWindow    *window = [view window];
    NSWindow    *parent = [window parentWindow];
    
    if (parent) {
        [parent removeChildWindow:window];
    }
    [window orderOut:self];
}

#pragma mark Inspection

+ (NSUInteger)shouldInspectCalendarItem:(CalCalendarItem *)event
{
    return 0;
}

@end
