
#import "EKAlarm+Extensions.h"

#import "AJRCalendarView.h"
#import "EKRecurrenceRule+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRTranslator.h>

@implementation EKAlarm (AJRInterfaceExtensions)

- (NSString *)ajr_typeString
{
    NSString    *action = @"translator.Unknown";
    
    switch ([self type]) {
        case EKAlarmTypeDisplay:
            action = @"translator.Message";
            break;
        case EKAlarmTypeAudio:
            action = @"translator.Play sound";
            break;
        case EKAlarmTypeProcedure:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            if ([[[[self url] path] pathExtension] isEqualToString:@"scpt"]) {
                action = @"translator.Run script";
            } else {
                action = @"translator.Open file";
            }
#pragma clang diagnostic pop
            break;
        case EKAlarmTypeEmail:
            action = @"translator.Email";
            break;
    }

    return [self valueForKeyPath:action];;
}

- (NSString *)ajr_typeSubstring
{
    NSString    *substring = nil;
    
    switch ([self type]) {
        case EKAlarmTypeDisplay:
            if ([self soundName]) {
                substring = [self soundName];
            }
            break;
        case EKAlarmTypeEmail:
            substring = [self emailAddress];
            break;
        case EKAlarmTypeProcedure:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            if ([[[[self url] path] pathExtension] isEqualToString:@"scpt"]) {
                substring = AJRFormat(@"%@ %@", [self valueForKeyPath:@"translator.Open"], [[[self url] path] lastPathComponent]);
            } else {
                substring = AJRFormat(@"%@ %@", [self valueForKeyPath:@"translator.Open"], [[[self url] path] lastPathComponent]);
            }
#pragma clang diagnostic pop
            break;
        case EKAlarmTypeAudio:
            substring = [self soundName];
            break;
    }

    return substring;
}

- (NSString *)ajr_triggerString
{
    NSString    *triggerString;
    NSInteger    seconds;
    NSString    *relative;
    NSString    *units;
    
    if ([self absoluteDate]) {
        triggerString = AJRFormat(@"%@ %@", [self valueForKeyPath:@"translator.On"], [[EKRecurrenceRule dateFormatter] stringFromDate:[self absoluteDate]]);
    } else {
        seconds = [self relativeOffset];
        if (seconds < 0) {
            relative = [self valueForKeyPath:@"translator.before"];
        } else {
            relative = [self valueForKeyPath:@"translator.after"];
        }
        seconds = labs(seconds);
        if (seconds < 60 * 60) {
            units = [self valueForKeyPath:@"translator.minute"];
            seconds /= 60;
        } else if (seconds < 60 * 60 * 24) {
            units = [self valueForKeyPath:@"translator.hour"];
            seconds /= (60 * 60);
        } else {
            units = [self valueForKeyPath:@"translator.day"];
            seconds /= (60 * 60 * 24);
        }
        triggerString = AJRFormat(@"%d %@%@ %@", seconds, units, seconds == 1 ? @"" : @"s", relative);
    }
    
    return triggerString;
}

#pragma mark NSObject-Extensions

- (AJRTranslator *)translator
{
    return [AJRTranslator translatorForClass:[AJRCalendarView class]];
}

@end
