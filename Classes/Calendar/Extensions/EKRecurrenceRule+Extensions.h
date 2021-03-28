
#import <EventKit/EventKit.h>

@interface EKRecurrenceRule (AJRInterfaceExtensions)

+ (NSDateFormatter *)dateFormatter;

- (NSString *)ajr_frequencyString;
- (NSString *)ajr_frequencyIntervalString;
- (NSString *)ajr_frequencyEndString;

@end
