/*
 AJRCalendarEventInspector.m
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

#import "AJRCalendarEventInspector.h"

#import "AJRCalendarItemInspectorController.h"
#import "AJRCalendarView.h"
#import "AJRFlippedView.h"
#import "EKAlarm+Extensions.h"
#import "EKParticipant+Extensions.h"
#import "EKRecurrenceRule+Extensions.h"
#import "NSAttributedString+Extensions.h"
#import "NSImage+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/AJRTranslator.h>
#import <EventKit/EventKit.h>
#import <Collaboration/Collaboration.h>

static const CGFloat AJRValueWidth = 176.0;

@implementation AJRCalendarEventInspector

+ (void)load {
    [AJRCalendarItemInspectorController registerInspector:self];
}

#pragma mark Initialization

- (id)initWithOwner:(AJRCalendarItemInspectorController *)owner {
    if ((self = [super initWithOwner:owner])) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
    }
    return self;
}


#pragma mark Properties


#pragma mark View Setup

- (NSMutableDictionary *)valueAttributes {
    if (_valueAttributes == nil) {
        NSMutableParagraphStyle *style;
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentLeft];
        [style setHyphenationFactor:1.0];
        [style setMaximumLineHeight:13.0];
        
        _valueAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:11.0], NSFontAttributeName,
                           [NSColor blackColor], NSForegroundColorAttributeName,
                           style, NSParagraphStyleAttributeName,
                           nil];
    }
    return _valueAttributes;
}

- (NSTextField *)labelFieldWithString:(NSString *)value y:(CGFloat)y {
    NSTextField *field;
    NSRect frame;
    
    frame = (NSRect){{0.0, y}, {68.0, 13.0}};
    field = [[NSTextField alloc] initWithFrame:frame];
    [field setFont:[NSFont boldSystemFontOfSize:11.0]];
    [field setTextColor:[NSColor colorWithDeviceWhite:0.475 alpha:1.0]];
    [field setAlignment:NSTextAlignmentRight];
    [field setStringValue:value];
    [field setBordered:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:NO];
    [field setFrame:frame];
    
    return field;
}

- (NSTextField *)tokenFieldWithString:(NSString *)value y:(CGFloat)y {
    NSTextField *field;
    NSRect frame;
    
    frame = (NSRect){{72.0, y}, {AJRValueWidth, 13.0}};
    field = [[NSTextField alloc] initWithFrame:frame];
    [field setFont:[NSFont systemFontOfSize:11.0]];
    [field setTextColor:[NSColor blackColor]];
    [field setAlignment:NSTextAlignmentLeft];
    [field setStringValue:value];
    [field setBordered:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:NO];
    [field setFrame:frame];
    
    return field;
}

- (NSTextField *)valueFieldWithString:(NSString *)value wrap:(BOOL)wrap y:(CGFloat)y {
    NSTextField *field;
    NSRect frame;
    NSAttributedString *string;
    NSMutableDictionary *attributes = [self valueAttributes];
    
    string = [[NSAttributedString alloc] initWithString:value attributes:attributes];
    
    frame = (NSRect){{72.0, y}, {AJRValueWidth, 13.0}};
    field = [[NSTextField alloc] initWithFrame:frame];
    [field setFont:[attributes objectForKey:NSFontAttributeName]];
    [field setTextColor:[attributes objectForKey:NSForegroundColorAttributeName]];
    [field setAlignment:[[attributes objectForKey:NSParagraphStyleAttributeName] alignment]];
    [field setAllowsEditingTextAttributes:YES];
    [field setAttributedStringValue:string];
    [field setBordered:NO];
    [field setBezeled:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:YES];
    if (wrap) {
        //AJRPrintf(@"%C: layout: %@\n", self, [field attributedStringValue]);
        frame.size.height = [string ajr_sizeConstrainedToWidth:AJRValueWidth - 4.0].height + 4.0;
    } else {
        [[field cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    [field setFrame:frame];
    
    
    return field;
}

- (NSButton *)valueButtonWithString:(NSString *)value y:(CGFloat)y {
    NSButton *button;
    NSRect frame;
    
    frame = (NSRect){{72.0, y}, {AJRValueWidth, 13.0}};
    button = [[NSButton alloc] initWithFrame:frame];
    [button setFont:[NSFont systemFontOfSize:11.0]];
    [button setAlignment:NSTextAlignmentLeft];
    [button setTitle:value];
    [button setBordered:NO];
    [button setFrame:frame];
    
    return button;
}

- (NSButton *)checkboxWithTitle:(NSString *)value y:(CGFloat)y {
    NSButton *button;
    NSRect frame;
    
    frame = (NSRect){{70.0, y - 3.0}, {18.0, 18.0}};
    button = [[NSButton alloc] initWithFrame:frame];
	[button setButtonType:NSButtonTypeSwitch];
    [button setFont:[NSFont systemFontOfSize:11.0]];
    [[button cell] setControlSize:NSControlSizeMini];
    if ([value length]) {
        [button setTitle:value];
        [button setImagePosition:NSImageLeft];
        [button setAlignment:NSTextAlignmentLeft];
    } else {
        [button setImagePosition:NSImageOnly];
    }
    [button setEnabled:NO];
    [button setFrame:frame];
    
    return button;
}

- (NSButton *)buttonWithTitle:(NSString *)title y:(CGFloat)y {
    NSButton *button;
    NSRect frame;
    
    frame = (NSRect){{[[self view] frame].size.width - 76.0, y}, {66.0, 25.0}};
    button = [[NSButton alloc] initWithFrame:frame];
	[button setButtonType:NSButtonTypeMomentaryLight];
	[button setBezelStyle:NSBezelStyleTexturedRounded];
    [button setTitle:title];
    [button setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [[button cell] setControlSize:NSControlSizeSmall];
    
    return button;
}

- (void)setupView {
    NSView *view = [self view];
    EKEvent *event = (EKEvent *)[self item];
    id control;
    CGFloat y = 0.0;
    EKParticipant *me = nil;
    NSRect frame;
    
    [[[view subviews] copy] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([[event location] length]) {
        control = [self labelFieldWithString:[self valueForKeyPath:@"translator.location"] y:y];
        [view addSubview:control];
        control = [self tokenFieldWithString:[event location] y:y];
        [view addSubview:control];
        y += 29.0;
    }
    
    if ([event startDate] || [event endDate]) {
        if ([event isAllDay]) {
            control = [self labelFieldWithString:[self valueForKeyPath:@"translator.all-day"] y:y];
            [view addSubview:control];
            control = [self checkboxWithTitle:nil y:y];
            [control setState:NSControlStateValueOn];
            [view addSubview:control];
            y += 16.0;
        }
        if ([event startDate]) {
            control = [self labelFieldWithString:[self valueForKeyPath:@"translator.from"] y:y];
            [view addSubview:control];
            control = [self tokenFieldWithString:@"" y:y];
            [control setFormatter:_dateFormatter];
            [control setObjectValue:[event startDate]];
            [view addSubview:control];
            _initialFirstResponder = control;
            y += 16.0;
        }
        if ([event endDate]) {
            control = [self labelFieldWithString:[self valueForKeyPath:@"translator.to"] y:y];
            [view addSubview:control];
            control = [self tokenFieldWithString:@"" y:y];
            [control setFormatter:_dateFormatter];
            [control setObjectValue:[event endDate]];
            [view addSubview:control];
            y += 16.0;
        }
#warning Fix me!
        EKRecurrenceRule *rule = [event hasRecurrenceRules] ? [[event recurrenceRules] firstObject] : nil;
        if (rule) {
            NSString *string = [rule ajr_frequencyString];
            NSString *substring = [rule ajr_frequencyIntervalString];
            
            control = [self labelFieldWithString:[self valueForKeyPath:@"translator.repeat"] y:y];
            [view addSubview:control];
            control = [self valueFieldWithString:string wrap:NO y:y];
            [view addSubview:control];
            y += 16.0;
            if ([substring length]) {
                control = [self valueFieldWithString:substring wrap:YES y:y];
                [view addSubview:control];
                y += [(NSView *)control frame].size.height;
            }
            control = [self labelFieldWithString:[self valueForKeyPath:@"translator.end"] y:y];
            [view addSubview:control];
            control = [self valueFieldWithString:[rule ajr_frequencyEndString] wrap:NO y:y];
            [view addSubview:control];
            y += 16.0;            
        }
        // Put some space betwee us and the next section.
        y += 12.0;
    }
    
    if ([event calendar]) {
        control = [self labelFieldWithString:[self valueForKeyPath:@"translator.calendar"] y:y];
        [view addSubview:control];
        control = [self valueButtonWithString:AJRFormat(@" %@", [[event calendar] title]) y:y];
        [control setImagePosition:NSImageLeft];
        [control setImage:[NSImage ajr_colorSwatch:[[event calendar] color] ofSize:(NSSize){13.0, 9.0}]];
        [view addSubview:control];
        y += 29.0;
    }
    
    if ([[event alarms] count]) {
        for (EKAlarm *alarm in [event alarms]) {
            NSString    *string = [alarm ajr_typeString];
            NSString    *substring = [alarm ajr_typeSubstring];
            NSString    *triggerString = [alarm ajr_triggerString];

            control = [self labelFieldWithString:[self valueForKeyPath:@"translator.alarm"] y:y];
            [view addSubview:control];
            if ([string length]) {
                control = [self valueFieldWithString:string wrap:YES y:y];
                [view addSubview:control];
                y += 16.0;
            }
            if ([substring length]) {
                control = [self valueFieldWithString:substring wrap:YES y:y];
                [view addSubview:control];
                y += 16.0;
            }
            if ([triggerString length]) {
                control = [self valueFieldWithString:triggerString wrap:YES y:y];
                [view addSubview:control];
                y += 16.0;
            }
        }
        y += 12.0;
    }
    
    if ([[event attendees] count]) {
        control = [self labelFieldWithString:[self valueForKeyPath:@"translator.attendees"] y:y];
        [view addSubview:control];
        for (EKParticipant *attendee in [event attendees]) {
            if ([[attendee name] isEqualToString:NSFullUserName()]) {
                me = attendee;
            }
            control = [self valueButtonWithString:AJRFormat(@" %@", [attendee name]) y:y];
            [control setImagePosition:NSImageLeft];
            [control setImage:[attendee statusImage]];
            [view addSubview:control];
            y += 16.0;
        }
        y += 12.0;
    }
    
    if (me) {
        control = [self labelFieldWithString:[self valueForKeyPath:@"translator.my status"] y:y];
        [view addSubview:control];
        control = [self valueButtonWithString:AJRFormat(@" %@", [me name]) y:y];
        [control setImagePosition:NSImageLeft];
        [control setImage:[me statusImage]];
        [view addSubview:control];
        y += 29.0;
    }
    
    if ([event URL]) {
        control = [self labelFieldWithString:[self valueForKeyPath:@"translator.url"] y:y];
        [view addSubview:control];
        control = [self valueFieldWithString:[[event URL] absoluteString] wrap:YES y:y];
        [view addSubview:control];
        y += [(NSView *)control frame].size.height;
    }
    
    if ([event notes]) {
        control = [self labelFieldWithString:[self valueForKeyPath:@"translator.note"] y:y];
        [view addSubview:control];
        control = [self valueFieldWithString:[event notes] wrap:YES y:y];
        [view addSubview:control];
        y += [(NSView *)control frame].size.height;
    }
    
    frame = [view frame];
    frame.size.height = y;// + 16.0;
    [view setFrame:frame];
}

#pragma mark AJRCalendarItemInspector

- (NSView *)view {
    if (_view == nil) {
        _view = [[AJRFlippedView alloc] initWithFrame:(NSRect){NSZeroPoint, {260.0, 10.0}}];
    }
    return _view;
}

- (void)setItem:(EKCalendarItem *)item {
    [super setItem:item];
    [self setupView];
}

- (id)initialFirstResponder {
    return _initialFirstResponder;
}

#pragma mark Inspection

+ (NSUInteger)shouldInspectCalendarItem:(EKCalendarItem *)event {
    if ([event isKindOfClass:[EKEvent class]]) {
        return 100;
    }
    return 0;
}

#pragma mark NSObject-Extensions

- (AJRTranslator *)translator {
    return [AJRTranslator translatorForClass:[AJRCalendarView class]];
}

@end
