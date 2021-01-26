//
//  AJRCalendarItemInspector.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/5/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

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
