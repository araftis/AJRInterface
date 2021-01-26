//
//  AJRCalendarQuarterRenderer.m
//  AJRInterface
//
//  Created by A.J. Raftis on 5/16/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRCalendarQuarterRenderer.h"

@implementation AJRCalendarQuarterRenderer

+ (void)load
{
    //[AJRCalendarRenderer registerCalendarRenderer:self];
}

+ (NSString *)name
{
    return @"Quarter";
}

- (NSDate *)decrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setMonth:-3];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)incrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setMonth:3];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

+ (NSInteger)approximateTimeSpan
{
    return 90;
}

@end
