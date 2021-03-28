
#import "EKCalendar+Extensions.h"

@implementation EKCalendar (AJRInterfaceExtensions)

- (NSString *)typeString {
    NSString *typeString = @"Other";
    
    switch ([self type]) {
        case EKCalendarTypeBirthday:
            typeString = @"Birthdays";
            break;
        case EKCalendarTypeCalDAV:
            typeString = @"iCal";
            break;
        case EKCalendarTypeLocal:
            typeString = @"Calendars";
            break;
        case EKCalendarTypeSubscription:
            typeString = @"Subscriptions";
            break;
        case EKCalendarTypeExchange:
            typeString = @"Exchange";
            break;
    }
    
    return typeString;
}    

- (NSString *)UID {
    return [self calendarIdentifier];
}

@end
