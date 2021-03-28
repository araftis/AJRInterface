
#import "AJRCalendarYearRenderer.h"

@implementation AJRCalendarYearRenderer

+ (void)load {
    //[AJRCalendarRenderer registerCalendarRenderer:self];
}

+ (NSString *)name {
    return @"Year";
}

- (NSDate *)decrementDate:(NSDate *)date {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:-1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)incrementDate:(NSDate *)date {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

+ (NSInteger)approximateTimeSpan {
    return 365;
}

@end
