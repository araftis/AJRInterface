//
//  AJRCalendarRenderer.m
//  AJRInterface
//
//  Created by A.J. Raftis on 5/15/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRCalendarRenderer.h"

#import "AJRCalendarEvent.h"
#import "EKEvent+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSMutableArray+Extensions.h>
#import <EventKit/EventKit.h>

@interface NSString (SnowLeopardToBe)

/* 
 This API appears in Snow Leopard, but we test for it, even under Leopard. If it exists, we call it, 
 otherwise we call a known API for both Leopard and Snow Leopard.
 */
- (NSComparisonResult)localizedStandardCompare:(NSString *)string;

@end


@implementation AJRCalendarRenderer

static NSMutableDictionary    *_renderers = nil;
static NSDateFormatter        *_dateFormatter = nil;

#pragma mark Class Initialization

+ (void)initialize {
    if (_renderers == nil) {
        @autoreleasepool {
            _renderers = [[NSMutableDictionary alloc] init];
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setDateFormat:@"yyyyMMdd"];
        }
    }
}

#pragma mark Renderer Management

+ (void)registerCalendarRenderer:(Class)class {
    [_renderers setObject:class forKey:[class name]];
}

+ (NSArray *)rendererNames {
    return [[_renderers allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Class        leftRenderer = [_renderers objectForKey:obj1];
        Class        rightRenderer = [_renderers objectForKey:obj2];
        
        return [leftRenderer approximateTimeSpan] - [rightRenderer approximateTimeSpan];
    }];
}

+ (Class)rendererForName:(NSString *)name {
    return [_renderers objectForKey:name];
}

+ (NSString *)name {
    return @"Name Me";
}

#pragma mark Initialization

