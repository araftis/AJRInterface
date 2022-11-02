/*
 AJRCalendarMonthRenderer.m
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

#import "AJRCalendarMonthRenderer.h"

#import "NSString+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <CalendarStore/CalendarStore.h>

@interface AJRCalendarMonthRenderer ()

- (NSMutableDictionary *)eventAttributesIncludeBullet:(BOOL)flag;

@end


@implementation AJRCalendarMonthRenderer

+ (void)load
{
    [AJRCalendarRenderer registerCalendarRenderer:self];
}

- (id)initWithView:(AJRCalendarView *)view
{
    if ((self = [super initWithView:view])) {
        NSLocale    *locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]];
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"MMMM y"];
        [_formatter setLocale:locale];
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"h':'mm a"];
        [_timeFormatter setLocale:locale];
        
        _eventAttributes = [self eventAttributesIncludeBullet:NO];
        _eventListAttributes = [self eventAttributesIncludeBullet:YES];
    }
    return self;
}


+ (NSString *)name
{
    return @"Month";
}

- (NSDate *)decrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setMonth:-1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)incrementDate:(NSDate *)date
{
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    [components setMonth:1];
    return [[_view calendar] dateByAddingComponents:components toDate:date options:0];
}

+ (NSInteger)approximateTimeSpan
{
    return 30;
}

- (void)getEventsStart:(NSDate **)startDate andEnd:(NSDate **)endDateIn forDate:(NSDate *)date
{
    NSCalendar            *calendar = [_view calendar];
    NSDateComponents    *components;
    NSDateComponents    *adder;
    NSDate                *endDate, *workDate;
    NSInteger            max;
    
    components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:date];
    [components setDay:1];
    adder = [[NSDateComponents alloc] init];
    
    max = [[_formatter weekdaySymbols] count] * _weeksInMonth;
    workDate = [calendar dateFromComponents:components];
    [adder setDay:-[calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:workDate] + 1];
    workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    [adder setDay:max];
    endDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    [adder setDay:1];
    
    if (startDate) *startDate = workDate;
    if (endDateIn) *endDateIn = endDate;
}

- (NSDictionary *)titleAttributes
{
    if (_titleAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontBoldTrait];
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:18.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        _titleAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                            font, NSFontAttributeName,
                            [_view fontColor], NSForegroundColorAttributeName,
                            style, NSParagraphStyleAttributeName,
                            nil];
    }
    return _titleAttributes;
}

- (NSDictionary *)dayAttributes
{
    if (_dayAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:10.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        _dayAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                          font, NSFontAttributeName,
                          [_view dimmedFontColor], NSForegroundColorAttributeName,
                          style, NSParagraphStyleAttributeName,
                          nil];
    }
    return _dayAttributes;
}

- (NSDictionary *)dateAttributes
{
    if (_dateAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:12.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentRight];
        
        _dateAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                           font, NSFontAttributeName,
                           [_view fontColor], NSForegroundColorAttributeName,
                           style, NSParagraphStyleAttributeName,
                           nil];
    }
    return _dateAttributes;
}

- (NSDictionary *)dimDateAttributes
{
    if (_dimDateAttributes == nil) {
        NSFont                    *font = [_view font];
        NSMutableParagraphStyle    *style;
        
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:12.0];
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentRight];
        
        _dimDateAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                           font, NSFontAttributeName,
                           [_view gridColor], NSForegroundColorAttributeName,
                           style, NSParagraphStyleAttributeName,
                           nil];
    }
    return _dimDateAttributes;
}

- (NSMutableDictionary *)eventAttributesIncludeBullet:(BOOL)flag
{
    NSMutableDictionary        *eventAttributes;
    NSFont                    *font = [_view font];
    NSMutableParagraphStyle    *style;
    
    font = [[NSFontManager sharedFontManager] convertFont:font toSize:10.0];
    
    style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentLeft];
    [style setHyphenationFactor:1.0];
    [style setMaximumLineHeight:12.0];
    if (flag) {
        [style setHeadIndent:6.0];
    }

    eventAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       font, NSFontAttributeName,
                       [NSColor blackColor], NSForegroundColorAttributeName,
                       style, NSParagraphStyleAttributeName,
                       nil];
    
    return eventAttributes;
}

- (void)_computeWeeksInMonth
{
    NSDate                *date = [_view displayDate];
    NSCalendar            *calendar = [_view calendar];
    NSInteger            daysInMonth;
    NSInteger            firstWeek, lastWeek;
    NSDateComponents    *components;
    NSDate                *work;

    daysInMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    [components setDay:1];
    work = [calendar dateFromComponents:components];
    firstWeek = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitMonth forDate:work];
    _weekOfYear = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:work];
    [components setDay:daysInMonth];
    lastWeek = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitMonth forDate:[calendar dateFromComponents:components]];
    
    _weeksInMonth = lastWeek - firstWeek + 1;
    //AJRPrintf(@"%C: weeksInMonth: %d\n", self, _weeksInMonth);
}

- (NSRect)_rectForDate:(NSDate *)incoming inRect:(NSRect)bounds
{
    NSCalendar            *calendar = [_view calendar];
    NSArray                *weekdays;
    CGFloat                width;
    NSInteger            widthRemainder;
    CGFloat                height;
    NSInteger            heightRemainder;
    NSInteger            weekOfMonth;
    NSInteger            dayOfWeek;
    NSRect                rect = NSZeroRect;
    NSDateComponents    *components;

    weekdays = [_formatter weekdaySymbols];
//    width = rint(bounds.size.width / 7.0);
//    height = rint((bounds.size.height - 48.0) / (CGFloat)_weeksInMonth);
    width = floor(bounds.size.width / [weekdays count]);
    widthRemainder = (NSInteger)bounds.size.width % [weekdays count];
    height = floor((bounds.size.height - 48.0) / (CGFloat)_weeksInMonth);
    heightRemainder = (NSInteger)((CGFloat)_weeksInMonth * ((bounds.size.height - 48.0) / (CGFloat)_weeksInMonth - height));
    components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:incoming];
    dayOfWeek = [components weekday] - 1;
    weekOfMonth = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:incoming] - _weekOfYear;
    
    //AJRPrintf(@"%C: %d, %d, %d, %d\n", self, _weekOfYear, weekOfMonth, [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:incoming], widthRemainder);
    
    if (weekOfMonth < -2) {
        weekOfMonth = _weeksInMonth - 1;
    }
    
    rect.size.width = width + 1.0;
    if (dayOfWeek <= widthRemainder) {
        rect.size.width += 1.0;
    }
    rect.size.height = height + 1.0;
    if (weekOfMonth <= heightRemainder) {
        rect.size.height += 1.0;
    }
    rect.origin.x = bounds.origin.x - 1;
    for (NSInteger x = 0; x < dayOfWeek; x++) {
        rect.origin.x += width;
        if (x <= widthRemainder) {
            rect.origin.x += 1.0;
        }
    }
    rect.origin.y = bounds.origin.y + bounds.size.height - 48.0 - rect.size.height;
    for (NSInteger x = 0; x < weekOfMonth; x++) {
        rect.origin.y -= height;
        if (x <= heightRemainder) {
            rect.origin.y -= 1.0;
        }
    }

    return NSIntegralRect(rect);
}

- (NSRect)rectForDate:(NSDate *)incoming inRect:(NSRect)bounds
{
    [self _computeWeeksInMonth];
    return [self _rectForDate:incoming inRect:bounds];
}

- (void)layoutEventsForDate:(NSDate *)date inRect:(NSRect)rect
{
    BOOL                done = NO;
    BOOL                cleanUpY;
    NSArray                *dailyEvents = [self dailyEventsForDate:date];
    NSArray                *events = [self eventsForDate:date];
    CGFloat                eventTop;
    CGFloat                lineHeight;

    lineHeight = [[_eventListAttributes objectForKey:NSParagraphStyleAttributeName] maximumLineHeight];

    // This is the top of the first event.
    eventTop = rect.origin.y + rect.size.height;
    
    //AJRPrintf(@"%C: layout: %@, daily: %d, events: %d\n", self, date, [dailyEvents count], [events count]);
    
    // Now layout all the daily events.
    for (AJRCalendarEvent *event in dailyEvents) {
        NSRect        eventRect;
        NSRect        lastRect;

        // Compute the bounding rectangle.
        eventRect.origin.x = rect.origin.x + 1.0;
        eventRect.origin.y = eventTop - lineHeight;
        eventRect.size.width = rect.size.width - 2.0;
        eventRect.size.height = lineHeight;
        
        // Make sure the event actually fits in the day rectangle.
        if (eventRect.origin.y < rect.origin.y) break;
        
//        if ([[event title] isEqualToString:@"WWDC"]) {
//            AJRPrintf(@"%C: break here: %s:%d\n", self, __PRETTY_FUNCTION__, __LINE__);
//        }
        
        // See if we've already got hit rectangle, and that it's within our "week". If it is, then
        // we want to extend it out.
        lastRect = [event lastHitRect];
        if (!NSEqualRects(NSZeroRect, lastRect) && 
            lastRect.origin.y >= rect.origin.y && 
            lastRect.origin.y <= rect.origin.y + rect.size.height) {
            eventRect.origin.y = lastRect.origin.y;
        }
        
        // Save the rectangle
        [event addHitRectangle:eventRect];
        
        // Set what'll be displayed for this event onto the event
        [event setDisplayString:[event title]];
        
        // And advance to the next slot.
        eventTop -= (lineHeight + 1.0);
    }
    
    // Now we layout all the hourly events.
    for (AJRCalendarEvent *event in events) {
        NSString    *string;
        CGFloat        height;
        NSRect        eventRect;
        
        // Build the string to display. While we won't be displaying this yet, it allows us to know
        // the desired height of the event.
        string = AJRFormat(@"●%@", [event title]);
        // And store the string onto the event. This way, we don't have to keep regenerating it.
        [event setDisplayString:string];
        
        // Compute the height of the event
        height = [string sizeWithAttributes:_eventListAttributes constrainedToWidth:rect.size.width - 10.0].height;
        
        //AJRPrintf(@"%C: height: %.1f\n", self, height);

        // Compute the display rectangle.
        eventRect.origin.x = rect.origin.x;
        eventRect.origin.y = eventTop - height;
        eventRect.size.width = rect.size.width;
        eventRect.size.height = height;
        
        // Make sure the event actually fits in the day rectangle.
        if (eventRect.origin.y < rect.origin.y) break;
        
        // Save the rectangle
        [event addHitRectangle:eventRect];

        // And advance to the next event.
        eventTop -= height;
    }
    
    // This code selectively decreases the height of events until we can either fit all the events
    // in the day tile, or we've decreased all events to the height of one line.
    cleanUpY = NO;
    while (eventTop < rect.origin.y && !done) {
        NSInteger    x;
        
        done = YES;
        for (x = [events count] - 1; x >= 0 && eventTop < rect.origin.y; x--) {
            AJRCalendarEvent    *event = [events objectAtIndex:x];
            NSRect            eventRect = [event lastHitRect];
            if (eventRect.size.height > lineHeight) {
                eventRect.origin.y += lineHeight;
                eventRect.size.height -= lineHeight;
                [event clearHitRectangles];
                [event addHitRectangle:eventRect];
                eventTop += lineHeight;
                done = NO;
                cleanUpY = YES;
            }
        }
    }
    // See if we changed the height of any events. If we did, then we want to clean up the y
    // locations of the events. This is done separately from above, since it avoids doing a bunch
    // of extra work of constantly adjusting the Y locations each time through the loop. This allows
    // us to adjust the Y locations just once.
    if (cleanUpY) {
        NSInteger        x, max = [events count];
        AJRCalendarEvent    *previous = [events objectAtIndex:0];
        
        for (x = 1; x < max; x++) {
            NSRect            previousRect = [previous lastHitRect];
            AJRCalendarEvent    *event = [events objectAtIndex:x];
            NSRect            eventRect = [event lastHitRect];
            
            // The new Y location is the previous event's Y location, minus our height. Remember,
            // origin is lower left.
            eventRect.origin.y = previousRect.origin.y - eventRect.size.height;
            [event clearHitRectangles];
            // Only add our hit rect back in if our y fits within the day tile. If we don't add it
            // back in, then the event won't render.
            if (eventRect.origin.y > rect.origin.y) {
                [event addHitRectangle:eventRect];
            }
            
            previous = event;
        }
    }
}

/*
 * This method expects the events to have already been layed out by the layoutEventsForDate:inRect:
 * method. If the above hasn't been called, the events will be rendered into random locations.
 */
