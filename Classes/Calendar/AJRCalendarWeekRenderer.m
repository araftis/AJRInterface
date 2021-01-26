//
//  AJRCalendarWeekRenderer.m
//  AJRInterface
//
//  Created by A.J. Raftis on 5/15/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRCalendarWeekRenderer.h"

#import "AJRImages.h"
#import "NSBezierPath+Extensions.h"
#import "NSColor+Extensions.h"
#import "NSAttributedString+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <CalendarStore/CalendarStore.h>

static NSImage    *_currentTimeIndicator = nil;

@implementation AJRCalendarWeekRenderer

+ (void)load
{
    [AJRCalendarRenderer registerCalendarRenderer:self];
}

- (id)initWithView:(AJRCalendarView *)view
{
    if ((self = [super initWithView:view])) {
        NSLocale            *locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]];
        NSDateFormatter        *formatter;
        
        if (_currentTimeIndicator == nil) {
            _currentTimeIndicator = [AJRImages imageNamed:@"AJRCurrentTimeIndicator" forObject:self];
        }
        
        _days = 7;
        
        _formatters = [[NSMutableArray alloc] init];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"EEEE',' MMM d"];
        [_formatters addObject:formatter];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"EEE',' MMM d"];
        [_formatters addObject:formatter];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"EEE d"];
        [_formatters addObject:formatter];
        
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setLocale:locale];
        [_timeFormatter setDateFormat:@"h:mm a"];
        

        _leftMargin = 52.0;
        _halfHourHeight = 36.0;
    }
    return self;
}


+ (NSString *)name
{
    return @"Week";
}

- (void)rendererDidBecomeActiveInCalendarView:(AJRCalendarView *)calendarView inRect:(NSRect)bounds
{
    NSArray            *events;
    AJRCalendarEvent    *earliest = nil;
    NSUInteger        earliestTime = NSUIntegerMax;
    AJRCalendarEvent    *latest = nil;
    NSUInteger        latestTime = 0;
    NSRect            rect;
    NSCalendar        *calendar = [calendarView calendar];
    
    // Make sure we have the most current events
    [self updateEvents:YES];
    
    events = [self events];
    for (AJRCalendarEvent *event in events) {
        NSUInteger    eventStartTime, eventEndTime;
        
        if ([event isAllDay]) continue; // This don't effect our visible scroll region.
        
        eventStartTime = [calendar ordinalityOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitDay forDate:[event startDate]];
        eventEndTime = [calendar ordinalityOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitDay forDate:[event endDate]];
        
        if (eventStartTime < earliestTime) {
            earliest = event;
            earliestTime = eventStartTime;
        }
        if (eventEndTime > latestTime) {
            latest = event;
            latestTime = eventEndTime;
        }
    }
    
    if (earliest) {
        NSScrollView    *scrollView = [calendarView bodyScrollView];
        NSRect            documentRect = [scrollView documentVisibleRect];
        
        rect = NSInsetRect([self rectForEvent:earliest inRect:bounds], 0, -50);
        if (!NSContainsRect(documentRect, rect)) {
            [[[calendarView bodyScrollView] documentView] scrollRectToVisible:rect];
        }
    } else {
    }
}

- (NSDate *)decrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setWeekOfMonth:-1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)incrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setWeekOfMonth:1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

+ (NSInteger)approximateTimeSpan
{
    return 7;
}

