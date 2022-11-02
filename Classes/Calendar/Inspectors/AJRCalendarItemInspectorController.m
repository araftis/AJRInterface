/*
 AJRCalendarItemInspectorController.m
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

#import "AJRCalendarItemInspectorController.h"

#import "AJRCalendarEventInspector.h"
#import "AJRCalendarItemInspectorWindow.h"
#import "NSWindow+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>

static NSMutableDictionary    *_inspectorsIndex = nil;
static NSArray                *_inspectorKeysToObserve = nil;

@implementation AJRCalendarItemInspectorController

#pragma mark NSObject

+ (void)initialize {
    if (_inspectorKeysToObserve == nil) {
        _inspectorKeysToObserve = [[NSArray alloc] initWithObjects:@"rightButtonTitle", @"rightButtonKeyEquivalent", @"rightButtonTarget", @"rightButtonAction", @"rightButtonEnabled", @"middleButtonTitle", @"middleButtonKeyEquivalent", @"middleButtonTarget", @"middleButtonAction", @"middleButtonEnabled", @"leftButtonTitle", @"leftButtonKeyEquivalent", @"leftButtonTarget", @"leftButtonAction", @"leftButtonEnabled", @"isTitleEditable", @"title", nil];
        
    }
}

#pragma mark Managing Inspectors

+ (void)registerInspector:(Class)inspectorClass {
    @autoreleasepool {
        if (_inspectorsIndex == nil) {
            _inspectorsIndex = [[NSMutableDictionary alloc] init];
        }
        [_inspectorsIndex setObject:inspectorClass forKey:NSStringFromClass(inspectorClass)];
    }
}

+ (Class)inspectorClassForCalendarItem:(EKCalendarItem *)item {
    NSUInteger    weight = 0;
    Class        chosenClass = Nil;
    
    for (NSString *key in _inspectorsIndex) {
        Class        class = [_inspectorsIndex objectForKey:key];
        NSUInteger    instanceWeight = [class shouldInspectCalendarItem:item];
        
        if (instanceWeight > weight) {
            weight = instanceWeight;
            chosenClass = class;
        }
    }
    
    return chosenClass;
}

#pragma mark Initialization

- (id)initWithOwner:(AJRCalendarView *)calendarView {
    if ((self = [super init])) {
        _owner = calendarView;
        _inspectors = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_window orderOut:self];
}

#pragma mark Properties

@synthesize parentWindow = _parentWindow;
@synthesize window = _window;
@synthesize inspector = _inspector;

- (AJRCalendarView *)owner {
    return _owner;
}

- (AJRCalendarItemInspectorWindow *)window {
    if (_window == nil) {
        _window = [[AJRCalendarItemInspectorWindow alloc] initWithScreenLocation:(NSPoint){100.0,100.0}];
        [_window setDelegate:self];
    }
    return _window;
}

- (void)setParentWindow:(NSWindow *)parentWindow {
    if (_parentWindow != parentWindow) {
        if (_window) {
            if ([_window parentWindow]) {
                [[_window parentWindow] removeChildWindow:_window];
            }
        }
        _parentWindow = parentWindow;
        if (_window) {
            [_parentWindow addChildWindow:_window ordered:NSWindowAbove];
        }
    }
}

#pragma mark Actions

- (IBAction)dismiss:(id)sender {
    if ([_window isVisible] && [_window parentWindow] != nil) {
        [_inspector dismiss:sender];
    }
}

- (void)inspectItem:(EKCalendarItem *)item inRect:(NSRect)rect {
//    NSRect finalFrame;
    Class inspectorClass;
    AJRCalendarItemInspector *inspector;
    
    //AJRPrintf(@"INFO: Examinging calendar item: %@", item);
    
    [self window];
    
    inspectorClass = [[self class] inspectorClassForCalendarItem:item];
    if (inspectorClass) {
        NSString *key = NSStringFromClass(inspectorClass);
        
        inspector = [_inspectors objectForKey:key];
        if (inspector == nil) {
            inspector = [(AJRCalendarItemInspector *)[inspectorClass alloc] initWithOwner:self];
            [_inspectors setObject:inspector forKey:key];
        }
        if (_inspector) {
            for (NSString *key in _inspectorKeysToObserve) {
                @try {
                    [_inspector removeObserver:self forKeyPath:key];
                } @catch (NSException *exception) { /* We don't care if this fails */ }
            }
        }
        _inspector = inspector;
    }
    if (_inspector) {
        [_inspector setItem:item];
        [_window setDocumentView:[_inspector view]];
        // Fire off a bunch of fake observer notifications, which will get us set up correctly.
        [self observeValueForKeyPath:@"title" ofObject:_inspector change:nil context:NULL];
        [self observeValueForKeyPath:@"rightButtonTitle" ofObject:_inspector change:nil context:NULL];
        [self observeValueForKeyPath:@"rightButtonKeyEquivalent" ofObject:_inspector change:nil context:NULL];
        [self observeValueForKeyPath:@"middleButtonTitle" ofObject:_inspector change:nil context:NULL];
        [self observeValueForKeyPath:@"middleButtonKeyEquivalent" ofObject:_inspector change:nil context:NULL];
        [self observeValueForKeyPath:@"leftButtonTitle" ofObject:_inspector change:nil context:NULL];
        [self observeValueForKeyPath:@"leftButtonKeyEquivalent" ofObject:_inspector change:nil context:NULL];
        if ([_inspector editTitleOnFirstAppearance]) {
            [self observeValueForKeyPath:@"isTitleEditable" ofObject:_inspector change:nil context:NULL];
        } else {
            [_window makeFirstResponder:nil];
            [[_window titleField] setEditable:[_inspector isTitleEditable]];
        }
        [_window pointToRect:rect];
//        finalFrame = [_window frame];
        //[_window setFrame:(NSRect){point, NSZeroSize} display:NO];
//        if (_parentWindow) {
//            [_parentWindow addChildWindow:_window ordered:NSWindowAbove];
//        }
//        [_window orderFront:self];
//        [_window setFrame:finalFrame display:YES animate:YES];
//        [_window setFrame:finalFrame display:YES];
        [_window setEventualParent:_parentWindow];
        [_window popup];
        //[_window orderFrontWithTransition:AJRWindowZoomTransitionEffect fromRect:(NSRect){point, NSZeroSize} duration:1.0 onScreen:[NSScreen mainScreen]];
        for (NSString *key in _inspectorKeysToObserve) {
            [_inspector addObserver:self forKeyPath:key options:0 context:NULL];
        }
    }
}

