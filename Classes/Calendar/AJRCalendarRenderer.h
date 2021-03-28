
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
