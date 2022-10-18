/*
AJRCalendarView.m
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

#import "AJRCalendarView.h"

#import "_AJRCalendarPrintView.h"
#import "AJRCalendarDateChooser.h"
#import "AJRCalendarDayRenderer.h"
#import "AJRCalendarItemInspectorController.h"
#import "AJRCalendarItemInspectorWindow.h"
#import "AJRCalendarMonthRenderer.h"
#import "AJRCalendarQuarterRenderer.h"
#import "AJRCalendarWeekRenderer.h"
#import "AJRCalendarYearRenderer.h"
#import "EKEvent+Extensions.h"

#import <AJRInterface/AJRInterface.h>
#import <EventKit/EventKit.h>

#pragma mark Notifications

NSString *AJRCalendarViewWillChangeSelectionNotification = @"AJRCalendarViewWillChangeSelectionNotification";
NSString *AJRCalendarViewDidChangeSelectionNotification = @"AJRCalendarViewDidChangeSelectionNotification";

NSString *AJRCalendarViewWillSelectEventNotification = @"AJRCalendarViewWillSelectEventNotification";
NSString *AJRCalendarViewDidSelectEventNotification = @"AJRCalendarViewDidSelectEventNotification";

NSString *AJRCalendarViewWillInspectEventNotification = @"AJRCalendarViewWillInspectEventNotification";
NSString *AJRCalendarViewDidInspectEventNotification = @"AJRCalendarViewDidInspectEventNotification";

NSString *AJRCalendarViewWillChangeDateNotification = @"AJRCalendarViewWillChangeDateNotification";
NSString *AJRCalendarViewDidChangeDateNotification = @"AJRCalendarViewDidChangeDateNotification";

NSString *AJRCalendarViewWillChangeRendererNotification = @"AJRCalendarViewWillChangeRendererNotification";
NSString *AJRCalendarViewDidChangeRendererNotification = @"AJRCalendarViewDidChangeRendererNotification";

NSString *AJRCalendarViewWillDeleteEventsNotification = @"AJRCalendarViewWillDeleteEventsNotification";
NSString *AJRCalendarViewDidDeleteEventsNotification = @"AJRCalendarViewDidDeleteEventsNotification";

// Keys used in notification
NSString *AJRCalendarViewEventKey = @"event";
NSString *AJRCalendarViewDateKey = @"date";
NSString *AJRCalendarViewRendererKey = @"renderer";
NSString *AJRCalendarViewEventsKey = @"events";

@interface AJRCalendarView (Private)

/*!
 @methodgroup Event Handling
 */
- (EKEvent *)_calendarEventForEvent:(NSEvent *)event inView:(NSView *)view;
- (void)handleMouseDown:(NSEvent *)event inView:(NSView *)view;
- (void)handleMouseUp:(NSEvent *)event inView:(NSView *)view;
- (void)handleKeyDown:(NSEvent *)event inView:(NSView *)view;
- (NSMenu *)handleMenuForEvent:(NSEvent *)event inView:(NSView *)view;

/*!
 @methodgroup Autosave
 */
- (NSString *)_calendarsAutosaveDefaultsKey;
- (NSString *)_displayModeAutosaveDefaultsKey;
- (void)_saveCalendars;
- (void)_restoreCalendars;
- (void)_restoreDisplayMode;

@end



@interface _AJRCalendarDocumentView : NSView
{
    AJRCalendarView        *_calendarView;
    AJRCalendarRenderer    *_renderer;
}

- (id)initWithFrame:(NSRect)frame calendarView:(AJRCalendarView *)calendarView renderer:(AJRCalendarRenderer *)renderer;

- (void)setRenderer:(AJRCalendarRenderer *)renderer;

@end


@implementation _AJRCalendarDocumentView

#pragma mark Initialization

- (id)initWithFrame:(NSRect)frame calendarView:(AJRCalendarView *)calendarView renderer:(AJRCalendarRenderer *)renderer
{
    if ((self = [super initWithFrame:frame])) {
        _renderer = renderer;
        _calendarView = calendarView;
    }
    return self;
}


#pragma mark NSView

- (void)drawRect:(NSRect)rect
{
    if ([NSGraphicsContext currentContextDrawingToScreen]) {
        // Only draw when drawing to the screen. Our calendar view does something very different
        // when printing.
        [_renderer drawBodyInRect:rect bounds:[self bounds]];
    }
}

#pragma mark Properties

- (void)setRenderer:(AJRCalendarRenderer *)renderer
{
    if (_renderer != renderer) {
        _renderer = renderer;
        [self setNeedsDisplay:YES];
    }
}

#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)event
{
    [_calendarView handleMouseDown:event inView:self];
}

- (void)mouseDragged:(NSEvent *)event
{
}

- (void)mouseUp:(NSEvent *)event
{
    [_calendarView handleMouseUp:event inView:self];
}

- (void)keyDown:(NSEvent *)event
{
    [_calendarView handleKeyDown:event inView:self];
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    return [_calendarView handleMenuForEvent:event inView:self];
}

@end