- (void)getEventsStart:(NSDate **)startDateIn andEnd:(NSDate **)endDateIn forDate:(NSDate *)date
{
    NSDateComponents    *adder = [[NSDateComponents alloc] init];
    NSCalendar            *calendar = [_view calendar];
    NSDate                *startDate;
    NSDate                *endDate;
    
    adder = [[NSDateComponents alloc] init];
    [adder setDay:[self initialDayOfWeekForDate:date] - [[_view calendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date]];
    startDate = [calendar dateByAddingComponents:adder toDate:date options:0];
    [adder setDay:_days];
    endDate = [calendar dateByAddingComponents:adder toDate:startDate options:0];

    if (startDateIn) *startDateIn = startDate;
    if (endDateIn) *endDateIn = endDate;
}

- (NSRect)rectForHeaderInRect:(NSRect)bounds
{    
    [self updateEvents:NO];

    bounds.origin.y = bounds.size.height - (24.0 + 18.0 * _maxDailyEvents);
    bounds.size.height = 24.0 + 18.0 * _maxDailyEvents;
    
    return bounds;
}

- (NSRect)rectForBodyInRect:(NSRect)bounds
{
    _halfHourHeight = bounds.size.height * 0.0375;
    bounds.size.height = _halfHourHeight * 48.0;
    
    return bounds;
}

- (NSRect)rectForDate:(NSDate *)date inRect:(NSRect)bounds
{
//    NSRect                bounds = [[[_view bodyScrollView] documentView] bounds];
    CGFloat                baseWidth = bounds.size.width - _leftMargin;
    NSCalendar            *calendar = [_view calendar];
    NSArray                *weekdays;
    CGFloat                width;
    NSInteger            widthRemainder;
    NSInteger            dayOfWeek;
    NSRect                rect = NSZeroRect;
    NSDateComponents    *components;
    
    weekdays = [[_formatters lastObject] weekdaySymbols];
    width = floor(baseWidth / _days);
    widthRemainder = (NSInteger)baseWidth % _days;
    components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:date];
    dayOfWeek = [components weekday] - 1;
    
    //AJRPrintf(@"%C: %d\n", self, widthRemainder);
    
    rect.size.width = width + 1.0;
    if (dayOfWeek <= widthRemainder) {
        rect.size.width += 1.0;
    }
    rect.size.height = bounds.size.height;
    rect.origin.x = bounds.origin.x + _leftMargin - 1.0;
    for (NSInteger x = [self initialDayOfWeekForDate:date]; x <= dayOfWeek; x++) {
        rect.origin.x += width;
        if (x <= widthRemainder + 1) {
            rect.origin.x += 1.0;
        }
    }
    rect.origin.y = bounds.origin.y;
    
    return NSIntegralRect(rect);
}    

- (NSRect)rectForEvent:(AJRCalendarEvent *)event inRect:(NSRect)bounds
{
    NSRect        eventRect;
    NSRect        dayRect = [self rectForDate:[event startDate] inRect:bounds];
    NSCalendar    *calendar = [_view calendar];
    CGFloat        startPercent, startY;
    CGFloat        endPercent, endY;

    startPercent = ([calendar ordinalityOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitDay forDate:[event startDate]]) / 1440.0;
    endPercent = ([calendar ordinalityOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitDay forDate:[event endDate]]) / 1440.0;
    startY = rint(dayRect.origin.y + dayRect.size.height * (1.0 - startPercent));
    endY = rint(dayRect.origin.y + dayRect.size.height * (1.0 - endPercent));
    eventRect.origin.x = dayRect.origin.x + 0.5;
    eventRect.origin.y = endY + 0.5;
    eventRect.size.width = dayRect.size.width - 1.0;
    eventRect.size.height = startY - endY;

    return eventRect;
}

- (BOOL)bodyShouldScroll
{
    return YES;
}

- (NSDictionary *)headerAttributes
{
    if (_headerAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:10.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        _headerAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                             font, NSFontAttributeName,
                             [_view fontColor], NSForegroundColorAttributeName,
                             style, NSParagraphStyleAttributeName,
                             nil];
    }
    return _headerAttributes;
}

- (NSDictionary *)boldHeaderAttributes
{
    if (_boldHeaderAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:10.0];
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        _boldHeaderAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 font, NSFontAttributeName,
                                 [_view fontColor], NSForegroundColorAttributeName,
                                 style, NSParagraphStyleAttributeName,
                                 nil];
    }
    return _boldHeaderAttributes;
}
- (NSDictionary *)labelAttributes
{
    if (_labelAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:10.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentRight];
        
        _labelAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                            font, NSFontAttributeName,
                            [_view dimmedFontColor], NSForegroundColorAttributeName,
                            style, NSParagraphStyleAttributeName,
                            nil];
    }
    return _labelAttributes;
}

- (NSDictionary *)smallLabelAttributes
{
    if (_smallLabelAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:9.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentRight];
        
        _smallLabelAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                            font, NSFontAttributeName,
                            [_view dimmedFontColor], NSForegroundColorAttributeName,
                            style, NSParagraphStyleAttributeName,
                            nil];
    }
    return _smallLabelAttributes;
}

