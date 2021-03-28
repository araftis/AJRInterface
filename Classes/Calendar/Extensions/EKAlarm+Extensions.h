
#import <EventKit/EventKit.h>

@interface EKAlarm (AJRInterfaceExtensions)

- (NSString *)ajr_typeString;
- (NSString *)ajr_typeSubstring;
- (NSString *)ajr_triggerString;

@end