@implementation AJRCalendarView

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        NSDictionary    *defaults;
        
        _calendar = [NSCalendar currentCalendar];
        _eventStore = [[EKEventStore alloc] init];
        self.displayDate = [NSDate date];
        _backgroundColor = [NSColor textBackgroundColor];
        _selectedBackgroundColor = [[NSColor selectedControlColor] colorWithAlphaComponent:0.5];
        _todayBackgroundColor = [[NSColor selectedControlColor] colorWithAlphaComponent:0.25];
        _gridColor = [NSColor gridColor];
        _font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
        _fontColor = [NSColor colorWithCalibratedWhite:0.2 alpha:1.0];
        _dimmedFontColor = [NSColor disabledControlTextColor];
        _selectedFontColor = [NSColor alternateSelectedControlTextColor];
        _selectedDimmedFontColor = _dimmedFontColor;
        _timeIndicatorColor = [NSColor colorWithCalibratedRed:0.75 green:0.0 blue:0.0 alpha:1.0];
        _calendars = [[NSMutableArray alloc] init];
        _selection = [[NSMutableDictionary alloc] init];
        _renderer = [[[AJRCalendarRenderer rendererForName:@"Month"] alloc] initWithView:self];
        _inspectorController = [[AJRCalendarItemInspectorController alloc] initWithOwner:self];
        _temporaryEvents = [[NSMutableArray alloc] init];
        
        defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.iCal"];
        _firstMinuteOfWorkHours = [defaults integerForKey:@"first minute of work hours" defaultValue:0];
        _lastMinuteOfWorkHours = [defaults integerForKey:@"last minute of work hours" defaultValue:0];
        
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                // Register for various notifications to which we wish to observe
                [center addObserver:self
                           selector:@selector(eventsChanged:)
                               name:EKEventStoreChangedNotification
                             object:self->_eventStore];
                [center addObserver:self
                           selector:@selector(eventsChanged:)
                               name:EKEventStoreChangedNotification
                             object:self->_eventStore];
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark NSNibAwakening

- (void)awakeFromNib
{
    [_inspectorController setParentWindow:[self window]];
    [self _restoreCalendars];
    [self _restoreDisplayMode];
    _awakenedFromNib = YES;
}

#pragma mark Properties

@synthesize calendar = _calendar;
@synthesize date = _date;
@synthesize displayDate = _displayDate;
@synthesize time = _time;
@synthesize renderer = _renderer;

@synthesize backgroundColor = _backgroundColor;
@synthesize selectedBackgroundColor = _selectedBackgroundColor;
@synthesize todayBackgroundColor = _todayBackgroundColor;
@synthesize gridColor = _gridColor;
@synthesize font = _font;
@synthesize fontColor = _fontColor;
@synthesize dimmedFontColor = _dimmedFontColor;
@synthesize selectedFontColor = _selectedFontColor;
@synthesize selectedDimmedFontColor = _selectedDimmedFontColor;
@synthesize timeIndicatorColor = _timeIndicatorColor;

@synthesize managedControl = _managedControl;

@synthesize firstMinuteOfWorkHours = _firstMinuteOfWorkHours;
@synthesize lastMinuteOfWorkHours = _lastMinuteOfWorkHours;

@synthesize target = _target;
@synthesize action = _action;
@synthesize doubleTarget = _doubleTarget;
@synthesize doubleAction = _doubleAction;

@synthesize userInfo = _userInfo;

@synthesize delegate = _delegate;

@synthesize autosaveName = _autosaveName;

@synthesize minimumRefreshInterval = _minimumRefreshInterval;

- (void)setCalendar:(NSCalendar *)calendar
{
    if (_calendar != calendar) {
        _calendar = calendar;
        [self setNeedsDisplay:YES];
    }
}

+ (NSSet *)keyPathsForValuesAffectingTime
{
    return [NSSet setWithObjects:@"date", nil];
}

- (void)setDate:(NSDate *)date
{
    if (_date != date) {
        NSDateComponents    *zero;
        NSDate                *startDate = nil, *endDate = nil;
        
        _time = date;
        
        zero = [_calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_time];
        [zero setHour:0];
        [zero setMinute:0];
        [zero setSecond:0];
        
        _date = [_calendar dateFromComponents:zero];
        
        if (_renderer) {
            [_renderer getEventsStart:&startDate andEnd:&endDate forDate:_displayDate];
            if ([_date isLessThan:startDate] || [_date isGreaterThan:endDate]) {
                [self setDisplayDate:_date];
            }
        }
        
        [self tile];
        [self setNeedsDisplay:YES];
    }
}

