
#import <AJRInterface/AJRCalendarRenderer.h>

@interface AJRCalendarWeekRenderer : AJRCalendarRenderer
{
    NSInteger _days;
    NSDictionary *_headerAttributes;
    NSDictionary *_boldHeaderAttributes;
    NSDictionary *_labelAttributes;
    NSDictionary *_smallLabelAttributes;
    NSMutableArray *_formatters;
    NSDateFormatter *_timeFormatter;
    CGFloat _leftMargin;
    CGFloat _halfHourHeight;
}

- (NSInteger)initialDayOfWeekForDate:(NSDate *)date;
- (NSRect)rectForEvent:(AJRCalendarEvent *)event inRect:(NSRect)bounds;

@end