- (id)initWithView:(AJRCalendarView *)view {
    if ((self = [super init])) {
        _view = view; // Not retained.
        _eventsByDate = [[NSMutableDictionary alloc] init];
        _dailyEventsByDate = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark Properties

- (NSArray *)events {
    return _events;
}

#pragma mark Calendar Interaction

- (void)rendererDidBecomeActiveInCalendarView:(AJRCalendarView *)calendarView inRect:(NSRect)bounds {
}

- (void)rendererDidBecomeInactiveInCalendarView:(AJRCalendarView *)calendarView inRect:(NSRect)bounds {
}

#pragma mark Geometry

- (NSRect)rectForHeaderInRect:(NSRect)rect {
    return NSZeroRect;
}

- (NSRect)rectForBodyInRect:(NSRect)rect {
    return rect;
}

- (NSRect)rectForDate:(NSDate *)date inRect:(NSRect)rect {
    return NSZeroRect;
}

#pragma mark Configuration

- (BOOL)bodyShouldScroll {
    return NO;
}

#pragma mark Drawing

- (void)drawHeaderInRect:(NSRect)rect bounds:(NSRect)bounds {
}

- (void)drawBodyInRect:(NSRect)rect bounds:(NSRect)bounds {
}

#pragma mark Events

- (void)getEventsStart:(NSDate **)startDate andEnd:(NSDate **)endDate forDate:(NSDate *)date {
    if (startDate) *startDate = nil;
    if (endDate) *endDate = nil;
}

- (NSPredicate *)eventPredicateForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    return [[_view eventStore] predicateForEventsWithStartDate:startDate endDate:endDate calendars:[_view calendars]];
}

- (NSPredicate *)eventPredicateForDate:(NSDate *)date {
    NSDate        *startDate, *endDate;
    
    [self getEventsStart:&startDate andEnd:&endDate forDate:date];
    
    return [self eventPredicateForStartDate:startDate andEndDate:endDate];
}

- (void)clearAllEventHitRectangles {
    [_events makeObjectsPerformSelector:@selector(clearHitRectangles) withObject:nil];
}

- (void)clearEventHitRectangles {
    for (NSString *key in _eventsByDate) {
        [[_eventsByDate objectForKey:key] makeObjectsPerformSelector:@selector(clearHitRectangles) withObject:nil];
    }
}

- (void)clearDailyEventHitRectangles {
    for (NSString *key in _eventsByDate) {
        [[_dailyEventsByDate objectForKey:key] makeObjectsPerformSelector:@selector(clearHitRectangles) withObject:nil];
    }
}

- (void)_buildPeerData {
    NSMutableArray    *slots = [[NSMutableArray alloc] init];
    NSInteger        x;
    
    // Set up our slots
    for (x = 0; x < 97; x++) {
        NSPointerArray        *slotIndex = [[NSPointerArray alloc] init];
        [slots addObject:slotIndex];
    }
    
    // Now loop over each day. Note that it doesn't really matter which day were working on or in
    // what order we compute this data. The important thing is that we only work on one data at a 
    // time and that we process all days.
    for (NSString *key in _eventsByDate) {
        NSArray        *events = [_eventsByDate objectForKey:key];
        
        // Loop over the events, and add the event to each slots into which it belongs
        for (AJRCalendarEvent *event in events) {
            NSInteger    slotStart = [event slotStart];
            NSInteger    slotEnd = [event slotEnd];
            NSInteger    position = 0;
            
            for (x = slotStart; x <= slotEnd; x++) {
                NSPointerArray    *slotIndex = [slots objectAtIndex:x];
                
                if (x == slotStart) {
                    // If were the start slot, find the first non-null entry in the index, or the
                    // last entry.
                    for (position = 0; position < [slotIndex count]; position++) {
                        if ([slotIndex pointerAtIndex:position] == NULL) break;
                    }
                    [event setPeerPosition:position];
                }
                if ([slotIndex count] < position + 1) {
                    // Make sure the slot index has enough room to hold our event.
                    [slotIndex setCount:position + 1];
                }

                [slotIndex replacePointerAtIndex:position withPointer:(__bridge void *)event];
            }
        }
        
        // Loop over the slots and do final computations. This actually does the computation for
        // the number of peers with which the event is sharing.
        for (x = 0; x < 97; x++) {
            NSPointerArray *slotIndex = [slots objectAtIndex:x];
            NSInteger count = [slotIndex count];
            NSInteger y;
            
            for (y = 0; y < count; y++) {
                [(AJRCalendarEvent *)[slotIndex pointerAtIndex:y] setPeerCountIfGreater:count];
            }
        }
        
        // Clear our slotIndexs
        for (x = 0; x < 97; x++) {
            [(NSPointerArray *)[slots objectAtIndex:x] setCount:0];
        }
    }
    
}

- (void)_addRawEvents:(NSArray *)rawEvents {
    for (EKEvent *calEvent in rawEvents) {
        AJRCalendarEvent *event = [[AJRCalendarEvent alloc] initWithEvent:calEvent];
        NSArray *keys = [event dateKeys];
        
        [_events addObject:event];
        for (NSString *key in keys) {
            NSMutableArray *events;
            NSMutableDictionary *index = nil;
            
            // First, special handling if we have an all day event.
            if ([event isAllDay]) {
                index = _dailyEventsByDate;
            } else {
                index = _eventsByDate;
            }
            
            events = [index objectForKey:key];
            if (events == nil) {
                events = [[NSMutableArray alloc] init];
                [index setObject:events forKey:key];
            }
            // Make sure the event is ready to have its peer status computed
            event.peerCount = 0;
            event.peerPosition = 0;
            [events addSortedObject:event usingComparator:^NSComparisonResult(id left, id right) {
                NSComparisonResult result = [[left startDate] compare:[right startDate]];
                if (result == NSOrderedSame) {
                    result = [[left title] localizedStandardCompare:[right title]];
                }
                return result;
            }];
            
            if ([event isAllDay] && [events count] > _maxDailyEvents) {
                _maxDailyEvents = [events count];
            }
        }
        
        // If we did anything with this, it's done by now.
    }
}

- (void)_updateEvents:(id)object {
    [self updateEvents:[object boolValue]];
}

- (void)updateEvents:(BOOL)force {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(_updateEvents:) withObject:[NSNumber numberWithBool:force] waitUntilDone:NO];
        return;
    }
    
    if (force || ![self date:_eventsDate equals:[_view displayDate]]) {
        NSPredicate            *predicate;
        EKEventStore        *store;
        NSDate                *eventsStartDate;
        NSDate                *eventsEndDate;
        
        // Since fetching events can be a little expensive, let's make sure we really want to do
        // this.
        [self getEventsStart:&eventsStartDate andEnd:&eventsEndDate forDate:[_view displayDate]];
        //AJRPrintf(@"%C: updateEvents: start: %@, end: %@, date: %@\n", self, eventsStartDate, eventsEndDate, [_view displayDate], );
        if (force || (![self date:_eventsStartDate equals:eventsStartDate] && ![self date:_eventsEndDate equals:eventsEndDate])) {
            // Save our values.
            _eventsStartDate = eventsStartDate;
            _eventsEndDate = eventsEndDate;
            
            store = [_view eventStore];
            
            _eventsDate = [_view date];
            
            predicate = [self eventPredicateForStartDate:_eventsStartDate andEndDate:_eventsEndDate];
            
            _events = [[NSMutableArray alloc] init];
            
            [_eventsByDate removeAllObjects];
            [_dailyEventsByDate removeAllObjects];
            _maxDailyEvents = 1;

            @try {
                // This can sometimes fail while updating the calendar, especially if the calendar is
                // updating a lot. The failure probably has to do with calendar events being created
                // one a background thread. I'm going to have to fix that.
                [self _addRawEvents:[store eventsMatchingPredicate:predicate]];
            } @catch (NSException *exception) {
                AJRPrintf(@"WARNING: An exception occurred while trying to refresh calendar events: %@\n", exception);
            }
            [self _addRawEvents:[_view temporaryItemsMatchingPredicate:predicate]];
            
            // Now that everything is added, let's build our peer data
            [self _buildPeerData];
        }
    }
}