#pragma mark NSWindowDelegate

- (void)windowDidCompletePopAnimation:(NSWindow *)window {
    // We fake this one more time, because the pop animation messes with our configuration.
    if ([_inspector editTitleOnFirstAppearance]) {
        [self observeValueForKeyPath:@"isTitleEditable" ofObject:_inspector change:nil context:NULL];
    } else {
        [_window makeFirstResponder:nil];
        [[_window titleField] setEditable:[_inspector isTitleEditable]];
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //AJRPrintf(@"%C: observe: %@\n", self, keyPath);
    if ([keyPath hasPrefix:@"right"]) {
        [_window setButtonTitle:[_inspector rightButtonTitle]
                  keyEquivalent:[_inspector rightButtonKeyEquivalent]
                        enabled:[_inspector rightButtonEnabled]
                         target:[_inspector rightButtonTarget]
                         action:[_inspector rightButtonAction]
                    forLocation:AJRButtonRight];
    } else if ([keyPath hasPrefix:@"middle"]) {
        [_window setButtonTitle:[_inspector middleButtonTitle]
                  keyEquivalent:[_inspector middleButtonKeyEquivalent]
                        enabled:[_inspector middleButtonEnabled]
                         target:[_inspector middleButtonTarget]
                         action:[_inspector middleButtonAction]
                    forLocation:AJRButtonMiddle];
    } else if ([keyPath hasPrefix:@"left"]) {
        [_window setButtonTitle:[_inspector leftButtonTitle]
                  keyEquivalent:[_inspector leftButtonKeyEquivalent]
                        enabled:[_inspector leftButtonEnabled]
                         target:[_inspector leftButtonTarget]
                         action:[_inspector leftButtonAction]
                    forLocation:AJRButtonLeft];
    } else if ([keyPath isEqualToString:@"isTitleEditable"]) {
        NSTextField    *titleField = [_window titleField];
        
        if ([_inspector isTitleEditable]) {
            [titleField setEditable:YES];
            [titleField setNextKeyView:[_inspector initialFirstResponder]];
            [_window makeFirstResponder:titleField];
            [_window becomeKeyWindow];
        } else {
            [titleField setEditable:NO];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        [_window setTitle:[_inspector title]]; 
    }
}

#pragma mark NSWindow Notifications

- (void)windowDidResignKey:(NSNotification *)notification {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    //AJRPrintf(@"%C:    application active: %B\n", self, [NSApp isActive]);
    
    if ([NSApp isActive]) {
        [self dismiss:self];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
}

#pragma mark NSApplication Notifications

- (void)dismissIfNotKey {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    //AJRPrintf(@"%C:    key? %B\n", self, [NSApp keyWindow] == _window);
    if ([NSApp keyWindow] != _window) {
        [self dismiss:self];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    [self performSelector:@selector(dismissIfNotKey) withObject:nil afterDelay:0.0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

@end