- (void)_setDisplayDate:(NSDate *)date
{
    if (_displayDate != date) {
        NSDateComponents    *zero;
        
        zero = [_calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        [zero setHour:0];
        [zero setMinute:0];
        [zero setSecond:0];
        
        _displayDate = [_calendar dateFromComponents:zero];
    }
}

- (void)setDisplayDate:(NSDate *)date
{
    if (_displayDate != date) {
        [self _setDisplayDate:date];
        // Changing the display date changes the current date, although the reverse is not true.
        [self setDate:_displayDate];
    }
}

- (void)setBackgroundColor:(NSColor *)value 
{
    if (_backgroundColor != value) {
        _backgroundColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setSelectedBackgroundColor:(NSColor *)value 
{
    if (_selectedBackgroundColor != value) {
        _selectedBackgroundColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setTodayBackgroundColor:(NSColor *)value 
{
    if (_todayBackgroundColor != value) {
        _todayBackgroundColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setGridColor:(NSColor *)value 
{
    if (_gridColor != value) {
        _gridColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setFont:(NSFont *)value 
{
    if (_font != value) {
        _font = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setFontColor:(NSColor *)value 
{
    if (_fontColor != value) {
        _fontColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setDimmedFontColor:(NSColor *)value 
{
    if (_dimmedFontColor != value) {
        _dimmedFontColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setSelectedFontColor:(NSColor *)value 
{
    if (_selectedFontColor != value) {
        _selectedFontColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setSelectedDimmedFontColor:(NSColor *)value 
{
    if (_selectedDimmedFontColor != value) {
        _selectedDimmedFontColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setTimeIndicatorColor:(NSColor *)value 
{
    if (_timeIndicatorColor != value) {
        _timeIndicatorColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setManagedControl:(NSControl *)managedControl
{
    if (_managedControl != managedControl) {
        //AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
        _managedControl = managedControl;
        if ([_managedControl isKindOfClass:[NSSegmentedControl class]]) {
            [self setupSegmentedControl:(NSSegmentedControl *)_managedControl];
        }
    }
}

- (void)setRenderer:(AJRCalendarRenderer *)renderer
{
    if (_renderer != renderer) {
        if (_renderer) {
            if ([_renderer bodyShouldScroll]) {
                [_renderer rendererDidBecomeInactiveInCalendarView:self inRect:[(NSView *)[[self bodyScrollView] documentView] bounds]];
            } else {
                [_renderer rendererDidBecomeInactiveInCalendarView:self inRect:[self bounds]];
            }
        }
        _renderer = renderer;
        // When a new renderer becomes active, we set the displayDate to the current date, because
        // the new renderer might not be able to display the display date like the current one can.
        // For example, this can commonly happen when switching from a month view to a week view.
        if (![_date isEqualToDate:_displayDate]) {
            [self _setDisplayDate:_date];
        }
        [self tile];
        [self setNeedsDisplay:YES];
        if (_renderer) {
            if ([_renderer bodyShouldScroll]) {
                [_renderer rendererDidBecomeActiveInCalendarView:self inRect:[(NSView *)[[self bodyScrollView] documentView] bounds]];
            } else {
                [_renderer rendererDidBecomeActiveInCalendarView:self inRect:[self bounds]];
            }
        }
    }
}

- (NSMutableDictionary *)userInfo
{
    if (_userInfo == nil) {
        _userInfo = [[NSMutableDictionary alloc] init];
    }
    return _userInfo;
}

- (void)setDelegate:(id)delegate
{
    if (_delegate != delegate) {
        NSNotificationCenter    *center = [NSNotificationCenter defaultCenter];
        if (_delegate) {
            [center removeObserver:_delegate name:AJRCalendarViewDidChangeSelectionNotification object:self];
            [center removeObserver:_delegate name:AJRCalendarViewDidChangeDateNotification object:self];
            [center removeObserver:_delegate name:AJRCalendarViewDidChangeRendererNotification object:self];
            [center removeObserver:_delegate name:AJRCalendarViewDidSelectEventNotification object:self];
            [center removeObserver:_delegate name:AJRCalendarViewDidInspectEventNotification object:self];
            [center removeObserver:_delegate name:AJRCalendarViewDidDeleteEventsNotification object:self];
        }
        
        _delegate = delegate;
        
        if (_delegate) {
            if ([_delegate respondsToSelector:@selector(calendarViewDidChangeSelection:)]) {
                [center addObserver:_delegate selector:@selector(calendarViewDidChangeSelection:) name:AJRCalendarViewDidChangeSelectionNotification object:self];
            }
            if ([_delegate respondsToSelector:@selector(calendarViewDidChangeDate:)]) {
                [center addObserver:_delegate selector:@selector(calendarViewDidChangeDate:) name:AJRCalendarViewDidChangeDateNotification object:self];
            }
            if ([_delegate respondsToSelector:@selector(calendarViewDidChangeRenderer:)]) {
                [center addObserver:_delegate selector:@selector(calendarViewDidChangeRenderer:) name:AJRCalendarViewDidChangeRendererNotification object:self];
            }
            if ([_delegate respondsToSelector:@selector(calendarViewDidSelectEvent:)]) {
                [center addObserver:_delegate selector:@selector(calendarViewDidSelectEvent:) name:AJRCalendarViewDidSelectEventNotification object:self];
            }
            if ([_delegate respondsToSelector:@selector(calendarViewDidInspectEvent:)]) {
                [center addObserver:_delegate selector:@selector(calendarViewDidInspectEvent:) name:AJRCalendarViewDidInspectEventNotification object:self];
            }
        }
    }
}

- (void)setAutosaveName:(NSString *)autosaveName
{
    if (_autosaveName != autosaveName) {
        _autosaveName = autosaveName;
        if (_awakenedFromNib) {
            // Because we only want to do this once we're fully up and initialized. awakeFromNib
            // will do its own thing to make sure our state is restored.
            [self _restoreCalendars];
            [self _restoreDisplayMode];
        }
    }
}

#pragma mark Autosave

- (NSString *)_calendarsAutosaveDefaultsKey
{
    if (_autosaveName == nil) return nil;
    return AJRFormat(@"%@: Calendars", _autosaveName);
}

- (NSString *)_displayModeAutosaveDefaultsKey
{
    if (_autosaveName == nil) return nil;
    return AJRFormat(@"%@: Display Mode", _autosaveName);
}

- (void)_saveCalendars
{
    NSString    *key = [self _calendarsAutosaveDefaultsKey];
    if (key) {
        [[NSUserDefaults standardUserDefaults] setObject:[_calendars valueForKey:@"uid"] forKey:key];
    }
}

- (void)_restoreCalendars
{
    NSString    *key = [self _calendarsAutosaveDefaultsKey];
    BOOL        restoreAll = YES;
    if (key) {
        NSArray    *uids = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
        if (uids) {
            NSMutableArray        *calendars = [[NSMutableArray alloc] init];
            
            for (NSString *uid in uids) {
                EKCalendar    *calendar = [_eventStore calendarWithIdentifier:uid];
                if (calendar) {
                    [calendars addObject:calendar];
                }
            }
            
            [self willChangeValueForKey:@"calendars"];
            _calendars = calendars;
            [self didChangeValueForKey:@"calendars"];
            
            restoreAll = NO;
        }
    }
    
    if (restoreAll) {
        NSArray        *calendars = nil;
        
        if ([_delegate respondsToSelector:@selector(calendarViewNeedsInitialCalendars:)]) {
            calendars = [_delegate calendarViewNeedsInitialCalendars:self];
        } else {
            calendars = [_eventStore calendarsForEntityType:EKEntityTypeEvent];
        }
        // By default, the calendar will display everything.
        [self willChangeValueForKey:@"calendars"];
        _calendars = [calendars mutableCopy];
        [self didChangeValueForKey:@"calendars"];
    }
}

- (void)_restoreDisplayMode
{
    NSString    *key = [self _displayModeAutosaveDefaultsKey];
    
    if (key) {
        NSString            *name = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (name) {
            AJRCalendarRenderer    *renderer = [[[AJRCalendarRenderer rendererForName:name] alloc] initWithView:self];
            
            if (renderer) {
                [self setRenderer:renderer];
                if ([self.managedControl isKindOfClass:[NSSegmentedControl class]]) {
                    [(NSSegmentedControl *)self.managedControl setSelected:YES forSegment:[[AJRCalendarRenderer rendererNames] indexOfObject:[[_renderer class] name]] + 1];
                }
            }
        }
    }
}

#pragma mark NSView

- (void)drawRect:(NSRect)rect
{
    NSRect        bounds = [self bounds];
    NSRect        headerBounds = bounds;
    NSRect        headerRect;
    
    if ([_renderer bodyShouldScroll]) {
        headerBounds.size.width = [[self bodyScrollView] documentVisibleRect].size.width;
    }
    headerRect = [_renderer rectForHeaderInRect:headerBounds];
    
    if (headerRect.size.height != 0.0) {
        [[self backgroundColor] set];
        NSRectFill(bounds);
        [_renderer drawHeaderInRect:rect bounds:headerRect];
        
        headerRect.size.width = bounds.size.width;
        
        headerRect.origin.y -= 4.0;
        headerRect.size.height = 4.0;
        [[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] set];
        //[[NSColor redColor] set];
        NSFrameRect(headerRect);
        
        headerRect.origin.y += 1.0;
        headerRect.size.height = 1.0;
        //[[NSColor blueColor] set];
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
        NSFrameRect(headerRect);
        
        headerRect.origin.y += 1.0;
        //[[NSColor greenColor] set];
        [[NSColor colorWithCalibratedWhite:0.91 alpha:1.0] set];
        NSFrameRect(headerRect);
    }
    if (![_renderer bodyShouldScroll]) {
        [_renderer drawBodyInRect:rect bounds:[self bounds]];
    }
}

- (void)setFrame:(NSRect)frame
{
    NSScrollView    *scrollView;
    
    [super setFrame:frame];
    scrollView = [self bodyScrollView];
    if (scrollView) {
        _AJRCalendarDocumentView    *document = [scrollView documentView];
        NSRect                    frame = [document frame];
        frame.size.width = [scrollView documentVisibleRect].size.width;
        frame.size.height = [_renderer rectForBodyInRect:[self bounds]].size.height;
        [document setFrame:frame];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)window
{
    [_inspectorController dismiss:self];
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    return [self handleMenuForEvent:event inView:self];
}

#pragma mark Actions

- (IBAction)goToToday:(id)sender
{
    self.displayDate = [NSDate date];
}

- (void)dateChooserDidEnd:(AJRCalendarDateChooser *)chooser returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSModalResponseOK) {
        self.displayDate = [chooser date];
    }
}

- (IBAction)goToDate:(id)sender
{
    AJRCalendarDateChooser    *chooser = [[AJRCalendarDateChooser alloc] init];
    
    [chooser beginDateChooserForDate:[self displayDate] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(dateChooserDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (IBAction)incrementDate:(id)sender
{
    self.displayDate = [_renderer incrementDate:self.time];
}

- (IBAction)decrementDate:(id)sender
{
    self.displayDate = [_renderer decrementDate:self.time];
}

- (IBAction)viewByDay:(id)sender
{
    [self selectRendererNamed:@"Day"];
}

- (IBAction)viewByWeek:(id)sender
{
    [self selectRendererNamed:@"Week"];
}

- (IBAction)viewByMonth:(id)sender
{
    [self selectRendererNamed:@"Month"];
}

- (IBAction)performControlAction:(id)sender
{
    NSString            *name;
    
    if ([sender isKindOfClass:[NSSegmentedControl class]]) {
        NSUInteger    segment = [sender selectedSegment];
        
        if (segment == 0) {
            [self decrementDate:sender];
            [sender setSelected:YES forSegment:[[AJRCalendarRenderer rendererNames] indexOfObject:[[_renderer class] name]] + 1];
            return;
        } else if (segment == [sender segmentCount] - 1) {
            [self incrementDate:sender];
            [sender setSelected:YES forSegment:[[AJRCalendarRenderer rendererNames] indexOfObject:[[_renderer class] name]] + 1];
            return;
        }
        name = [[AJRCalendarRenderer rendererNames] objectAtIndex:[sender selectedSegment] - 1];
    } else {
        name = [[sender selectedCell] stringValue];
    }

    [self selectRendererNamed:name];
}

- (IBAction)takeDateFromStringValue:(id)sender
{
    self.displayDate = [[sender stringValue] dateValue];
}

- (IBAction)takeDateFromTimeIntervalValue:(id)sender
{
    self.displayDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[sender floatValue]];
}

- (IBAction)takeDateFromEpochValue:(id)sender
{
    self.displayDate = [NSDate dateWithTimeIntervalSince1970:[sender floatValue] / 1000.0];
}

#pragma mark Subviews

- (NSScrollView *)bodyScrollView
{
    return [[self subviews] lastObject];
}

- (void)tile
{
    NSScrollView    *scrollView = [self bodyScrollView];
    NSRect            bounds = [self bounds];
    NSRect            bodyRect, headerRect;
    
    if ([_renderer bodyShouldScroll]) {
        if (!scrollView) {
            _AJRCalendarDocumentView    *document;
            
            scrollView = [[NSScrollView alloc] initWithFrame:(NSRect){{0,0},{100,100}}];
            [self addSubview:scrollView];
            [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [scrollView setHasVerticalScroller:YES];
            [scrollView setHasHorizontalScroller:NO];

            bodyRect.origin.x = 0.0;
            bodyRect.origin.y = 0.0;
            bodyRect.size.width = [scrollView documentVisibleRect].size.width;
            bodyRect.size.height = [_renderer rectForBodyInRect:[self bounds]].size.height;
            document = [[_AJRCalendarDocumentView alloc] initWithFrame:bodyRect calendarView:self renderer:_renderer];
            [scrollView setDocumentView:document];
        }
    } else {
        if (scrollView) {
            [scrollView removeFromSuperview];
        }
    }
    
    if (scrollView) {
        _AJRCalendarDocumentView    *document = [scrollView documentView];
        NSRect                    frame = [document frame];

        [document setRenderer:_renderer];

        headerRect = [_renderer rectForHeaderInRect:[self bounds]];
        bodyRect.origin.x = bounds.origin.x;
        bodyRect.origin.y = bounds.origin.y;
        bodyRect.size.width = bounds.size.width;
        bodyRect.size.height = bounds.size.height - (headerRect.size.height + 4.0);
        [scrollView setFrame:bodyRect];

        frame.size.height = [_renderer rectForBodyInRect:[self bounds]].size.height;
        frame.size.width = [scrollView documentVisibleRect].size.width;
        [document setFrame:frame];
    }
}

#pragma mark Display

- (void)selectRendererNamed:(NSString *)name
{
    AJRCalendarRenderer    *renderer = [[[AJRCalendarRenderer rendererForName:name] alloc] initWithView:self];
    if (renderer) {
        [self selectRenderer:renderer];
        // Done, so nuke it.
    }
}

- (void)selectRenderer:(AJRCalendarRenderer *)renderer
{
    if ([_delegate respondsToSelector:@selector(calendarView:willChangeRenderer:)] &&
        ![_delegate calendarView:self willChangeRenderer:_renderer]) {
        return;
    }
    
    // If the delegate approved of the change, go ahead and notify anyone else who cares.
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewWillChangeRendererNotification object:self userInfo:[NSDictionary dictionaryWithObject:renderer forKey:AJRCalendarViewRendererKey]];
    // And save the choice to user defaults, if appropriate.
    if ([self autosaveName]) {
        [[NSUserDefaults standardUserDefaults] setObject:[[renderer class] name] forKey:[self _displayModeAutosaveDefaultsKey]];
    }
    [self setRenderer:renderer];
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewDidChangeRendererNotification object:self userInfo:[NSDictionary dictionaryWithObject:renderer forKey:AJRCalendarViewRendererKey]];
    
    if (_managedControl && [_managedControl isKindOfClass:[NSSegmentedControl class]]) {
        NSInteger    index = [[AJRCalendarRenderer rendererNames] indexOfObject:[[renderer class] name]];
        if (index != NSNotFound) {
            [(NSSegmentedControl *)_managedControl setSelectedSegment:index + 1];
        }
    }
}

- (void)setupSegmentedControl:(NSSegmentedControl *)control
{
    NSArray *renderers = [AJRCalendarRenderer rendererNames];
    NSInteger max = [renderers count];
    NSDictionary *attributes;
    NSRect frame = [control frame];
    NSUInteger mask;
    
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName, nil];
    
    [control setSegmentCount:max + 2];
    [control setLabel:@"" forSegment:0];
    [control setImage:[NSImage imageNamed:NSImageNameGoLeftTemplate] forSegment:0];
    [control setWidth:26.0 forSegment:0];
    for (NSInteger x = 0; x < max; x++) {
        NSString    *label = [[self translator] valueForKey:[renderers objectAtIndex:x]];
        [control setLabel:label forSegment:x + 1];
        [control setImage:nil forSegment:x + 1];
        [control setWidth:[label sizeWithAttributes:attributes].width + 20.0 forSegment:x + 1];
        if ([label isEqualToString:[[_renderer class] name]]) {
            [control setSelected:YES forSegment:x + 1];
        }
    }
    [control setLabel:@"" forSegment:max + 1];
    [control setImage:[NSImage imageNamed:NSImageNameGoRightTemplate] forSegment:max + 1];
    [control setWidth:26.0 forSegment:max + 1];
    [control sizeToFit];
    
    [control setTarget:self];
    [control setAction:@selector(performControlAction:)];
    
    mask = [control autoresizingMask];
    if (mask & NSViewMinXMargin && mask & NSViewMaxXMargin) {
        NSRect    newFrame = [control frame];
        newFrame.origin.x = newFrame.origin.x - rint((newFrame.size.width - frame.size.width) / 2.0);
        [control setFrame:newFrame];
    } else if (mask & NSViewMinXMargin) {
        NSRect    newFrame = [control frame];
        newFrame.origin.x = newFrame.origin.x - (newFrame.size.width - frame.size.width);
        [control setFrame:newFrame];
    } else if (mask & NSViewMaxXMargin) {
    }

    [[control cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
    
    /*
    for (NSInteger x = 0; x < max + 2; x++) {
        NSSegmentedCell    *cell = [control cellAtIndex:x];
        AJRPrintf(@"%C: %@/%@/%.1f: %@\n", self,
                 [control labelForSegment:x],
                 [control imageForSegment:x],
                 [control widthForSegment:x],
                 cell);        
    }
     */
}

- (void)_showInspectorForItem:(EKCalendarItem *)item
{
    [self showInspectorForItem:item];
}

- (void)showInspectorForItem:(EKCalendarItem *)item
{
    NSRect        where;

    if ([self needsDisplay]) {
        // This means we might need to layout our events again, so it's pointless to get the 
        // event's hit rectangles. Thus, delay the event until later.
        [self performSelector:@selector(_showInspectorForItem:) withObject:item afterDelay:0.1];
        return;
    }
    
    where = [_renderer rectForItem:item];
    if (!NSEqualRects(where, NSZeroRect)) {
        NSView        *view = nil;
//        NSPoint        point;
        
        if ([item isKindOfClass:[EKEvent class]] && [(EKEvent *)item isAllDay]) {
            view = self;
        } else {
            if ([_renderer bodyShouldScroll]) {
                view = [[self bodyScrollView] documentView];
            } else {
                view = self;
            }
        }
        
        if (view) {
            where.origin = [[self window] ajr_convertPointToScreen:[view convertRect:where toView:nil].origin];
//            point.x = NSMidX(where);
//            point.y = NSMidY(where);
            [_inspectorController setParentWindow:[self window]];
            [_inspectorController inspectItem:item inRect:where];
        }
    }
}

#pragma mark Calendars

- (void)setCalendars:(NSArray *)calendars
{
    _calendars = [calendars mutableCopy];
    [_renderer updateEvents:YES];
    [self tile];
    [self setNeedsDisplay:YES];
    [self _saveCalendars];
}

- (NSArray *)calendars
{
    return _calendars;
}

- (void)addCalendar:(EKCalendar *)calendar
{
    if (![_calendars containsObject:calendar]) {
        [self willChangeValueForKey:@"calendars"];
        [_calendars addObject:calendar];
        [_renderer updateEvents:YES];
        [self tile];
        [self setNeedsDisplay:YES];
        [self _saveCalendars];
        [self didChangeValueForKey:@"calendars"];
    }
}

- (void)removeCalendar:(EKCalendar *)calendar
{
    if ([_calendars containsObject:calendar]) {
        [self willChangeValueForKey:@"calendars"];
        [_calendars removeObject:calendar];
        [_renderer updateEvents:YES];
        [self setNeedsDisplay:YES];
        [self tile];
        [self _saveCalendars];
        [self didChangeValueForKey:@"calendars"];
    }
}

- (BOOL)isDisplayingCalendar:(EKCalendar *)calendar
{
    for (EKCalendar *myCalendar in _calendars) {
        if ([[myCalendar calendarIdentifier] isEqualToString:[calendar calendarIdentifier]]) return YES;
    }
    return NO;
}

#pragma mark Temporary Items

/*!
 @methodgroup Temporary items
 */
- (NSArray *)temporaryItems
{
    return _temporaryEvents;
}

- (NSArray *)temporaryItemsMatchingPredicate:(NSPredicate *)predicate
{
    return [_temporaryEvents filteredArrayUsingPredicate:predicate];
}

- (void)addTemporaryItem:(EKCalendarItem *)item
{
    if (![_temporaryEvents containsObject:item]) {
        [_temporaryEvents addObject:item];
        [_renderer updateEvents:YES];
        [self setNeedsDisplay:YES];
    }
}

- (void)removeTemporaryItem:(EKCalendarItem *)item
{
    if ([_temporaryEvents containsObject:item]) {
        [_temporaryEvents removeObject:item];
        [_renderer updateEvents:YES];
        [self setNeedsDisplay:YES];
    }
}

- (void)removeAllTempoaryItems
{
    if ([_temporaryEvents count]) {
        [_temporaryEvents removeAllObjects];
        [_renderer updateEvents:YES];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark Selection

- (NSArray *)selection
{
    return [_selection allValues];
}

- (void)clearSelection
{
    if ([_selection count]) {
        [_selection removeAllObjects];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)isEventSelected:(EKEvent *)event
{
    return [_selection objectForKey:[event ajr_eventUID]] != nil;
}

- (void)selectEvent:(EKEvent *)event byExtendingSelection:(BOOL)flag;
{
    if (!flag) {
        [self clearSelection];
    }
    if (event) {
        [_selection setObject:event forKey:[event ajr_eventUID]];
        [self setNeedsDisplay:YES];
    }
}

- (void)showSelection
{
    if ([_selection count]) {
        for (NSString *uid in _selection) {
            EKEvent    *event = [_selection objectForKey:uid];
            [self setDate:[event startDate]];
        }
    }
}

- (BOOL)inspectEvent:(EKEvent *)event
{
//    NSPoint            point;
    AJRCalendarEvent    *calendarEvent;
    
    [self selectEvent:event byExtendingSelection:NO];
    if ([_selection count]) {
        calendarEvent = [_renderer calendarEventForEvent:event];
        if (calendarEvent) {
            NSView            *view;
            NSRect            where = [calendarEvent firstHitRect];

            if ([_renderer bodyShouldScroll]) {
                view = [event isAllDay] ? self : [[self bodyScrollView] documentView];
            } else {
                view = self;
            }
            
            // Notify anyone who cares
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewWillInspectEventNotification object:self];
            
            // Figure out where the event needs to be inspected.
            where.origin = [[self window] ajr_convertPointToScreen:[view convertRect:where toView:nil].origin];
//            point.x = NSMidX(where);
//            point.y = NSMidY(where);
            // And have our inspector controller do its thing.
            [_inspectorController setParentWindow:[self window]];
            [_inspectorController inspectItem:[calendarEvent event] inRect:where];
            
            // Notify the world that we're now inspecting something.
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewDidInspectEventNotification object:self];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark Event Handling

- (EKEvent *)_calendarEventForEvent:(NSEvent *)event inView:(NSView *)view
{
    AJRCalendarEvent    *calendarEvent;
    NSDate            *date; // Might want to eventually do something with this.
    NSRect            where;
    NSRect            headerRect = [_renderer rectForHeaderInRect:[self bounds]];

    if (view == self) {
        if (headerRect.size.height != 0.0) {
            where = [_renderer getCalendarEvent:&calendarEvent andDate:&date forEvent:event inHeaderView:view];
        }
        
        if (![_renderer bodyShouldScroll]) {
            where = [_renderer getCalendarEvent:&calendarEvent andDate:&date forEvent:event inBodyView:view];
        }
    } else {
        where = [_renderer getCalendarEvent:&calendarEvent andDate:&date forEvent:event inBodyView:view];
    }
    
    return [calendarEvent event];
}

- (void)handleMouseDown:(NSEvent *)event inView:(NSView *)view
{
    AJRCalendarEvent        *calendarEvent = nil;
    NSDate                *date = nil;
    NSRect                headerRect = [_renderer rectForHeaderInRect:[self bounds]];
    BOOL                shift = ([event modifierFlags] & NSEventModifierFlagShift) != 0;
    NSRect                where;
    BOOL                dismissInspector = YES;

    [[self window] makeFirstResponder:self];
    
    // This might get reset to YES below.
    _sendDoubleAction = NO;
    
    if (view == self) {
        if (headerRect.size.height != 0.0) {
            where = [_renderer getCalendarEvent:&calendarEvent andDate:&date forEvent:event inHeaderView:view];
        }
        
        if (![_renderer bodyShouldScroll]) {
            where = [_renderer getCalendarEvent:&calendarEvent andDate:&date forEvent:event inBodyView:view];
        }
    } else {
        where = [_renderer getCalendarEvent:&calendarEvent andDate:&date forEvent:event inBodyView:view];
    }

    if (calendarEvent) {
        if ([event clickCount] == 2) {
            // Give the delegate the change to interfere.
            if ([_delegate respondsToSelector:@selector(calendarView:willInspectEvent:)] && 
                ![_delegate calendarView:self willInspectEvent:[calendarEvent event]]) {
                // Do noting.
            } else {
                [self inspectEvent:[calendarEvent event]];
                dismissInspector = NO;
            }
        } else {
            // Give the delegate a chance to block the selection change
            if ([_delegate respondsToSelector:@selector(calendarView:willSelectEvent:)] && 
                ![_delegate calendarView:self willInspectEvent:[calendarEvent event]]) {
                // Do nothing.
            } else {
                if ([_delegate respondsToSelector:@selector(calendarViewWillChangeSelection:)] &&
                    ![_delegate calendarViewWillChangeSelection:self]) {
                    // Still do nothing.
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewWillSelectEventNotification object:self userInfo:[NSDictionary dictionaryWithObject:[calendarEvent event] forKey:AJRCalendarViewEventKey]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewWillChangeSelectionNotification object:self];
                    [self selectEvent:[calendarEvent event] byExtendingSelection:shift];
                    _sendSingleAction = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewDidSelectEventNotification object:self userInfo:[NSDictionary dictionaryWithObject:[calendarEvent event] forKey:AJRCalendarViewEventKey]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewDidChangeSelectionNotification object:self];
                }
            }
        }
    } else {
        if ([_delegate respondsToSelector:@selector(calendarViewWillChangeSelection:)] &&
            ![_delegate calendarViewWillChangeSelection:self]) {
            // Still do nothing.
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewWillChangeSelectionNotification object:self];
            [self selectEvent:nil byExtendingSelection:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewDidChangeSelectionNotification object:self];
        }
    }
    
    if (date) {
        if (![date isEqualToDate:_date] && dismissInspector) {
            [_inspectorController dismiss:self];
        }
        if (calendarEvent == nil) {
            if ([event clickCount] == 2) {
                _sendDoubleAction = YES;
            } else {
                _sendSingleAction = YES;
            }
        }
        if ([_delegate respondsToSelector:@selector(calendarView:willChangeDate:)] &&
            ![_delegate calendarView:self willChangeDate:date]) {
            // Do nothing.
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewWillChangeDateNotification object:self userInfo:[NSDictionary dictionaryWithObject:date forKey:AJRCalendarViewDateKey]];
            [self setDate:date];
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRCalendarViewDidChangeDateNotification object:self userInfo:[NSDictionary dictionaryWithObject:date forKey:AJRCalendarViewDateKey]];
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)handleMouseUp:(NSEvent *)event inView:(NSView *)view
{
    if (_sendSingleAction) {
        _sendSingleAction = NO;
        if (_action) {
            [NSApp sendAction:_action to:_target from:self];
        }
    }
    if (_sendDoubleAction) {
        _sendDoubleAction = NO;
        if (_doubleAction) {
            [NSApp sendAction:_doubleAction to:_doubleTarget from:self];
        }
    }
}

- (void)handleKeyDown:(NSEvent *)event inView:(NSView *)view
{
    if ([event keyCode] == 51 || [event keyCode] == 117) {
        NSNotificationCenter    *center = [NSNotificationCenter defaultCenter];
        NSMutableArray            *deletingSelection = [[NSMutableArray alloc] initWithCapacity:[_selection count]];
        NSMutableArray            *deleted = [[NSMutableArray alloc] initWithCapacity:[_selection count]];
        NSError                    *error;
        
        deletingSelection = [[_selection allValues] mutableCopy];
        
        if ([_delegate respondsToSelector:@selector(calendarView:willDeleteEvents:)] && 
            ![_delegate calendarView:self willDeleteEvents:deletingSelection]) {
            // Do nothing.
        } else {
            [center postNotificationName:AJRCalendarViewWillDeleteEventsNotification object:self userInfo:[NSDictionary dictionaryWithObject:deletingSelection forKey:AJRCalendarViewEventsKey]];
            
            for (EKEvent *event in deletingSelection) {
                // Let the calendar store remove the event.
                [_eventStore removeEvent:event span:EKSpanFutureEvents | EKSpanThisEvent commit:YES error:&error];
                if (error) {
                    AJRPrintf(@"Unable to remove event: %@: %@", event, [error localizedDescription]);
                } else {
                    // Record what we actually deleted.
                    [deleted addObject:event];
                    // And if we succeed, then remove the event from our selection.
                    [_selection removeObjectForKey:[event ajr_eventUID]];
                }
            }

            if ([_delegate respondsToSelector:@selector(calendarView:didDeleteEvents:)]) {
                [_delegate calendarView:self didDeleteEvents:[deleted valueForKeyPath:@"event"]];
            }
            [center postNotificationName:AJRCalendarViewDidDeleteEventsNotification object:self userInfo:[NSDictionary dictionaryWithObject:[deleted valueForKeyPath:@"event"] forKey:AJRCalendarViewEventsKey]];
        }
        
    }
}

- (NSMenu *)handleMenuForEvent:(NSEvent *)event inView:(NSView *)view
{
    EKEvent    *calendarEvent = [self _calendarEventForEvent:event inView:view];
    
    if (calendarEvent && [_delegate respondsToSelector:@selector(calendarView:wantsMenuForCalendarEvent:)]) {
        return [_delegate calendarView:self wantsMenuForCalendarEvent:calendarEvent];
    }
    
    return nil;
}

#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)event
{
    [self handleMouseDown:event inView:self];
}

- (void)mouseDragged:(NSEvent *)event
{
}

- (void)mouseUp:(NSEvent *)event
{
    [self handleMouseUp:event inView:self];
}

- (void)keyDown:(NSEvent *)event
{
    [self handleKeyDown:event inView:self];
}

#pragma mark CalCalendarStore Notifications

- (void)eventsChanged:(NSNotification *)notification
{
    if (_minimumRefreshInterval == 0 || 
        ([NSDate timeIntervalSinceReferenceDate] - _lastRefresh > _minimumRefreshInterval)) {
        [_renderer updateEvents:YES];
        [self setNeedsDisplay:YES];
        _lastRefresh = [NSDate timeIntervalSinceReferenceDate];
    }
}
#pragma mark Printing

- (void)setupPrintInfo:(NSPrintInfo *)printInfo
{
    if ([_renderer bodyShouldScroll]) {
        [printInfo setOrientation:NSPaperOrientationPortrait];
    } else {
        [printInfo setOrientation:NSPaperOrientationLandscape];
    }
    [printInfo setVerticallyCentered:NO]; // Don't vertically center the content on the page
    [printInfo setHorizontalPagination:NSPrintingPaginationModeFit]; // Fit content horizontally onto a single page width
    [printInfo setVerticalPagination:NSPrintingPaginationModeFit]; // Fit content horizontally onto a single page width
    [printInfo setTopMargin:36.0];
    [printInfo setBottomMargin:36.0];
    [printInfo setLeftMargin:36.0];
    [printInfo setRightMargin:36.0];
}

- (NSView *)calendarPrintView
{
    if (_calendarPrintView == nil) {
        NSWindow                *window = [[NSWindow alloc] initWithContentRect:(NSRect){NSZeroPoint, {10, 10}} styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
        
        //[window orderFront:self];
        _calendarPrintView = [[_AJRCalendarPrintView alloc] initWithRenderer:_renderer];
        [window setContentView:_calendarPrintView];
    } else {
        [_calendarPrintView setRenderer:_renderer];
    }
    
    return _calendarPrintView;
}

@end
