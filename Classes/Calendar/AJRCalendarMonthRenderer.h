
#import <AJRInterface/AJRCalendarRenderer.h>

@interface AJRCalendarMonthRenderer : AJRCalendarRenderer
{
    NSDictionary *_titleAttributes;
    NSDictionary *_dayAttributes;
    NSDictionary *_dateAttributes;
    NSDictionary *_dimDateAttributes;
    NSDateFormatter *_formatter;
    NSDateFormatter *_timeFormatter;
    NSInteger _weeksInMonth;
    NSInteger _weekOfYear;

    // Used during drawing.
    NSMutableDictionary *_eventAttributes;
    NSMutableDictionary *_eventListAttributes;
}

@end