- (void)drawEvents
{
    for (AJRCalendarEvent *event in _events) {
        if ([event isAllDay]) {
            for (NSValue *eventValue in [event hitRects]) {
                NSRect            eventRect = [eventValue rectValue];
                NSString        *string = [event displayString];
                NSBezierPath    *path;
                
                if ([_view isEventSelected:[event event]]) {
                    [[[event calendar] color] set];
                } else {
                    [[[[event calendar] color] colorWithAlphaComponent:0.5] set];
                }
                path = [[NSBezierPath alloc] init];
                [path appendBezierPathWithRoundedRect:eventRect xRadius:6.0 yRadius:6.0];
                [path fill];
                
                [_eventAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
                eventRect.origin.x += 5.0;
                eventRect.size.width -= 10.0;
                if ([NSGraphicsContext currentContextDrawingToScreen]) {
                    eventRect.size.height -= 1.0;
                } else {
                    eventRect.size.height -= 0.25;
                }
                [string drawInRect:eventRect withAttributes:_eventAttributes];
            }
        }
    }
    
    for (AJRCalendarEvent *event in _events) {
        if (![event isAllDay]) {
            for (NSValue *rectValue in [event hitRects]) {
                NSRect        eventRect = [rectValue rectValue];
            
                NSString    *string = [event displayString];
                
                // If selected, then draw a background.
                if ([_view isEventSelected:[event event]]) {
                    [[[event calendar] color] set];
                    NSRectFill(eventRect);
                } else {
                    //[[[event calendar] color] set];
                    //NSFrameRect(eventRect);
                }
                
                if ([_view isEventSelected:[event event]]) {
                    [_eventListAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
                } else {
                    [_eventListAttributes setObject:[[event calendar] color] forKey:NSForegroundColorAttributeName];
                }
                eventRect.origin.x += 5.0;
                eventRect.size.width -= 10.0;
                if ([NSGraphicsContext currentContextDrawingToScreen]) {
                    eventRect.size.height -= 1.0;
                } else {
                    eventRect.size.height -= 0.25;
                }
                [string drawInRect:eventRect withAttributes:_eventListAttributes];
            }
        }
    }
}

- (void)drawBodyInRect:(NSRect)rect bounds:(NSRect)bounds
{
    NSDate                *date = [_view displayDate];
    NSDate                *selectedDate = [_view date];
    NSCalendar            *calendar = [_view calendar];
    NSString            *title;
    NSInteger            x, max;
    NSRect                dayRect;
    CGFloat                width;
    NSInteger            widthRemainder, dayOfWeek;
    NSArray                *weekdays;
    NSDateComponents    *components;
    NSDate                *workDate, *endDate;
    NSDateComponents    *adder;
    NSInteger            month;
    NSDate                *today = [NSDate date];
    
    // Compute some values we'll need while rendering
    [self _computeWeeksInMonth];
    weekdays = [_formatter weekdaySymbols];
    width = floor((bounds.size.width + 2) / 7.0);
    widthRemainder = (NSInteger)(bounds.size.width + 2) % [weekdays count];
    month = [calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:date];
    
    [[_view backgroundColor] set];
    NSRectFill(bounds);
    
    title = [_formatter stringFromDate:date];
    [title drawInRect:(NSRect){{bounds.origin.x, bounds.origin.y + bounds.size.height - 31.0}, {bounds.size.width, 24.0}} withAttributes:[self titleAttributes]];
    
    components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:date];
    dayOfWeek = [components weekday] - 1;
    dayRect.origin.x = bounds.origin.x - 1;
    dayRect.origin.y = bounds.origin.y + bounds.size.height - 45.0;
    dayRect.size.width = width + 1.0;
    dayRect.size.height = 12.0;
    x = 0;
    for (NSString *weekday in weekdays) {        
        [weekday drawInRect:dayRect withAttributes:[self dayAttributes]];

        dayRect.origin.x += dayRect.size.width;
        if (x == widthRemainder) {
            dayRect.size.width -= 1.0;
        }
        x++;
    }
    
    components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:date];
    [components setDay:1];
    adder = [[NSDateComponents alloc] init];
    
    max = [weekdays count] * _weeksInMonth;
    workDate = [calendar dateFromComponents:components];
    [adder setDay:-[calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:workDate] + 1];
    workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    [adder setDay:max];
    endDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    [adder setDay:1];
    
    [self updateEvents:NO];
    
    // Now that we've updated our events, let's make sure they have no hit rectangles from a previous
    // run.
    [self clearAllEventHitRectangles];
    
    for (x = 0; x < max; x++) {
        NSRect    rect = [self _rectForDate:workDate inRect:bounds];
        
        if ([self date:today equals:workDate]) {
            [[_view todayBackgroundColor] set];
            NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
        } else if ([self date:selectedDate equals:workDate]) {
            [[_view selectedBackgroundColor] set];
            NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
        }
        
        [[_view gridColor] set];
        NSFrameRect(rect);
        
        components = [calendar components:NSCalendarUnitDay fromDate:workDate];
        rect.size.height -= 2;
        rect.size.width -= 6;
        if (month == [calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:workDate]) {
            [AJRFormat(@"%d", [components day]) drawInRect:rect withAttributes:[self dateAttributes]];
        } else {
            [AJRFormat(@"%d", [components day]) drawInRect:rect withAttributes:[self dimDateAttributes]];
        }

        // Compute the portion of the day tile that contains events.
        rect.size.height -= 17.0;
        rect.size.width += 6.0;
        
        // Layout the events. This method computes the bounding rectangles of each event within
        // the bounding rectangle of the date.
        [self layoutEventsForDate:workDate inRect:rect];

        // Advance the date
        // Get the events we have occurring.
        workDate = [calendar dateByAddingComponents:adder toDate:workDate options:0];
    }
    // Now that we've drawn the whole calendar, and layed out all the events, let's draw our events.
    [self drawEvents];
    
    // See if we're printing, and if we are, do a little extra. Mostly, we just make sure to draw
    // our full border when printing.
    if (![NSGraphicsContext currentContextDrawingToScreen]) {
        NSRect    monthRect = bounds;
        
        [[_view gridColor] set];
        monthRect.size.height -= 48.0;
        NSFrameRect(NSInsetRect(monthRect, -1, 0));
    }
    
}

