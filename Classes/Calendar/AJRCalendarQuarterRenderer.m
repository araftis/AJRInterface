
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
