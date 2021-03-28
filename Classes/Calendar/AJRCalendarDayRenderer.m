
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