- (NSArray *)eventsForDate:(NSDate *)date {
    return [_eventsByDate objectForKey:[_dateFormatter stringFromDate:date]];
}

- (NSArray *)dailyEventsForDate:(NSDate *)date {
    return [_dailyEventsByDate objectForKey:[_dateFormatter stringFromDate:date]];
}

- (AJRCalendarEvent *)calendarEventForEvent:(EKEvent *)event {
    for (AJRCalendarEvent *calendarEvent in _events) {
        if ([[event ajr_eventUID] isEqual:[[calendarEvent event] ajr_eventUID]]) {
            return calendarEvent;
        }
    }
    return nil;
}

- (NSDate *)decrementDate:(NSDate *)date {
    return date;
}

- (NSDate *)incrementDate:(NSDate *)date {
    return date;
}

+ (NSInteger)approximateTimeSpan {
    return 0;
}

#pragma mark Date Manipulation

- (BOOL)date:(NSDate *)left equals:(NSDate *)right {
    NSDateComponents    *leftComponents;
    NSDateComponents    *rightComponents;
    
    leftComponents = [[_view calendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:left];
    rightComponents = [[_view calendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:right];
    
    return ([leftComponents day] == [rightComponents day] &&
            [leftComponents month] == [rightComponents month] &&
            [leftComponents year] == [rightComponents year]);
}

- (BOOL)startDate:(NSDate *)start andEndDate:(NSDate *)end occursOnDate:(NSDate *)date {
    NSCalendar            *calendar = [_view calendar];
    NSDateComponents    *startComponents;
    NSDateComponents    *endComponents;
    NSDateComponents    *dateComponents;
    NSInteger            startInt, endInt, dateInt;

    startComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:start];
    endComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:end];
    dateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    startInt = [startComponents year] * 10000 + [startComponents month] * 100 + [startComponents day];
    endInt = [endComponents year] * 10000 + [endComponents month] * 100 + [endComponents day];
    dateInt = [dateComponents year] * 10000 + [dateComponents month] * 100 + [dateComponents day];
    
    // Starts before or on date and ends after or on date.
    return startInt <= dateInt && endInt >= dateInt;
}

- (BOOL)isEvent:(EKEvent *)event allDayOnDate:(NSDate *)date {
    return [event isAllDay] && [self startDate:[event startDate] andEndDate:[event startDate] occursOnDate:date];
}

- (NSRect)rectForItem:(EKCalendarItem *)item {
    for (AJRCalendarEvent *event in _events) {
        if ([[event event] isEqual:item]) {
            return [event firstHitRect];
        }
    }
    
    return NSZeroRect;
}

- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)event
              inHeaderView:(NSView *)headerView {
    if (calendarEvent) *calendarEvent = nil;
    if (date) *date = nil;

    return NSZeroRect;
}

- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)event
                inBodyView:(NSView *)headerView {
    if (calendarEvent) *calendarEvent = nil;
    if (date) *date = nil;

    return NSZeroRect;
}

@end
