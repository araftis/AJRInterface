/*
 AJRPieChart.m
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

#import "AJRPieChart.h"

#import "NSColor+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

static NSMutableArray    *_defaultColors = nil;

@implementation AJRPieChart

+ (void)initialize {
    if (_defaultColors == nil) {
        _defaultColors = [[NSMutableArray alloc] init];
        [_defaultColors addObject:[NSColor redColor]];
        [_defaultColors addObject:[NSColor orangeColor]];
        [_defaultColors addObject:[NSColor yellowColor]];
        [_defaultColors addObject:[NSColor greenColor]];
        [_defaultColors addObject:[NSColor cyanColor]];
        [_defaultColors addObject:[NSColor blueColor]];
        [_defaultColors addObject:[NSColor purpleColor]];
        [_defaultColors addObject:[NSColor magentaColor]];
    }
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _keys = [[NSMutableArray alloc] init];
        _values = [[NSMutableDictionary alloc] init];
        _displayValues = [[NSMutableDictionary alloc] init];
        _colors = [[NSMutableDictionary alloc] init];
        _backgroundColor = [NSColor lightGrayColor];
        _backgroundLabel = @"";
        _attributes = [[NSMutableDictionary alloc] init];
        [_attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        _boldAttributes = [[NSMutableDictionary alloc] init];
        [_boldAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        self.font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
        _valueFormatter = [[NSNumberFormatter alloc] init];
        _currentColor = 0;
        _showKey = YES;
        _showValues = YES;
    }
    return self;
}


@synthesize showKey = _showKey;
@synthesize showValues = _showValues;

@synthesize backgroundColor = _backgroundColor;

- (void)setBackgroundColor:(NSColor *)value {
    if (_backgroundColor != value) {
        _backgroundColor = value;
        [self setNeedsDisplay:YES];
    }
}


@synthesize backgroundLabel = _backgroundLabel;

- (void)setBackgroundLabel:(NSString *)backgroundLabel {
    if (_backgroundLabel != backgroundLabel) {
        _backgroundLabel = backgroundLabel;
        [self setNeedsDisplay:YES];
    }
}

@synthesize totalValue = _totalValue;

- (void)setTotalValue:(double)value {
    if (_totalValue != value) {
        _totalValue = value;
        [self setNeedsDisplay:YES];
    }
}

@synthesize valueFormatter = _valueFormatter;

- (void)setValueFormatter:(NSFormatter *)formatter {
    if (_valueFormatter != formatter) {
        _valueFormatter = formatter;
    }
}

@synthesize font = _font;

- (void)setFont:(NSFont *)font {
    if (font != _font) {
        _font = font;
        [_attributes setObject:_font forKey:NSFontAttributeName];
        [_boldAttributes setObject:[[NSFontManager sharedFontManager] convertFont:_font toHaveTrait:NSBoldFontMask] forKey:NSFontAttributeName];
    }
}

- (void)addValue:(CGFloat)value forKey:(NSString *)key {
    [self addValue:value forKey:key withColor:[_defaultColors objectAtIndex:_currentColor]];
    _currentColor = (_currentColor + 1) % [_defaultColors count];
}

- (void)addValue:(CGFloat)value forKey:(NSString *)key withColor:(NSColor *)color {
    if (![_keys containsObject:key]) {
        [_keys addObject:key];
    }
    [self setFloatValue:value forKey:key];
    [self setColor:color forKey:key];
    [self setNeedsDisplay:YES];
}

- (void)removeKey:(NSString *)key {
    if ([_keys containsObject:key]) {
        [_keys removeObject:key];
        [_values removeObjectForKey:key];
        [_colors removeObjectForKey:key];
        [self setNeedsDisplay:YES];
    }
}

- (NSColor *)colorForKey:(NSString *)key {
    return [_colors objectForKey:key];
}

- (void)setColor:(NSColor *)color forKey:(NSString *)key {
    [_colors setObject:color forKey:key];
    [self setNeedsDisplay:YES];
}

- (double)floatValueForKey:(NSString *)key {
    return [[_values objectForKey:key] doubleValue];
}

- (void)setFloatValue:(double)value forKey:(NSString *)key {
    [_values setObject:[NSNumber numberWithDouble:value] forKey:key];
    [self setNeedsDisplay:YES];
}

- (double)displayValueForKey:(NSString *)key {
    return [[_displayValues objectForKey:key] doubleValue];
}

- (void)setDisplayValue:(double)value forKey:(NSString *)key {
    [_displayValues setObject:[NSNumber numberWithDouble:value] forKey:key];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    NSPoint center;
    NSBezierPath *path;
    NSBezierPath *wedge;
    CGFloat radius = rint((bounds.size.width > bounds.size.height ? bounds.size.height : bounds.size.width) / 2.0) - 5.0;
    NSInteger x;
    CGFloat angle;
    NSShadow *shadow;
    CGFloat lineHeight;

    center.x = radius + 5.0;
    center.y = rint(bounds.origin.y + bounds.size.height / 2.0) + 2.0;
    
    path = [[NSBezierPath alloc] init];
    [path setLineCapStyle:NSLineCapStyleRound];

    [path moveToPoint:(NSPoint){center.x + radius, center.y}];
    [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:0.0 endAngle:360.0];
    [path closePath];
    
    shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:(NSSize){0.0, -2.0}];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor darkGrayColor]];
    //[_attributes setObject:shadow forKey:NSShadowAttributeName];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [[NSColor blackColor] set];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
    [path setLineWidth:1.5];
    [[self.backgroundColor gradient] drawInBezierPath:path angle:310.0];
    [[NSColor blackColor] set];
    [path stroke];
    
    wedge = [[NSBezierPath alloc] init];
    [wedge setLineCapStyle:NSLineCapStyleRound];
    angle = 0;
    if (_totalValue >= 0.0) {
        for (x = 0; x < [_keys count]; x++) {
            NSString *key = [_keys objectAtIndex:x];
            CGFloat value = [self floatValueForKey:key];
            CGFloat endAngle = angle + 360.0 * (value / _totalValue);
            
            if (angle >= 0.0 && angle <= 360.0 && endAngle >= 0.0 && endAngle <= 360.0) {
                [wedge removeAllPoints];
                if (fabs(endAngle - angle) >= 360.0) {
                    [wedge moveToPoint:(NSPoint){cos(angle / (2.0 * M_PI)) * radius + center.x, sin(angle / (2.0 * M_PI)) * radius + center.y}];
                } else {
                    [wedge moveToPoint:center];
                }
                [wedge appendBezierPathWithArcWithCenter:center radius:radius startAngle:angle endAngle:endAngle];
                [wedge closePath];
                [[[_colors objectForKey:key] gradient] drawInBezierPath:wedge angle:310.0];
                [[NSColor blackColor] set];
                [wedge stroke];
                
                angle = endAngle;
            }
        }
    }

    lineHeight = [_font capHeight] - [_font descender] + [_font leading];
    angle = bounds.origin.y + bounds.size.height - lineHeight;
    for (x = 0; x <= [_keys count]; x++) {
        NSString *key;
        NSRect colorRect;
        NSNumber *value;
        NSString *displayString;
        NSSize displaySize;
        NSGradient *gradient;

        if (x == [_keys count]) {
            key = _backgroundLabel;
            value = [NSNumber numberWithDouble:_totalValue];
            gradient = [self.backgroundColor gradient] ;
        } else {
            key = [_keys objectAtIndex:x];
            value = [_displayValues objectForKey:key];
            if (value == nil) {
                value = [_values objectForKey:key];
            }
            gradient = [[_colors objectForKey:key] gradient];
        }
        displayString = [_valueFormatter stringForObjectValue:value];
        
        colorRect.size.width = rint(radius * 0.50);
        colorRect.origin.x = (bounds.origin.x + bounds.size.width) - colorRect.size.width - 2.0;
        colorRect.origin.y = angle;
        colorRect.size.height = lineHeight - 2.0;
        colorRect = NSIntegralRect(colorRect);
        [NSGraphicsContext saveGraphicsState];
        [shadow set];
        [[NSColor blackColor] set];
        NSRectFill(colorRect);
        [NSGraphicsContext restoreGraphicsState];
        [gradient drawInRect:colorRect angle:310.0];
        [[NSColor blackColor] set];
        NSFrameRect(colorRect);
        
        displaySize = [key sizeWithAttributes:_boldAttributes];
        [key drawAtPoint:(NSPoint){colorRect.origin.x - displaySize.width - 5.0, angle + [_font descender]} withAttributes:_boldAttributes];
        
        angle -= (lineHeight + 2.0);
        
        if (_showValues) {
            displaySize = [displayString sizeWithAttributes:_attributes];
            [displayString drawAtPoint:(NSPoint){colorRect.origin.x + colorRect.size.width - displaySize.width, angle + [_font descender]} withAttributes:_attributes];
            angle -= (lineHeight + 2.0);
        }
    }
    
}

@end