#pragma mark Hit detection

- (NSDate *)dateForPoint:(NSPoint)point inRect:(NSRect)rect
{
    NSCalendar            *calendar = [_view calendar];
    NSInteger            dayX, weekY;
    NSInteger            daysInWeek;
    NSInteger            dayInMonth;
    NSDateComponents    *components;
    NSDate                *date;
    NSInteger            weekdayOfFirst;
    
    // First, let's see if we're even in the "calendar" grid
    if (point.y > rect.origin.y + rect.size.height - 48.0) return nil;

    // Compute some values we're going to need to know.
    daysInWeek = 7; // Seems to not be working: [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:[_view date]].length;
    
    // OK, we're at least in the date grid, so let's get our x / y grid location.
    dayX = floor((double)daysInWeek * ((point.x - rect.origin.x) / rect.size.width));
    weekY = _weeksInMonth - floor((double)_weeksInMonth * ((point.y - rect.origin.y) / (rect.size.height - 48.0)))- 1;
    
    components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:[_view displayDate]];
    [components setDay:1];
    date = [calendar dateFromComponents:components];
    weekdayOfFirst = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:date];
    //AJRPrintf(@"%C: %@, %d\n", self, date, weekdayOfFirst);
    
    dayInMonth = weekY * daysInWeek + dayX + 2 - weekdayOfFirst;
    
    [components setDay:dayInMonth];
    date = [calendar dateFromComponents:components];
    
    //AJRPrintf(@"%C: %d x %d: %d: %@\n", self, dayX, weekY, dayInMonth, date);
    
    return date;
}

- (NSRect)getCalendarEvent:(AJRCalendarEvent **)calendarEvent
                   andDate:(NSDate **)date
                  forEvent:(NSEvent *)appKitEvent
                inBodyView:(NSView *)bodyView
{
    NSPoint        where;
    
    if (calendarEvent) *calendarEvent = nil;
    if (date) *date = nil;
    
    // First, scan and see if the point encounters any of our events
    where = [bodyView convertPoint:[appKitEvent locationInWindow] fromView:nil];
    for (AJRCalendarEvent *event in _events) {
        NSRect        hitRect;
        if (!NSEqualRects(NSZeroRect, hitRect = [event containsPoint:where]) && calendarEvent) {
            *calendarEvent = event;
            // Record the date, too, if the caller requested it.
            if (date) {
                *date = [self dateForPoint:where inRect:[bodyView bounds]];
            }
            return hitRect;
        }
    }
    
    // Nope, so we're going to try and see if we can find a date, if the caller wants it.
    if (date) {
        *date = [self dateForPoint:where inRect:[bodyView bounds]];
        if (*date) {
            // We found a date, so return the rectangle of that date.
            return [self rectForDate:*date inRect:[bodyView bounds]];
        }
    }
    
    return NSZeroRect;
}

@end
