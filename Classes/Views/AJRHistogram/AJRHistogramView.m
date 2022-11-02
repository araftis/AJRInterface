/*
 AJRHistogramView.m
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

#import "AJRHistogramView.h"

static NSString        *keys[] = {
    @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
    @"10", @"20", @"30", @"40", @"50", @"60", @"70", @"80", @"90",
    @"100", @"200", @"300", @"400", @"500", @"600", @"700", @"800", @"900",
    @"1000", @"2000", @"3000", @"4000", @"5000", @"6000", @"7000", @"8000", @"9000",
    @"10000", @"20000", @"30000", @"40000", @"50000", @"60000", @"70000", @"80000", @"90000",
    @"100000", @"200000", @"300000", @"400000", @"500000", @"600000", @"700000", @"800000", @"900000",
    @"1000000", @"2000000", @"3000000", @"4000000", @"5000000", @"6000000", @"7000000", @"8000000", @"9000000",
    @">= 10000000"
};
static NSInteger keyCount = sizeof(keys) / sizeof(NSString *);

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRHistogramView {
    NSInteger _maxBucket;
    long _maxCount;
    NSMenu *_menu;
}

+ (void)initialize {
    [self exposeBinding:@"statistics"];
}

- (void)_setup {
    self.labelFont = [NSFont fontWithName:@"Helvetica" size:11.0];
    self.SLA = -1;
    self.SLAColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
}

- (id)initWithFrame:(NSRect)frame  {
    if ((self = [super initWithFrame:frame])) {
        [self _setup];
        self.borderColor = [NSColor lightGrayColor];
        self.backgroundColor = [NSColor whiteColor];
    }
    return self;
}


- (void)awakeFromNib {
    [self _setup];
}

- (void)setLabelFont:(NSFont *)aFont {
    if (_labelFont != aFont) {
        _labelFont = aFont;
        [self setNeedsDisplay:YES];
    }
}

- (void)setSLA:(NSInteger)SLA {
    if (_SLA != SLA) {
        _SLA = SLA;
        [self setNeedsDisplay:YES];
    }
}

- (void)setSLAColor:(NSColor *)SLAColor {
    if (_SLAColor != SLAColor) {
        _SLAColor = SLAColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setBorderColor:(NSColor *)borderColor {
    if (borderColor != _borderColor) {
        _borderColor = borderColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (backgroundColor != _backgroundColor) {
        _backgroundColor = backgroundColor;
        [self setNeedsDisplay:YES];
    }
}

- (NSGradient *)gradientForColor:(NSColor *)input {
    CGFloat h,s,b,a;
    [[input colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
    s *= 0.9;
    b *= 0.8;
    return [[NSGradient alloc] initWithStartingColor:input endingColor:[NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a]];
}

- (void)drawRect:(NSRect)rect  {
    NSRect bounds = [self bounds];
    double xScale;
    double yScale;
    NSInteger x, label;
    unsigned long step;
    NSColor *reallyLightGray;
    double left;
    NSDictionary *fontAttributes;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    if (_maxCount < 10) step = 1;
    else if (_maxCount < 30) step = 3UL;
    else if (_maxCount < 50) step = 5UL;
    else if (_maxCount < 80) step = 8UL;
    else if (_maxCount < 100) step = 10UL;
    else if (_maxCount < 250) step = 25UL;
    else if (_maxCount < 500) step = 50UL;
    else if (_maxCount < 750) step = 75UL;
    else if (_maxCount < 1000) step = 100UL;
    else if (_maxCount < 2500) step = 250UL;
    else if (_maxCount < 5000) step = 500UL;
    else if (_maxCount < 7500) step = 750UL;
    else if (_maxCount < 10000) step = 1000UL;
    else if (_maxCount < 25000) step = 2500UL;
    else if (_maxCount < 50000) step = 5000UL;
    else if (_maxCount < 75000) step = 7500UL;
    else if (_maxCount < 100000) step = 10000UL;
    else if (_maxCount < 250000) step = 25000UL;
    else if (_maxCount < 500000) step = 50000UL;
    else if (_maxCount < 750000) step = 75000UL;
    else if (_maxCount < 1000000) step = 100000UL;
    else if (_maxCount < 2500000) step = 250000UL;
    else if (_maxCount < 5000000) step = 500000UL;
    else if (_maxCount < 7500000) step = 750000UL;
    else if (_maxCount < 10000000) step = 1000000UL;
    else if (_maxCount < 15000000) step = 1500000UL;
    else if (_maxCount < 20000000) step = 2000000UL;
    else if (_maxCount < 25000000) step = 2500000UL;
    else if (_maxCount < 30000000) step = 3000000UL;
    else if (_maxCount < 35000000) step = 3500000UL;
    else if (_maxCount < 40000000) step = 4000000UL;
    else if (_maxCount < 45000000) step = 4500000UL;
    else if (_maxCount < 50000000) step = 5000000UL;
    else if (_maxCount < 55000000) step = 5500000UL;
    else if (_maxCount < 60000000) step = 6000000UL;
    else if (_maxCount < 65000000) step = 6500000UL;
    else if (_maxCount < 70000000) step = 7000000UL;
    else if (_maxCount < 75000000) step = 7500000UL;
    else if (_maxCount < 80000000) step = 8000000UL;
    else if (_maxCount < 85000000) step = 8500000UL;
    else if (_maxCount < 90000000) step = 9000000UL;
    else if (_maxCount < 95000000) step = 9500000UL;
    else step = 10000000UL;
    
    if (_backgroundColor) {
        [_backgroundColor set];
        NSRectFill(bounds);
    }
    if (_borderColor) {
        [_borderColor set];
        NSFrameRect(bounds);
        bounds = NSInsetRect(bounds, 1.0, 1.0);
        NSRectClip(bounds);
    }
    
    fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:_labelFont, NSFontAttributeName, nil];
    left = [[NSString stringWithFormat:@"%ld", step * 10] sizeWithAttributes:fontAttributes].width + 10.0;
    xScale = (bounds.size.width - left) / (double)_maxBucket;
    yScale = bounds.size.height / (double)(_maxCount + step);
    
    reallyLightGray = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0/3.0];
    
    for (x = 0; x <= _maxBucket; x++) {
        NSInteger        count = [[_statistics objectForKey:keys[x]] intValue];
        NSRect            fill;
        NSGradient        *gradient;
        
        //        AJRPrintf(@"%C: bucket: %d, count: %d, height: %.0f, maxCount: %d, step: %d\n",
        //                 self,
        //                 x,
        //                 count,
        //                 (double)count * yScale,
        //                 _maxCount,
        //                 step);
        
        if (count != 0) {
            double        width;
            NSString    *drawString;
            long        time = [keys[x] unsignedLongValue];
            
            if (_SLA > 0 && _SLA >= time && _SLA <= [keys[x + 1] unsignedLongValue]) {
                [self.SLAColor  set];
                fill.origin.x = bounds.origin.x + left + (double)x * xScale;
                fill.origin.y = bounds.origin.y;
                fill.size.width = xScale;
                fill.size.height = bounds.size.height;
                NSRectFill(fill);
            }
            
            gradient = [self gradientForColor:[NSColor colorWithCalibratedHue:(1.0/3.0) - (((double)x / (double)keyCount) * (1.0/3.0)) saturation:1.0 brightness:1.0 alpha:1.0]];
            fill.origin.x = bounds.origin.x + left + (double)x * xScale;
            fill.origin.y = bounds.origin.y;
            fill.size.width = xScale;
            fill.size.height = (double)count * yScale;
            [gradient drawInRect:fill angle:315.0];
            
            [NSGraphicsContext saveGraphicsState];
            CGContextTranslateCTM(context, fill.origin.x, fill.size.height);
            CGContextRotateCTM(context, -M_PI / 2.0);
            [reallyLightGray set];
            
            if (time < 1000) {
                drawString = AJRFormat(@"%d ms", time);
            } else if (time < 60000) {
                drawString = AJRFormat(@"%d s", time / 1000);
            } else if (time < 3600000) {
                drawString = AJRFormat(@"%.1f m", (double)time / 60000.0);
            } else {
                drawString = AJRFormat(@"%.1f h", (double)time / 3600000.0);
            }
            
            width = [drawString sizeWithAttributes:fontAttributes].width;
            if (width > fabs(fill.size.height) - 6.0) {
                CGContextTranslateCTM(context, -(width + 6.0), 0.0);
            }
            [drawString drawAtPoint:(NSPoint){3, 0} withAttributes:fontAttributes];
            [NSGraphicsContext restoreGraphicsState];
        }
    }
    
    reallyLightGray = [NSColor colorWithCalibratedWhite:0.0 alpha:0.1];
    
    label = step;
    for (x = 1; x < 10; x++) {
        double y = label * yScale;
        double width;
        NSString *string = [NSString stringWithFormat:@"%ld", label];
        
        [[NSColor lightGrayColor] set];
        width = [string sizeWithAttributes:fontAttributes].width;
        [string drawAtPoint:(NSPoint){left - 6.0 - width, round(y - [self.labelFont capHeight])} withAttributes:fontAttributes];
        [reallyLightGray set];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, bounds.origin.x + left, round(y) - 0.5);
        CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, round(y) - 0.5);
        CGContextStrokePath(context);
        label += step;
    }
}

- (void)setStatistics:(NSDictionary *)someStatistics {
    NSInteger x;
    
    if (_statistics != someStatistics) {
        _statistics = someStatistics;
    }
    
    _maxCount = 0;
    _maxBucket = -1;
    for (x = keyCount - 1; x >= 0; x--) {
        long        count = [[_statistics objectForKey:keys[x]] longValue];
        if (count && _maxBucket == -1) {
            _maxBucket = x;
        }
        if (count > _maxCount) _maxCount = count;
    }
    if (_maxBucket == -1) _maxBucket = 17;
    
    [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped {
    return NO;
}

- (NSMenu *)menu {
    if (_menu == nil) {
        _menu = [[NSMenu alloc] initWithTitle:@"Histogram Settings"];
        [_menu addItemWithTitle:@"Copy as TSV" action:@selector(copyAsTSV:) keyEquivalent:@""];
        [[[_menu itemArray] lastObject] setTarget:self];
        [_menu addItemWithTitle:@"Copy as Image" action:@selector(copyAsImage:) keyEquivalent:@""];
        [[[_menu itemArray] lastObject] setTarget:self];
    }
    
    return _menu;
}

- (IBAction)copyAsTSV:(id)sender {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSMutableString *string = [NSMutableString string];
    NSInteger x;
    
    [pb declareTypes:@[NSPasteboardTypeString, NSPasteboardTypeTabularText] owner:self];
    
    for (x = 0; x < keyCount; x++) {
        [string appendFormat:@"%@\t%@\n", keys[x], [_statistics objectForKey:keys[x]]];
    }
    
    [pb setString:string forType:NSPasteboardTypeString];
    [pb setString:string forType:NSPasteboardTypeTabularText];
}

- (IBAction)copyAsImage:(id)sender {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSBitmapImageRep *imageRep;
    
    [pb declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF, nil] owner:self];

    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:imageRep];

    [pb setData:[imageRep TIFFRepresentation] forType:NSPasteboardTypeTIFF];
    
}

@end
