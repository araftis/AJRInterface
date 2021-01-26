//
//  AJRCalendarEvent.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRCalendarEvent.h"

#import <AJRFoundation/AJRFormat.h>

const NSTimeInterval AJRSecondInterval = 1.0;
const NSTimeInterval AJRMinuteInterval = 1.0 * 60.0;
const NSTimeInterval AJRHourInterval = 1.0 * 60.0 * 60.0;
const NSTimeInterval AJRDayInterval = 1.0 * 60.0 * 60.0 * 24.0;

@implementation AJRCalendarEvent

static NSDateFormatter        *_dateFormatter = nil;
static NSDateFormatter        *_dateTimeFormatter = nil;

+ (void)initialize
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyyMMdd"];
        _dateTimeFormatter = [[NSDateFormatter alloc] init];
        [_dateTimeFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    }
}

#pragma mark Initialization

- (id)initWithEvent:(EKEvent *)event
{
    if ((self = [super init])) {
        NSDateComponents    *components;
        NSInteger            hour;
        NSInteger            minute;

        self.event = event;
        _hitRects = [[NSMutableArray alloc] init];
        _peers = [[NSMutableArray alloc] init];

        components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[_event startDate]];
        hour = [components hour];
        // Produces values 0-3, for each 15 minute interval.
        minute = (NSInteger)round((double)[components minute] / 15.0);        
        _slotStart = hour * 4 + minute;

        components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[_event endDate]];
        hour = [components hour];
        // Produces values 0-3, for each 15 minute interval.
        minute = (NSInteger)round((double)[components minute] / 15.0);        
        _slotEnd = hour * 4 + minute;
    }
    return self;
}



#pragma mark Properties

@synthesize event = _event;
@synthesize hitRects = _hitRects;
@synthesize peers = _peers;
@synthesize displayString = _displayString;
@synthesize slotStart = _slotStart;
@synthesize slotEnd = _slotEnd;
@synthesize peerPosition = _peerPosition;
@synthesize peerCount = _peerCount;

- (void)setEvent:(EKEvent *)event
{
    if (_event != event) {
        _event = event;
        
        _timeStart = [[event startDate] timeIntervalSinceReferenceDate];
        _timeEnd = [[event endDate] timeIntervalSinceReferenceDate];
    }
}

#pragma mark Hit Detection

- (BOOL)intersects:(AJRCalendarEvent *)event
{
    if ((_timeStart >= event->_timeStart) && (_timeStart <= event->_timeEnd)) return YES;
    if ((_timeEnd >= event->_timeStart) && (_timeEnd <= event->_timeEnd)) return YES;
    if ((event->_timeStart >= _timeStart) && (event->_timeStart <= _timeEnd)) return YES;
    if ((event->_timeEnd >= _timeStart) && (event->_timeEnd <= _timeEnd)) return YES;
    
    return NO;
}

- (BOOL)encompassesDate:(NSDate *)date
{
    NSTimeInterval    interval = [date timeIntervalSinceReferenceDate];
    
    return (interval >= _timeStart) && (interval <= _timeEnd);
}

- (BOOL)occursOnDate:(NSDate *)date
{
    NSInteger            startInt = floor(_timeStart / AJRDayInterval);
    NSInteger            endInt = ceil(_timeEnd / AJRDayInterval);
    NSInteger            dateInt = round([date timeIntervalSinceReferenceDate] / AJRDayInterval);
    
    // Starts before or on date and ends after or on date.
    return startInt <= dateInt && endInt >= dateInt;
}

- (NSArray *)dateKeys
{
    NSCalendar            *calendar = [NSCalendar currentCalendar];
    NSDate                *date = [_event startDate];
    NSDateComponents    *components;
    NSDateComponents    *rangeComponents;
    NSDateComponents    *adder;
    NSInteger            days;
    NSInteger            index;
    NSMutableArray        *keys;
    
    rangeComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:[_event startDate] toDate:[_event endDate] options:0];

    days = [rangeComponents day];
    keys = [[NSMutableArray alloc] init];
    if (days == 0) {
        [keys addObject:[_dateFormatter stringFromDate:date]];
    } else {
        adder = [[NSDateComponents alloc] init];
        [adder setDay:1];
        
        for (index = 0; index < days; index++) {
            components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:date];
            
            [keys addObject:AJRFormat(@"%04d%02d%02d", [components year], [components month], [components day])];
            
            date = [calendar dateByAddingComponents:adder toDate:date options:0];
        }
        
    }
    
    return keys;
}

#pragma mark Managing Hit Rectangles

- (void)clearHitRectangles
{
    [_hitRects removeAllObjects];
}

- (void)addHitRectangle:(NSRect)rect
{
    NSValue    *last = [_hitRects lastObject];
    
    if (last) {
        NSRect    lastRect = [last rectValue];
        if (lastRect.origin.y == rect.origin.y && lastRect.size.height == rect.size.height) {
            rect = NSUnionRect(rect, lastRect);
            [_hitRects replaceObjectAtIndex:[_hitRects count] - 1 withObject:[NSValue valueWithRect:rect]];
            return;
        }
    }
    [_hitRects addObject:[NSValue valueWithRect:rect]];
}

- (NSRect)firstHitRect
{
    NSValue    *first = [_hitRects count] > 0 ? [_hitRects objectAtIndex:0] : nil;
    
    if (first) {
        return [first rectValue];
    }
    
    return NSZeroRect;
}

- (NSRect)lastHitRect
{
    NSValue    *last = [_hitRects lastObject];
    
    if (last) {
        return [last rectValue];
    }
    
    return NSZeroRect;
}

- (NSRect)containsPoint:(NSPoint)point
{
    for (NSValue *value in _hitRects) {
        NSRect    rect = [value rectValue];
        
        if (NSPointInRect(point, rect)) {
            return rect;
        }
    }
    return NSZeroRect;
}

#pragma mark CalCalendarItem

- (NSString *)title
{
    return [_event title];
}

- (EKCalendar *)calendar
{
    return [_event calendar];
}

#pragma mark CalEvent

- (BOOL)isAllDay
{
    return [_event isAllDay];
}

- (NSString *)location
{
    return [_event location];
}

- (EKRecurrenceRule *)recurrenceRule
{
#warning Fix me!
    return [_event hasRecurrenceRules] ? [[_event recurrenceRules] firstObject] : nil;
}

- (NSDate *)startDate
{
    return [_event startDate];
}

- (NSDate *)endDate
{
    return [_event endDate];
}

- (NSArray *)attendees
{
    return [_event attendees];
}

- (BOOL)isDetached
{
    return [_event isDetached];
}

- (NSDate *)occurrence
{
    return [_event occurrenceDate];
}

#pragma mark NSObject

- (NSString *)description
{
    return AJRFormat(@"<%C: %p: %@ %@[%@ to %@]>", self, self, [_event title], [_event isAllDay] ? @"All Day " : @"", [_dateTimeFormatter stringFromDate:[_event startDate]], [_dateTimeFormatter stringFromDate:[_event endDate]]);
}

#pragma mark Peer computations

- (void)setPeerCountIfGreater:(NSInteger)peerCount
{
    if (peerCount > _peerCount) {
        _peerCount = peerCount;
    }
}

@end
