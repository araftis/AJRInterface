
#import <AJRInterface/AJRCalendarItemInspector.h>

@interface AJRCalendarEventInspector : AJRCalendarItemInspector
{
    NSDateFormatter *_dateFormatter;
    NSMutableDictionary *_valueAttributes;
    id _initialFirstResponder;
}

@end
