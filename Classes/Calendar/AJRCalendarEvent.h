//
//  AJRCalendarEvent.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <EventKit/EventKit.h>

extern const NSTimeInterval AJRSecondInterval;
extern const NSTimeInterval AJRMinuteInterval;
extern const NSTimeInterval AJRHourInterval;
extern const NSTimeInterval AJRDayInterval;

@interface AJRCalendarEvent : NSObject 
{
    EKEvent            *_event;
    NSMutableArray    *_hitRects;
    NSMutableArray    *_peers;
    NSTimeInterval    _timeStart;
    NSTimeInterval    _timeEnd;
    NSString        *_displayString;
    
    // Computed values dealing with overlapping events
    NSInteger        _slotStart;
    NSInteger        _slotEnd;
    NSInteger        _peerPosition;
    NSInteger        _peerCount;
}

- (id)initWithEvent:(EKEvent *)event;

@property (nonatomic,strong) EKEvent *event;
@property (nonatomic,readonly) NSArray *hitRects;
@property (nonatomic,readonly) NSArray *peers;
@property (nonatomic,strong) NSString *displayString;
@property (nonatomic,readonly) NSInteger slotStart;
@property (nonatomic,readonly) NSInteger slotEnd;
@property (nonatomic,assign) NSInteger peerPosition;
@property (nonatomic,assign) NSInteger peerCount;

- (BOOL)intersects:(AJRCalendarEvent *)event;
- (BOOL)encompassesDate:(NSDate *)date;
- (NSArray *)dateKeys;

/*!
 @methodgroup Managing Hit Rectangles
 */
- (void)clearHitRectangles;
- (void)addHitRectangle:(NSRect)rect;
- (NSRect)firstHitRect;
- (NSRect)lastHitRect;
- (NSRect)containsPoint:(NSPoint)point;

/*!
 @methodgroup NSCalCalendarItem
 */
- (NSString *)title;
- (EKCalendar *)calendar;

/*!
 @methodgroup NSCalEvent
 */
- (BOOL)isAllDay;
- (NSString *)location;
- (EKRecurrenceRule *)recurrenceRule;
- (NSDate *)startDate;
- (NSDate *)endDate;
- (NSArray *)attendees;
- (BOOL)isDetached;
- (NSDate *)occurrence;

/*!
 @methodgroup Peer computations
 */
- (void)setPeerCountIfGreater:(NSInteger)peerCount;

@end