- (NSMutableDictionary *)eventAttributesForDaily:(BOOL)daily
{
    NSMutableDictionary        *eventAttributes;
    NSFont                    *font = [_view font];
    NSMutableParagraphStyle    *style;
    
    if (daily) {
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:10.0];
    } else {
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:9.0];
    }
    
    style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentLeft];
    [style setHyphenationFactor:1.0];
    
    eventAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       font, NSFontAttributeName,
                       [NSColor blackColor], NSForegroundColorAttributeName,
                       style, NSParagraphStyleAttributeName,
                       nil];
    
    return eventAttributes;
}

- (NSInteger)initialDayOfWeekForDate:(NSDate *)date;
{
    return 1;
}

- (void)drawHeaderInRect:(NSRect)rect bounds:(NSRect)bounds
{
    NSDate                *date = [_view date];
    NSCalendar            *calendar = [_view calendar];
    NSInteger            x;
    NSRect                dayRect;
    CGFloat                width;
    NSDate                *workDate;
    NSDateComponents    *adder;
    NSInteger            month;
    NSInteger            year;
    NSDate                *today = [NSDate date];
    NSDictionary        *headerAttributes;
    CGFloat                allDayHeight = 1.0 + 18.0 * _maxDailyEvents;
    CGFloat                saveHeight;
    NSMutableDictionary    *eventAttributes = [self eventAttributesForDaily:YES];
    
    [self updateEvents:NO];
    
    [NSBezierPath setDefaultLineWidth:1.0];
    
    // Compute some values we'll need while rendering
    month = [calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:date];
    year = [calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:date];
    
    [[_view backgroundColor] set];
    NSRectFill(bounds);
    
    // Recompute bounds, because we want them minus the scroll bar width;
    //bounds.size.width = [[_view bodyScrollView] documentVisibleRect].size.width;
    width = (bounds.size.width - _leftMargin) / 7.0;
    
    dayRect = (NSRect){{bounds.origin.x - 1.0, bounds.origin.y + bounds.size.height - 24.0}, {_leftMargin + 1.0, 18.0}};
    //NSFrameRect(dayRect);
    [AJRFormat(@"%04d", year) drawInRect:dayRect withAttributes:[self headerAttributes]];
    dayRect = (NSRect){{dayRect.origin.x, bounds.origin.y + bounds.size.height - (24.0 + allDayHeight)}, {dayRect.size.width, allDayHeight + 1.0}};
    [[_view gridColor] set];
    NSFrameRect(dayRect);
    dayRect.size.height -= 4.0;
    dayRect.size.width -= 8.0;
    [@"all-day" drawInRect:dayRect withAttributes:[self labelAttributes]];
    
    x = 0;
    adder = [[NSDateComponents alloc] init];
    //AJRPrintf(@"%@: %d, %d\n", self, [self initialDayOfWeekForDate:date], [[_view calendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date]);
    [adder setDay:[self initialDayOfWeekForDate:date] - [[_view calendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date]];
    workDate = [calendar dateByAddingComponents:adder toDate:date options:0];
    [adder setDay:1];
    headerAttributes = [self headerAttributes];
    for (x = 0; x < _days; x++) {
        NSString    *string;
        
        dayRect = [self rectForDate:workDate inRect:bounds];
        //dayRect.origin.x = bounds.origin.x + _leftMargin + (x * width);
        dayRect.origin.y = bounds.origin.y + bounds.size.height - 24.0;
        //dayRect.size.width = width;
        dayRect.size.height = 18.0;
        
        if ([self date:workDate    equals:today]) {
            saveHeight = dayRect.size.height;
            dayRect.size.height = allDayHeight + 25.0;
            dayRect.origin.y -= allDayHeight;
            [[_view todayBackgroundColor] set];
            NSRectFillUsingOperation(dayRect, NSCompositingOperationSourceOver);
            [[_view gridColor] set];
            NSFrameRect(dayRect);
            dayRect.size.height = saveHeight;
            dayRect.origin.y += allDayHeight;
        } else if ([self date:workDate equals:date]) {
            saveHeight = dayRect.size.height;
            dayRect.size.height = allDayHeight + 25.0;
            dayRect.origin.y -= allDayHeight;
            [[_view selectedBackgroundColor] set];
            NSRectFillUsingOperation(dayRect, NSCompositingOperationSourceOver);
            [[_view gridColor] set];
            NSFrameRect(dayRect);
            dayRect.size.height = saveHeight;
            dayRect.origin.y += allDayHeight;
        } else {
            [[_view gridColor] set];
        }
        
        dayRect.origin.y -= allDayHeight;
        saveHeight = dayRect.size.height;
        dayRect.size.height = allDayHeight + 1;
        NSFrameRect(dayRect);
        dayRect.size.height = saveHeight;
        dayRect.origin.y += allDayHeight;
        
        string = @"";
        for (NSDateFormatter *formatter in _formatters) {
            string = [formatter stringFromDate:workDate];
            if ([string sizeWithAttributes:headerAttributes].width < width - 5.0) break;
        }
        [string drawInRect:dayRect withAttributes:[self date:workDate equals:today] ? [self boldHeaderAttributes] : [self headerAttributes]];
        
        workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    }

    [[_view gridColor] set];
    dayRect.origin.x += dayRect.size.width - 1.0;
    dayRect.origin.y -= allDayHeight;
    dayRect.size.height = allDayHeight + 1;
    NSFrameRect(dayRect);

    [adder setDay:-_days];
    workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    [adder setDay:1];
    [self clearDailyEventHitRectangles];
    for (x = 0; x < _days; x++) {
        dayRect = [self rectForDate:workDate inRect:bounds];
        dayRect.origin.y = bounds.origin.y + bounds.size.height - 24.0;
        dayRect.size.height = 18.0;
                
        dayRect.origin.x += 0.5;
        dayRect.origin.y -= 17.5;
        dayRect.size.height = 17.0;
        dayRect.size.width -= 1.0;
        if (x == _days - 1/* && ![NSGraphicsContext currentContextDrawingToScreen]*/) {
            dayRect.size.width -= 1.0;
        }
        for (AJRCalendarEvent *event in [self dailyEventsForDate:workDate]) {
            NSBezierPath    *path = [[NSBezierPath alloc] init];
            
            // Build a path to draw the event into.
            [path appendBezierPathWithRoundedRect:dayRect xRadius:6.0 yRadius:6.0];
            // And draw it.
            if ([_view isEventSelected:[event event]]) {
                NSGradient    *gradient = [[[event calendar] color] gradientWithSaturationWeight:2.0 / 3.0 andBrightnessWeight:1.1];
                [gradient drawInBezierPath:path angle:0.0];
                [[[event calendar] color] set];
                [path stroke];
            } else {
                [[[[[event calendar] color] colorWithAlphaComponent:0.5] colorByMultiplyingSaturation:1.125 andBrightness:1.33] set];
                [path fill];
                [[[event calendar] color] set];
                [path stroke];
            }
            
            // Now save the rectangle we used into the event
            [event addHitRectangle:dayRect];
            
            // Finally, draw the text.
            dayRect.origin.x += 4.0;
            dayRect.size.width -= 8.0;
            dayRect.size.height -= 2.0;
            if ([_view isEventSelected:[event event]]) {
                [eventAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            } else {
                [eventAttributes setObject:[[[event calendar] color] colorByMultiplyingBrightness:0.9] forKey:NSForegroundColorAttributeName];
            }
            [[event title] drawInRect:dayRect withAttributes:eventAttributes];
            // Adjust the rectangle back to its original values.
            dayRect.size.width += 8.0;
            dayRect.size.height += 2.0;
            dayRect.origin.x -= 4.0;

            // And advance the rectangle to the next event.
            dayRect.origin.y -= 18.0;
            
        }
        
        workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    }
    
    if (![NSGraphicsContext currentContextDrawingToScreen]) {
        [[_view gridColor] set];
        //[[NSColor redColor] set];
        bounds.origin.y -= 1.0;
        bounds.size.height += 1.0;
        NSFrameRect(bounds);
    }
    
}

- (void)drawBodyInRect:(NSRect)rect bounds:(NSRect)bounds
{
    NSDate                *date = [_view date];
    NSDate                *workDate;
    NSDate                *today = [NSDate date];
    NSCalendar            *calendar = [_view calendar];
    NSInteger            x;
    NSRect                dayRect, workRect;
    NSDateComponents    *adder;
    CGFloat                y;
    NSColor                *gridColor = [_view gridColor];
    NSColor                *lightGridColor;
    NSMutableDictionary    *eventAttributes;
    NSMutableDictionary    *eventAttributesLarge;
    NSInteger            minuteOfDay;
    BOOL                containsToday = NO;
    
    [NSBezierPath setDefaultLineWidth:1.0];

    [self updateEvents:NO];

    lightGridColor = [gridColor colorByMultiplyingBrightness:1.15];
    
    adder = [[NSDateComponents alloc] init];
    [adder setDay:[self initialDayOfWeekForDate:date] - [[_view calendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date]];
    workDate = [calendar dateByAddingComponents:adder toDate:date options:0];
    [adder setDay:1];
    for (x = 0; x < _days; x++) {
        NSInteger        workStart = [_view firstMinuteOfWorkHours];
        NSInteger        workStop = [_view lastMinuteOfWorkHours];
        
        dayRect = [self rectForDate:workDate inRect:bounds];
        
        if ([self date:workDate    equals:today]) {
            [[_view todayBackgroundColor] set];
            NSRectFillUsingOperation(dayRect, NSCompositingOperationSourceOver);
            containsToday = YES;
        } 
        if ([self date:workDate equals:date]) {
            [[_view selectedBackgroundColor] set];
            NSRectFillUsingOperation(dayRect, NSCompositingOperationSourceOver);
        }

        if (x == 0) {
            dayRect.origin.x -= _leftMargin;
            dayRect.size.width += _leftMargin;
        }
        
        if (workStart >= 0) {
            NSRect    startRect = dayRect;
            
            startRect.size.height = ((CGFloat)workStart / 1440.0) * dayRect.size.height;
            startRect.origin.y = dayRect.origin.y + dayRect.size.height - startRect.size.height;
            [[_view selectedBackgroundColor] set];
            NSRectFillUsingOperation(startRect, NSCompositingOperationSourceOver);
        }
        if (workStop < 1440) {
            NSRect    stopRect = dayRect;
            
            stopRect.size.height = ((CGFloat)(1440 - workStop) / 1440.0) * dayRect.size.height;
            [[_view selectedBackgroundColor] set];
            NSRectFillUsingOperation(stopRect, NSCompositingOperationSourceOver);
        }
        
        workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    }

    workRect = [self rectForDate:date inRect:bounds];
    workRect.origin.y -= 1.0;
    workRect.size.height += 2.0;
    for (x = 1; x <= 24; x++) {
        NSString    *string;
        CGFloat        percent;
        
        percent = ((x - 0) * 60.0 - 30.0) / 1440.0;
        y = rint(workRect.origin.y + workRect.size.height * (1.0 - percent));
        [lightGridColor set];
        [NSBezierPath strokeLineFromPoint:(NSPoint){_leftMargin, y + 0.5} toPoint:(NSPoint){bounds.size.width, y + 0.5}];

        percent = ((x - 0) * 60.0 + 0.0) / 1440.0;
        y = rint(workRect.origin.y + workRect.size.height * (1.0 - percent));
        //AJRPrintf(@"%C: %.1f, %.4f, %.1f\n", self, workRect.size.height, percent, y);
        if (x != 24) {
            [gridColor set];
            [NSBezierPath strokeLineFromPoint:(NSPoint){_leftMargin, y + 0.5} toPoint:(NSPoint){bounds.size.width, y + 0.5}];
        }
        
        if (x < 12) {
            string = AJRFormat(@"%d AM", x);
        } else if (x == 12) {
            string = @"NOON";
        } else if (x == 24) {
            string = @"";
        } else {
            string = AJRFormat(@"%d PM", x - 12);
        }
        dayRect.origin.x = bounds.origin.x;
        dayRect.origin.y = y - 4.0;
        dayRect.size.width = _leftMargin - 8.0;
        dayRect.size.height = 12.0;
        [string drawInRect:dayRect withAttributes:[self smallLabelAttributes]];
    }
    
    if (containsToday) {
        // Now draw the current time.
        NSBezierPath    *path;
        NSColor            *color = [_view timeIndicatorColor];
        NSGradient        *gradient = [[color colorByMultiplyingSaturation:0.5 andBrightness:1.5] gradientWithSaturationWeight:0.25 andBrightnessWeight:1.5];
        
        workRect = [self rectForDate:[NSDate date] inRect:bounds];
        minuteOfDay = [calendar ordinalityOfUnit:NSCalendarUnitMinute  inUnit:NSCalendarUnitDay  forDate:[NSDate date]];
        y = rint(((1440.0 - (double)minuteOfDay) / 1440.0) * workRect.size.height) + 0.5;
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
        [NSBezierPath strokeLineFromPoint:(NSPoint){_leftMargin, y} toPoint:(NSPoint){bounds.size.width, y}];
        //[_currentTimeIndicator compositeToPoint:(NSPoint){_leftMargin - 22.0, y - 30.0} operation:NSCompositingOperationSourceOver];
        path = [[NSBezierPath alloc] init];
        [path moveToPoint:(NSPoint){_leftMargin - 1.5, y}];
        [path lineToPoint:(NSPoint){_leftMargin - 1.5, y + 1.0}];
        [path lineToPoint:(NSPoint){_leftMargin - 6.0, y + 1.0}];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(_leftMargin - 9.5, y)
                                         radius:4.0 
                                     startAngle:15.0
                                       endAngle:345.0];
        [path lineToPoint:(NSPoint){_leftMargin - 6.0, y - 1.0}];
        [path lineToPoint:(NSPoint){_leftMargin - 1.5, y - 1.0}];
        [path closePath];
        [NSGraphicsContext saveGraphicsState];
        NSShadow    *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor:[NSColor grayColor]];
        [shadow setShadowBlurRadius:3.0];
        [shadow setShadowOffset:(NSSize){-4.0, -4.0}];
        [shadow set];
        [path fill];
        [gradient drawInBezierPath:path angle:90.0];
        [color set];
        [path stroke];
        [NSGraphicsContext restoreGraphicsState];
        
    }
    
    // Finally, set up for drawing the events.
    adder = [[NSDateComponents alloc] init];
    [adder setDay:[self initialDayOfWeekForDate:date] - [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date]];
    workDate = [calendar dateByAddingComponents:adder toDate:date options:0];
    [adder setDay:1];
    for (x = 0; x < _days; x++) {
        dayRect = [self rectForDate:workDate inRect:bounds];
        dayRect.origin.y -= 1.0;
        dayRect.size.height += 2.0;
        [[_view gridColor] set];
        NSFrameRect(dayRect);
        
        workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    }
    [adder setDay:-_days];
    workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    [adder setDay:1];
    // Clear out the old hit rectangles
    [self clearEventHitRectangles];
    // And now draw the events.
    for (x = 0; x < _days; x++) {
        BOOL        drawSelected = NO;
        NSInteger    sIndex;
        
        dayRect = [self rectForDate:workDate inRect:bounds];
        dayRect.origin.y -= 1.0;
        dayRect.size.height += 2.0;

        if (x == _days - 1/* && ![NSGraphicsContext currentContextDrawingToScreen]*/) {
            dayRect.size.width -= 1.0;
        }

        eventAttributes = [self eventAttributesForDaily:NO];
        eventAttributesLarge = [self eventAttributesForDaily:YES];
        
        for (sIndex = 0; sIndex < 2; sIndex++) {
            for (AJRCalendarEvent *event in [self eventsForDate:workDate]) {
                NSRect                        eventRect;
                NSAttributedString            *timeString;
                NSAttributedString            *titleString;
                NSAttributedString            *locationString;
                NSMutableAttributedString    *intermediateString;
                NSMutableAttributedString    *fullString;
                CGFloat                        startPercent, startY;
                CGFloat                        endPercent, endY;
                NSBezierPath                *path;
                NSColor                        *color = [[event calendar] color];
                CGFloat                        height;
                BOOL                        eventIsSelected = [_view isEventSelected:[event event]];

                // We do this, because we want to draw all selected events after we draw unselected events.
                if ((drawSelected && !eventIsSelected) || (!drawSelected && eventIsSelected)) continue;
                
                // Make sure our attributes are the correct color for the event.
                if (eventIsSelected) {
                    [eventAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
                    [eventAttributesLarge setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
                } else {
                    [eventAttributes setObject:color forKey:NSForegroundColorAttributeName];
                    [eventAttributesLarge setObject:color forKey:NSForegroundColorAttributeName];
                }
                
                // Now build our string fragments
                timeString = [[NSAttributedString alloc] initWithString:[_timeFormatter stringFromDate:[event startDate]] attributes:eventAttributes];
                titleString = [[NSAttributedString alloc] initWithString:[event title] attributes:eventAttributesLarge];
                locationString = [[NSAttributedString alloc] initWithString:[[event location] length] ? [event location] : @"No Location" attributes:eventAttributesLarge];
                // Build the string with time and title
                intermediateString = [[NSMutableAttributedString alloc] init];
                [intermediateString appendAttributedString:timeString];
                [intermediateString appendAttributedString:[(NSAttributedString *)[NSAttributedString alloc] initWithString:@"\n"]];
                [intermediateString appendAttributedString:titleString];
                // Finally build the string with time, title, and location
                fullString = [[NSMutableAttributedString alloc] init];
                [fullString appendAttributedString:intermediateString];
                [fullString appendAttributedString:[(NSAttributedString *)[NSAttributedString alloc] initWithString:@" — " attributes:eventAttributesLarge]];
                [fullString appendAttributedString:locationString];
                
                // Compute our start position
                if ([self date:[event startDate] equals:workDate]) {
                    NSDateComponents    *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[event startDate]];
                    startPercent = ([components hour] * 60.0 + [components minute]) / 1440.0;
                } else {
                    startPercent = 0.0;
                }
                // Compute our end position
                if ([self date:[event endDate] equals:workDate]) {
                    NSDateComponents    *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[event endDate]];
                    endPercent = ([components hour] * 60.0 + [components minute]) / 1440.0;
                } else {
                    endPercent = 1.0;
                }
                
                // Compute our display rectangle
                startY = rint(dayRect.origin.y + dayRect.size.height * (1.0 - startPercent));
                endY = rint(dayRect.origin.y + dayRect.size.height * (1.0 - endPercent));
                
                if ([event peerCount] <= 1) {
                    eventRect.origin.x = dayRect.origin.x + 0.5;
                    eventRect.origin.y = endY + 0.5;
                    eventRect.size.width = dayRect.size.width - 1.0;
                    eventRect.size.height = startY - endY;
                } else {
                    CGFloat                        peerGap;
                    
                    peerGap = (dayRect.size.width - 1.0) / (double)([event peerCount] + 2.0);
                    eventRect.origin.x = rint(dayRect.origin.x + (peerGap * [event peerPosition])) + 0.5;
                    eventRect.origin.y = endY + 0.5;
                    eventRect.size.width = rint(peerGap * 3.0);
                    eventRect.size.height = startY - endY;
                }
                
                // Create the path the surrounds the event.
                path = [[NSBezierPath alloc] init];
                [path appendBezierPathWithRoundedRect:eventRect xRadius:6.0 yRadius:6.0];
                if (eventIsSelected) {
                    NSColor            *color1 = [color colorByMultiplyingSaturation:0.85 andBrightness:1.075];
                    NSColor            *color2 = [color1 colorByMultiplyingSaturation:2.0 / 3.0 andBrightness:1.1];
                    NSGradient        *gradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
                    NSRect            clipRect;
                    // This is bizarrely failing during printing, for some reason.
                    @try {
                        [gradient drawInBezierPath:path angle:0.0];
                    } @catch (NSException *exception) { }
                    [color set];
                    [path stroke];
                    [NSGraphicsContext saveGraphicsState];
                    clipRect = eventRect;
                    clipRect.origin.y = clipRect.origin.y + clipRect.size.height - 12.5;
                    clipRect.size.height = 12.5;
                    NSRectClip(clipRect);
                    [color set];
                    [path fill];
                    [NSGraphicsContext restoreGraphicsState];
                } else {
                    [[[color colorWithAlphaComponent:0.5] colorByMultiplyingSaturation:1.125 andBrightness:1.33] set];
                    [path fill];
                    [color set];
                    [path stroke];
                }
                
                // Save the rectangle that defines where the event occurred.
                [event addHitRectangle:eventRect];
                
                // Inset our rectangle slightly, so our text doesn't touch the edges.
                eventRect.origin.x += 3.0;
                eventRect.size.width -= 3.0;
                
                // Figure out the height of the full string, if it's larger than our rect, then
                // we'll only display our title, not the time.
                height = [intermediateString ajr_sizeConstrainedToWidth:eventRect.size.width].height;
                if (height > eventRect.size.height) {
                    [titleString drawInRect:eventRect];
                } else {
                    // And finally draw the string.
                    [fullString drawInRect:eventRect];
                }
                
                // Done with it now.
            }
            drawSelected = YES;
        }
        
        workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    }
    
    if (![NSGraphicsContext currentContextDrawingToScreen]) {
        [[_view gridColor] set];
        //[[NSColor redColor] set];
        NSFrameRect(bounds);
    }
    
    //    [[NSColor blueColor] set];
//    [[NSBezierPath bezierPathWithCrossedRect:bounds] stroke];
}

#pragma mark Hit detection

- (NSDate *)dateForPoint:(NSPoint)point inRect:(NSRect)rect inHeaderView:(BOOL)flag
{
    NSInteger            dayOfWeek;
    NSInteger            initialDayOfWeek;
    NSCalendar            *calendar = [_view calendar];
    NSDateComponents    *dateComponents;
    NSDate                *date;
    NSInteger            diff;
    CGFloat                timeOfDay;
    
    if (point.x < _leftMargin) return nil;
    
    initialDayOfWeek = [self initialDayOfWeekForDate:[_view date]];
    dayOfWeek = floor((double)_days * ((point.x - rect.origin.x - _leftMargin) / (rect.size.width - _leftMargin))) + initialDayOfWeek;
    
    dateComponents = [calendar components:NSCalendarUnitWeekday fromDate:[_view date]];
    diff = dayOfWeek - [dateComponents weekday];
    dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:diff];
    date = [calendar dateByAddingComponents:dateComponents toDate:[_view date] options:0];
    
    if (!flag) {
        timeOfDay = round(1440.0 * ((rect.size.height - point.y) / rect.size.height));
        dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        [dateComponents setSecond:0];
        timeOfDay += 7;
        [dateComponents setMinute:(((NSInteger)timeOfDay) % 60) / 15 * 15];
        [dateComponents setHour:timeOfDay / 60.0];
        date = [calendar dateFromComponents:dateComponents];
    }
    
    AJRPrintf(@"%C: dayOfWeek: %d: %@\n", self, dayOfWeek, date);

    return date;
}

- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)appKitEvent
              inHeaderView:(NSView *)headerView
{
    NSPoint        where;
    
    if (calendarEvent) *calendarEvent = nil;
    if (date) *date = nil;
    
    where = [headerView convertPoint:[appKitEvent locationInWindow] fromView:nil];
    for (AJRCalendarEvent *event in _events) {
        NSRect    hitRect;
        
        if ([event isAllDay] && !NSEqualRects(NSZeroRect, hitRect = [event containsPoint:where])) {
            if (calendarEvent) {
                *calendarEvent = event;
                if (date) {
                    *date = [self dateForPoint:where inRect:[headerView bounds] inHeaderView:YES];
                }
                return hitRect;
            }
        }
    }
    
    if (date) {
        *date = [self dateForPoint:where inRect:[headerView bounds] inHeaderView:YES];
    }

    return NSZeroRect;
}

- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)appKitEvent
                inBodyView:(NSView *)bodyView
{
    NSPoint        where;
    
    if (calendarEvent) *calendarEvent = nil;
    if (date) *date = nil;
    
    where = [bodyView convertPoint:[appKitEvent locationInWindow] fromView:nil];
    for (AJRCalendarEvent *event in _events) {
        NSRect        hitRect;
        if (![event isAllDay] && !NSEqualRects(NSZeroRect, hitRect = [event containsPoint:where])) {
            if (calendarEvent) {
                *calendarEvent = event;
                if (date) {
                    *date = [self dateForPoint:where inRect:[bodyView bounds] inHeaderView:NO];
                }
                return hitRect;
            }
        }
    }
    
    if (date) {
        *date = [self dateForPoint:where inRect:[bodyView bounds] inHeaderView:NO];
    }

    return NSZeroRect;
}

@end
