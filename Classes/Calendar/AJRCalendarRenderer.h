/*
AJRCalendarRenderer.h
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

#import <AJRInterface/AJRCalendarView.h>

@class EKEvent;

@interface AJRCalendarRenderer : NSObject 
{
    AJRCalendarView        *_view;
    NSDate                *_eventsDate;
    NSDate                *_eventsStartDate;
    NSDate                *_eventsEndDate;
    NSMutableArray        *_events;
    NSMutableDictionary    *_eventsByDate;
    NSMutableDictionary    *_dailyEventsByDate;
    NSUInteger            _maxDailyEvents;
}

+ (void)registerCalendarRenderer:(Class)class;
+ (NSArray *)rendererNames;
+ (Class)rendererForName:(NSString *)name;

+ (NSString *)name;

- (id)initWithView:(AJRCalendarView *)view;

- (NSArray *)events;

- (void)rendererDidBecomeActiveInCalendarView:(AJRCalendarView *)calendarView inRect:(NSRect)bounds;
- (void)rendererDidBecomeInactiveInCalendarView:(AJRCalendarView *)calendarView inRect:(NSRect)bounds;

- (NSRect)rectForHeaderInRect:(NSRect)bounds;
- (NSRect)rectForBodyInRect:(NSRect)bounds;
- (NSRect)rectForDate:(NSDate *)date inRect:(NSRect)bounds;

- (BOOL)bodyShouldScroll;

- (void)drawHeaderInRect:(NSRect)rect bounds:(NSRect)bounds;
- (void)drawBodyInRect:(NSRect)rect bounds:(NSRect)bounds;

- (void)getEventsStart:(NSDate **)startDate andEnd:(NSDate **)endDate forDate:(NSDate *)date;
- (NSPredicate *)eventPredicateForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
- (NSPredicate *)eventPredicateForDate:(NSDate *)date;
- (void)clearAllEventHitRectangles;
- (void)clearEventHitRectangles;
- (void)clearDailyEventHitRectangles;
- (void)updateEvents:(BOOL)force;
- (NSArray *)eventsForDate:(NSDate *)date;
- (NSArray *)dailyEventsForDate:(NSDate *)date;
- (AJRCalendarEvent *)calendarEventForEvent:(EKEvent *)event;

- (NSDate *)decrementDate:(NSDate *)date;
- (NSDate *)incrementDate:(NSDate *)date;
+ (NSInteger)approximateTimeSpan;

- (BOOL)date:(NSDate *)left equals:(NSDate *)right;
- (BOOL)startDate:(NSDate *)start andEndDate:(NSDate *)endDate occursOnDate:(NSDate *)date;
- (BOOL)isEvent:(EKEvent *)event allDayOnDate:(NSDate *)date;
- (NSRect)rectForItem:(EKCalendarItem *)item;

/*!
 @methodgroup Hit Detection
 */
- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)event
              inHeaderView:(NSView *)headerView;
- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)event
                inBodyView:(NSView *)headerView;

@end
