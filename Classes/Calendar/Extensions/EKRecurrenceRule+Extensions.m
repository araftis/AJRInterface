//
//  EKRecurrenceRule+Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/6/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "EKRecurrenceRule+Extensions.h"

#import "AJRCalendarView.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRTranslator.h>

static NSDateFormatter    *_dateFormatter = nil;

@implementation EKRecurrenceRule (AJRInterfaceExtensions)

+ (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    }
    return _dateFormatter;
}

- (NSString *)ajr_frequencyString
{
    switch ([self frequency]) {
        case EKRecurrenceFrequencyDaily:
            if ([self interval] == 1) {
                return [self valueForKeyPath:@"translator.Every day"];
            }
            break;
        case EKRecurrenceFrequencyWeekly:
            if ([self interval] == 1 && [[self daysOfTheWeek] count] < 1) {
                return [self valueForKeyPath:@"translator.Every week"];
            }
            break;
        case EKRecurrenceFrequencyMonthly:
            if ([self interval] == 1 && [[self daysOfTheMonth] count] < 1) {
                return [self valueForKeyPath:@"translator.Every month"];
            }
            break;
        case EKRecurrenceFrequencyYearly:
            if ([self interval] == 1 && [[self monthsOfTheYear] count] < 1) {
                return [self valueForKeyPath:@"translator.Every year"];
            }
            break;
    }
    return [self valueForKeyPath:@"translator.Custom"];
}

- (NSString *)ajr_frequencyIntervalStringForWeekly
{
    if ([self interval] != 1 || [[self daysOfTheWeek] count] > 0) {
        NSMutableString    *work = [NSMutableString string];
        if ([self interval] == 1) {
            [work appendString:[self valueForKeyPath:@"translator.Every week"]];
        } else {
            [work appendFormat:[self valueForKeyPath:@"translator.Every %d weeks"], [self interval]];
        }
        if ([[self daysOfTheWeek] count] > 1) {
            NSArray        *days = [self daysOfTheWeek];
            NSArray        *weekdays = [[[self class] dateFormatter] weekdaySymbols];
            NSInteger    x, max = [days count];
            
            [work appendFormat:@" %@ ", [self valueForKeyPath:@"translator.on"]];
            for (x = 0; x < max; x++) {
                NSInteger dayIndex = [[days objectAtIndex:x] integerValue] - 1;
                if (x > 0 && max != 2) {
                    [work appendString:@", "];
                }
                if (x > 0 && x == max - 1) {
                    [work appendFormat:@" %@ ", [self valueForKeyPath:@"translator.and"]];
                }
                [work appendString:[weekdays objectAtIndex:dayIndex]];
            }
        }
        return work;
    }
    return nil;
}

- (NSString *)ajr_frequencyIntervalString
{
    switch ([self frequency]) {
        case EKRecurrenceFrequencyDaily:
            break;
        case EKRecurrenceFrequencyWeekly:
            return [self ajr_frequencyIntervalStringForWeekly];
        case EKRecurrenceFrequencyMonthly:
            break;
        case EKRecurrenceFrequencyYearly:
            break;
    }
    return nil;
}

- (NSString *)ajr_frequencyEndString
{
    EKRecurrenceEnd    *end = [self recurrenceEnd];
    
    if (end) {
        if ([end endDate]) {
            return [[[self class] dateFormatter] stringFromDate:[end endDate]];
        } else {
            if ([end occurrenceCount] == 1) {
                return AJRFormat([self valueForKeyPath:@"translator.After %d time"], [end occurrenceCount]);
            } else {
                return AJRFormat([self valueForKeyPath:@"translator.After %d times"], [end occurrenceCount]);
            }
        }
        return [self valueForKeyPath:@"translator.Unknown"];
    }
    
    return [self valueForKeyPath:@"translator.Never"];
}

#pragma mark NSObject-Extensions

- (AJRTranslator *)translator
{
    return [AJRTranslator translatorForClass:[AJRCalendarView class]];
}

@end
