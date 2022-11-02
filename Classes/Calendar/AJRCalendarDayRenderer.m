/*
 AJRCalendarDayRenderer.m
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

#import "AJRCalendarDayRenderer.h"

#import "NSBezierPath+Extensions.h"
#import "NSColor+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRCalendarDayRenderer

+ (void)load
{
    [AJRCalendarRenderer registerCalendarRenderer:self];
}

- (id)initWithView:(AJRCalendarView *)view
{
    if ((self = [super initWithView:view])) {
        _days = 1;
    }
    return self;
}

+ (NSString *)name
{
    return @"Day";
}

- (NSDate *)decrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)incrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

+ (NSInteger)approximateTimeSpan
{
    return 1;
}

- (NSInteger)initialDayOfWeekForDate:(NSDate *)date
{
    return [[_view calendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date];
}

@end
