/*
 EKRecurrenceRule+Extensions.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
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

#import "EKRecurrenceRule+Extensions.h"

#import "AJRCalendarView.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRTranslator.h>

static NSDateFormatter    *_dateFormatter = nil;

@implementation EKRecurrenceRule (AJRInterfaceExtensions)

+ (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    }
    return _dateFormatter;
}

- (NSString *)ajr_frequencyString {
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

- (NSString *)ajr_frequencyIntervalStringForWeekly {
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

- (NSString *)ajr_frequencyIntervalString {
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

- (NSString *)ajr_frequencyEndString {
    EKRecurrenceEnd *end = [self recurrenceEnd];
    
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

- (AJRTranslator *)translator {
    return [AJRTranslator translatorForClass:[AJRCalendarView class]];
}

@end
