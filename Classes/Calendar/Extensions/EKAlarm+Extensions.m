/*
EKAlarm+Extensions.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
