/*
AJRSparklineRenderer.m
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
//
//  AJRSparklineRenderer.m
//  Ellipsis
//
//  Created by Gregor Purdy on 2008-07-23.
//  Copyright 2008 Apple Inc. All rights reserved.
//

#import "AJRSparklineRenderer.h"

#import <AJRFoundation/AJRSparklineChart.h>

//
// Basics:
//

static const double PI = 3.141592657;

static const double MINIMUM_MARGIN = 3.0;
static const double MAXIMUM_MARGIN = 8.0;

static const double DOT_RADIUS_FACTOR = 0.3;
static const double LINE_WIDTH_FACTOR = 0.2;

//
// Other:
//

static const long NO_HEIGHT = -1;
static const size_t NO_INDEX = -1;
static const long NO_WIDTH = -1;

//
// Implementation:
//

@implementation AJRSparklineRenderer

@synthesize includeEntireRange = _includeEntireRange;
@synthesize marginFactor = _marginFactor;
@synthesize backgroundColor = _backgroundColor;
@synthesize endDotColor = _endDotColor;
@synthesize extremaColor = _extremaColor;
@synthesize seriesColor = _seriesColor;
@synthesize errorRangeColor = _errorRangeColor;
@synthesize warnRangeColor = _warnRangeColor;
@synthesize nominalRangeColor = _nominalRangeColor;
@synthesize numberFormatter = _numberFormatter;

static CGFloat whiteRGBValues []     = {           1.0,           1.0,           1.0, 1.0 };
static CGFloat lightGrayRGBValues [] = { 212.0 / 255.0, 212.0 / 255.0, 212.0 / 255.0, 1.0 };
static CGFloat darkGrayRGBValues []  = {  16.0 / 255.0,  16.0 / 255.0,  16.0 / 255.0, 1.0 };

static CGFloat lightRedRGBValues []  = { 219.0 / 255.0,  79.0 / 255.0,  81.0 / 255.0, 1.0 };
static CGFloat darkRedRGBValues []   = { 192.0 / 255.0,  32.0 / 255.0,  32.0 / 255.0, 1.0 };

static CGFloat blueRGBValues []      = {  32.0 / 255.0, 160.0 / 255.0, 255.0 / 255.0, 1.0 };

static CGFloat yellowRGBValues []    = { 242.0 / 255.0, 173.0 / 255.0,  24.0 / 255.0, 1.0 };

- (id)initWithMarginFactor:(CGFloat)aMarginFactor
{
    self = [super init];
    if (self) {        
        _includeEntireRange = false;
        _marginFactor = aMarginFactor;
        
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
        
        _backgroundColor = CGColorCreate(cs, whiteRGBValues);
        
        _endDotColor = CGColorCreate(cs, darkRedRGBValues);
        _extremaColor = CGColorCreate(cs, blueRGBValues);
        
        _seriesColor = CGColorCreate(cs, darkGrayRGBValues);
        
        _errorRangeColor = CGColorCreate(cs, lightRedRGBValues);
        _warnRangeColor = CGColorCreate(cs, yellowRGBValues);
        _nominalRangeColor = CGColorCreate(cs, lightGrayRGBValues);
        
        self.numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.maximumFractionDigits = 2;
        _numberFormatter.alwaysShowsDecimalSeparator = NO;
    }
    
    return self;
}

- (void)dealloc
{
    CGColorRelease(_backgroundColor);
    
    CGColorRelease(_endDotColor);
    CGColorRelease(_extremaColor);
    
    CGColorRelease(_seriesColor);
    
    CGColorRelease(_errorRangeColor);
    CGColorRelease(_warnRangeColor);
    CGColorRelease(_nominalRangeColor);
    
    self.numberFormatter = nil;
    
    [super dealloc];
}

- (CGFloat)marginForBounds:(CGRect)bounds {
    const CGFloat tempWidthMargin = bounds.size.width / _marginFactor;
    const CGFloat tempHeightMargin = bounds.size.height / _marginFactor;
    
    const CGFloat tempMargin = MIN(tempWidthMargin, tempHeightMargin);
    
    return (tempMargin >= MINIMUM_MARGIN) ? (tempMargin <= MAXIMUM_MARGIN ? tempMargin : MAXIMUM_MARGIN) : MINIMUM_MARGIN;
}

- (CGFloat)dotRadiusForMargin:(CGFloat)margin {
    return margin * DOT_RADIUS_FACTOR;
}

- (CGFloat)lineWidthForMargin:(CGFloat)margin {
    return margin * LINE_WIDTH_FACTOR;
}

- (CGRect)bodyRectForBounds:(CGRect)bounds andMargin:(CGFloat)margin {
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;    

    if (_includeEntireRange) {
        x = bounds.origin.x + (1.0 * margin);
        y = bounds.origin.y + (1.0 * margin);
        width = bounds.size.width - (2.0 * margin);
        height = bounds.size.height - (2.0 * margin);    
    }
    else {
        x = bounds.origin.x + margin;
        y = bounds.origin.y + margin;
        width = bounds.size.width - (2.0 * margin);
        height = bounds.size.height - (2.0 * margin);    
    }
    
    return CGRectMake(x, y, width, height);
}

- (double)xFactorForBodyWidth:(CGFloat)bodyWidth sampleCount:(NSInteger)sampleCount {
    return (double) bodyWidth / (double) sampleCount;
}

- (double)yFactorForBodyHeight:(CGFloat)bodyHeight graphMin:(double)graphMin graphMax:(double)graphMax {
    return (double) bodyHeight / (graphMax - graphMin);
}

- (CGFloat)transformHeight:(double)height forYFactor:(double)yFactor {
    return yFactor * height;
}

- (CGFloat)transformWidth:(double)width forXFactor:(double)xFactor {
    return xFactor * width;
}

- (CGFloat)transformX:(double)x forBodyX:(CGFloat)bodyX andXFactor:(double)xFactor {
    const double temp = bodyX + xFactor * x;
    
    if (isnan(temp)) {
        @throw [NSException exceptionWithName:@"NotANumber" reason:@"Unable to transform data set X value to view X coordinate: result was NaN" userInfo:nil];
    }
    
    return temp;
}

- (CGFloat)transformY:(double)y forBodyY:(CGFloat)bodyY andYFactor:(double)yFactor graphMin:(double)graphMin{
    const double temp = bodyY + yFactor * (y - graphMin);
    
    if (isnan(temp)) {
        @throw [NSException exceptionWithName:@"NotANumber" reason:@"Unable to transform data set Y value to view Y coordinate: result was NaN" userInfo:nil];
    }
    
    return temp;
}

- (void)drawInBounds:(CGRect)bounds
            graphMin:(double)graphMin
            graphMax:(double)graphMax
         sampleCount:(NSInteger)sampleCount
         withContext:(CGContextRef)ctx
          dotAtIndex:(size_t)index
               value:(double)value
               color:(CGColorRef)color
          withWedges:(BOOL)withWedges
{
    CGFloat margin = [self marginForBounds:bounds];
    CGFloat dotRadius = [self dotRadiusForMargin:margin];
    CGRect bodyRect = [self bodyRectForBounds:bounds andMargin:margin];
    double xFactor = [self xFactorForBodyWidth:bodyRect.size.width sampleCount:sampleCount];
    double yFactor = [self yFactorForBodyHeight:bodyRect.size.height graphMin:graphMin graphMax:graphMax];
    
    double x = [self transformX:index forBodyX:bodyRect.origin.x andXFactor:xFactor];
    double y = [self transformY:value forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];
    double r = dotRadius;
    
    if (isnan(x)) {
        @throw [NSException exceptionWithName:@"NAN" reason:@"Computed x value turned out to be NAN" userInfo:NULL];
    }
    
    if (isnan(y)) {
        @throw [NSException exceptionWithName:@"NAN" reason:@"Computed y value turned out to be NAN" userInfo:NULL];
    }
    
    CGContextSetFillColorWithColor(ctx, color);
    
    const double wedgeSize = margin + dotRadius;
    
    if (value > graphMax) {
        if (withWedges) {
            CGContextSaveGState(ctx);
            
            CGContextSetStrokeColorWithColor(ctx, _backgroundColor);
            CGContextSetLineJoin(ctx, kCGLineJoinMiter);
            
            // a: bottom (tip)
            // b: upper-left
            // c: upper-right
            
            const double ax = x;
            const double ay = (bounds.origin.y + bounds.size.height) - wedgeSize;
            
            const double bx = ax - (wedgeSize * 0.5);
            const double by = ay + wedgeSize;
            
            const double cx = bx + wedgeSize;
            const double cy = by;
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, ax, ay);
            CGPathAddLineToPoint(path, NULL, bx, by);
            CGPathAddLineToPoint(path, NULL, cx, cy);
            CGPathCloseSubpath(path);
            
            CGContextAddPath(ctx, path);
            
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGPathRelease(path);
            
            CGContextRestoreGState(ctx);
        }
    } else if (value < graphMin) {
        if (withWedges) {
            CGContextSaveGState(ctx);
            
            CGContextSetStrokeColorWithColor(ctx, _backgroundColor);
            CGContextSetLineJoin(ctx, kCGLineJoinMiter);
            
            // a: top (tip)
            // b: lower-left
            // c: lower-right
            
            const double ax = x;
            const double ay = bounds.origin.y + wedgeSize;
            
            const double bx = ax - (wedgeSize * 0.5);
            const double by = ay - wedgeSize;
            
            const double cx = bx + wedgeSize;
            const double cy = by;
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, ax, ay);
            CGPathAddLineToPoint(path, NULL, bx, by);
            CGPathAddLineToPoint(path, NULL, cx, cy);
            CGPathCloseSubpath(path);
            
            CGContextAddPath(ctx, path);
            
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGPathRelease(path);
            
            CGContextRestoreGState(ctx);
        }
    } else {
        CGContextAddArc(ctx, x, y, r, 0, 2.0 * PI, false);
        CGContextFillPath(ctx);
    }    
}

- (void)drawInBounds:(CGRect)bounds
            graphMin:(double)graphMin
            graphMax:(double)graphMax
         sampleCount:(NSInteger)sampleCount
         withContext:(CGContextRef)ctx
         sampleArray:(double *)samples
              length:(size_t)length
               color:(CGColorRef)color
          withWedges:(BOOL)withWedges
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    bool nextIsMoveTo = true;
    
    CGFloat margin = [self marginForBounds:bounds];
    CGRect bodyRect = [self bodyRectForBounds:bounds andMargin:margin];
    double xFactor = [self xFactorForBodyWidth:bodyRect.size.width sampleCount:sampleCount];
    double yFactor = [self yFactorForBodyHeight:bodyRect.size.height graphMin:graphMin graphMax:graphMax];
    
    for (size_t i = 0; i < length; ++i) {
        if (isnan(samples[i])) {
            nextIsMoveTo = true;
            continue;
        }
        
        const double tx = [self transformX:i forBodyX:bodyRect.origin.x andXFactor:xFactor];
        const double ty = [self transformY:samples[i] forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];
        
        if (nextIsMoveTo) {
            CGPathMoveToPoint(path, NULL, tx, ty);
            nextIsMoveTo = false;
        } else {
            CGPathAddLineToPoint(path, NULL, tx, ty);
        }
    }
    
    CGFloat lineWidth = [self lineWidthForMargin:margin];
    
    CGContextAddPath(ctx, path);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, _seriesColor);
    CGContextStrokePath(ctx);
    
    CGPathRelease(path);
    
    //
    // Draw the endpoint dots:
    //
    
    for (size_t i = 0; i < length; ++i) {
        if (isnan(samples[i])) {
            // There is no data at the point, so it should not have a (segment) endpoint dot. It is not on a
            // segment.
            continue;
        }
        
        if ((i == 0) || (i == (length - 1))) {
            // The code below looks behind and ahead one point, so we have to make sure this is not the point
            // on the very ends. If the data set has data there, the start and end dots will draw there anyway.
            continue;
        }
        
        if (isnan(samples[i - 1]) || isnan(samples[i + 1])) {
            [self drawInBounds:bounds graphMin:graphMin graphMax:graphMax sampleCount:sampleCount withContext:ctx dotAtIndex:i value:samples[i] color:color withWedges:withWedges];
        }
    }    
}

- (CGColorRef)rangeColorForChart:(AJRSparklineChart *)chart {
    switch (chart.ajrsessment) {
        case SDA_ERROR:
            return _errorRangeColor;
            break;
        case SDA_WARN:
            return _warnRangeColor;
            break;
        case SDA_NOMINAL:
        default:
            return _nominalRangeColor;
            break;
    }
}

- (void)drawChart:(AJRSparklineChart *)chart inBounds:(CGRect)bounds withContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    
    //
    // Convert from positive-y-axis-down to positive-y-axis-up and adjust the bounds rect to have
    // zero origin and desired size in the new coordinate system.
    //
    
    CGContextTranslateCTM(ctx, bounds.origin.x, bounds.origin.y + bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    bounds = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    
    //
    // Clear out the background
    //
    
    CGContextSetFillColorWithColor(ctx, _backgroundColor);    
    CGContextFillRect(ctx, bounds);

    //
    // Bail out if nothing to draw:
    //
    
    if (chart == nil) {
        CGContextRestoreGState(ctx);
        return;
    }
    
    if (chart.series.length < 1) {
        CGContextRestoreGState(ctx);
        return;
    }
    
    //
    // Base the graph's y range on a combination of:
    // * rangeMax and rangeMin (the "normal" range expected by the caller, if any)
    // * graphMax and graphMin (the actual observed maximum and minimum values)
    // * mainMax and mainMin (two standard deviations either side of the median)
    //
    // First, we choose as our maximum value the maximum of rangeMax and mainMax.
    // Then, we choose as our minimum value the maximum of dataMin and mainMin
    //
    
    double graphMin;
    double graphMax;
    
    if (chart.hasRange && _includeEntireRange) {
        if (chart.rangeMax > chart.max) {
            graphMax = chart.rangeMax;
        } else {
            graphMax = chart.max;
        }
        
        if (chart.rangeMin < chart.min) {
            graphMin = chart.rangeMin;
        } else {
            graphMin = chart.min;
        }
    } else {
        graphMax = chart.max;
        graphMin = chart.min;
    }
    
    if (isnan(graphMin) && isnan(graphMax)) {
        graphMin = 1.0f;
        graphMax = 1.0f;
    } else if (isnan(graphMin)) {
        graphMin = graphMax;
    } else if (isnan(graphMax)) {
        graphMax = graphMin;
    }
    
    if (graphMin == graphMax) { // Prevents divide-by-zero below
        graphMin = graphMin - 0.5f;
        graphMax = graphMax + 0.5f;
    }
    
    //
    // Adjust y axis to even power-of-ten:
    //
    
    double unit = pow(10, floor(log10(graphMax))); // Power of 10 generally one below magnitude of max value
    NSInteger factor = ceil(graphMax / unit); // How many of those needed on the chart to cover all values.
    if (factor < 4) { // If too few, go to one lower power of 10
        unit /= 2.0;
        factor = ceil(graphMax / unit);
    }
    graphMax = unit * factor;
    if (_includeEntireRange) {
        graphMin = 0.0;
    }
    
//    NSLog(@"GraphMin = %g", graphMin);
//    NSLog(@"GraphMax = %g", graphMax);
    
    //
    // Compute some numbers we'll need.
    //
    
    NSInteger sampleCount = chart.series.length - 1;
    
    CGFloat margin = [self marginForBounds:bounds];
    CGRect bodyRect = [self bodyRectForBounds:bounds andMargin:margin];
    double xFactor = [self xFactorForBodyWidth:bodyRect.size.width sampleCount:sampleCount];
    double yFactor = [self yFactorForBodyHeight:bodyRect.size.height graphMin:graphMin graphMax:graphMax];
    
    //
    // Draw the range rect:
    //
    
    if (!(isnan(chart.rangeMin) || isnan(chart.rangeMax))) {
        double drawRangeMin = MAX(graphMin, chart.rangeMin);
        double drawRangeMax = MIN(graphMax, chart.rangeMax);
        
//        CGFloat x = bounds.origin.x; // not [self transformX:0.0] because we want the whole width.
        CGFloat x = [self transformX:0.0 forBodyX:bodyRect.origin.x andXFactor:xFactor];
        CGFloat y = [self transformY:drawRangeMin forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];
//        CGFloat width = bounds.size.width; // not [self transformWidth:chart.series.length] because we want the whole width.
        CGFloat width = [self transformWidth:chart.series.length forXFactor:xFactor];
        CGFloat height = [self transformHeight:(drawRangeMax - drawRangeMin) forYFactor:yFactor];
        const CGRect rect = CGRectMake(x, y, width, height);
        
        CGContextSetFillColorWithColor(ctx, [self rangeColorForChart:chart]);
        CGContextFillRect(ctx, rect);
        
        if ((chart.rangeMin >= graphMin) && (chart.rangeMin <= graphMax)) {
            CGFloat y2 = [self transformY:chart.rangeMin forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];

            CGContextSaveGState(ctx);
            
            CGContextSetStrokeColorWithColor(ctx, _endDotColor);
            CGPoint segment[] = { {x, y2}, {x + width, y2} };
            CGContextStrokeLineSegments(ctx, segment, 2);
            
            CGContextRestoreGState(ctx);
        }
        
        if ((chart.rangeMax >= graphMin) && (chart.rangeMax <= graphMax)) {
            CGFloat y2 = [self transformY:chart.rangeMax forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];

            CGContextSaveGState(ctx);

            CGContextSetStrokeColorWithColor(ctx, _endDotColor);
            CGPoint segment[] = { {x, y2}, {x + width, y2} };
            CGContextStrokeLineSegments(ctx, segment, 2);
            
            CGContextRestoreGState(ctx);
        }
        
        //
        // Construction lines
        //
        
        //            CGColorRef pureRed = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0);
        //            CGColorRef pureGreen = CGColorCreateGenericRGB(0.0, 1.0, 0.0, 1.0);            
        
        //            CGContextSetStrokeColorWithColor(ctx, pureRed);
        //            CGPoint segment1[] = { {x, y}, {x + width, y} };
        //            CGContextStrokeLineSegments(ctx, segment1, 2);
        
        //            CGContextSetStrokeColorWithColor(ctx, pureGreen);
        //            CGPoint segment2[] = { {x, y + height}, {x + width, y + height} };
        //            CGContextStrokeLineSegments(ctx, segment2, 2);
        
        //            CGColorRelease(pureRed);
        //            CGColorRelease(pureGreen);
    }
    
    //
    // Draw the x axis:
    //
    
    if (_includeEntireRange) {
        CGFloat x = [self transformX:0.0 forBodyX:bodyRect.origin.x andXFactor:xFactor] - [self dotRadiusForMargin:margin];
        CGFloat y = [self transformY:0.0 forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];
        CGFloat width = [self transformWidth:chart.series.length forXFactor:xFactor] + (2.0 * [self dotRadiusForMargin:margin]);

        CGContextSaveGState(ctx);
        CGContextSetStrokeColorWithColor(ctx, _seriesColor);
        CGPoint segment[] = { {x, y}, {x + width, y} };
        CGContextStrokeLineSegments(ctx, segment, 2);
        
        for (NSInteger i = 5; i < chart.series.length; i = i + 5) {
            CGFloat x = [self transformX:(double)i forBodyX:bodyRect.origin.x andXFactor:xFactor];
            CGFloat height = [self dotRadiusForMargin:margin];
            CGPoint segment2[] = { {x, y}, {x, y - height} };
            CGContextStrokeLineSegments(ctx, segment2, 2);
        }
        
        CGContextRestoreGState(ctx);
    }
    
    //
    // Draw the y axis:
    //

    if (_includeEntireRange) {
        CGContextSaveGState(ctx);
        
        //
        // Cross lines:
        //
        
        CGContextSetStrokeColorWithColor(ctx, _seriesColor);
        for (NSInteger i = 1; (i * unit) < graphMax; ++i) {
            CGFloat x = [self transformX:0.0 forBodyX:bodyRect.origin.x andXFactor:xFactor] - [self dotRadiusForMargin:margin];
            CGFloat y = [self transformY:(i * unit) forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin];
            CGFloat width = [self transformWidth:chart.series.length forXFactor:xFactor] + [self dotRadiusForMargin:margin];
            
            CGPoint segment2[] = { {x, y}, {x + width, y} };

            CGContextSetStrokeColorWithColor(ctx, _nominalRangeColor);
            CGContextStrokeLineSegments(ctx, segment2, 2);
            
            // Does not show. Probably because the coordinate system is messed with above. That could be throwing off
            // the rendering of the font
            
//            NSString * label = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:(i * unit)]];
//            CGContextSetStrokeColorWithColor(ctx, _seriesColor);
//            UIFont * font = [UIFont systemFontOfSize:18.0];
//            CGSize labelSize = [label sizeWithFont:font];
//            CGPoint labelPoint = CGPointMake(x - labelSize.width - [self dotRadiusForMargin:margin], y + (labelSize.height / 2.0));
//            [label drawAtPoint:labelPoint withFont:font];
//            NSLog(@"Drawing '%@' at (%f, %f) with Font '%@' of size %f...", label, labelPoint.x, labelPoint.y, font.familyName, font.pointSize);
        }
        
        //
        // Axis itself:
        //
        
        CGFloat x = [self transformX:0.0 forBodyX:bodyRect.origin.x andXFactor:xFactor];
        CGFloat y = [self transformY:0.0 forBodyY:bodyRect.origin.y andYFactor:yFactor graphMin:graphMin] - [self dotRadiusForMargin:margin];
        CGFloat height = [self transformHeight:graphMax forYFactor:yFactor] + (2.0 * [self dotRadiusForMargin:margin]);
        
        CGContextSetStrokeColorWithColor(ctx, _seriesColor);
        CGPoint segment[] = { {x, y}, {x, y + height} };
        CGContextStrokeLineSegments(ctx, segment, 2);
        
        CGContextRestoreGState(ctx);
    }
    
    //
    // Draw the main data series and the extrema data series:
    //
    
    [self drawInBounds:bounds graphMin:graphMin graphMax:graphMax sampleCount:sampleCount withContext:ctx sampleArray:chart.series.samples length:chart.series.length color:_seriesColor withWedges:NO];
    [self drawInBounds:bounds graphMin:graphMin graphMax:graphMax sampleCount:sampleCount withContext:ctx sampleArray:chart.series.minimums length:chart.series.length color:_extremaColor withWedges:YES];
    [self drawInBounds:bounds graphMin:graphMin graphMax:graphMax sampleCount:sampleCount withContext:ctx sampleArray:chart.series.maximums length:chart.series.length color:_extremaColor withWedges:YES];
    
    //
    // Draw the (red) start and end dots:
    //
    
    if (chart.series.startIndex != NO_INDEX) {
        [self drawInBounds:bounds graphMin:graphMin graphMax:graphMax sampleCount:sampleCount withContext:ctx dotAtIndex:chart.series.startIndex value:chart.series.samples[chart.series.startIndex] color:_endDotColor withWedges:YES];
    }
    
    if (chart.series.endIndex != NO_INDEX) {
        [self drawInBounds:bounds graphMin:graphMin graphMax:graphMax sampleCount:sampleCount withContext:ctx dotAtIndex:chart.series.endIndex value:chart.series.samples[chart.series.endIndex] color:_endDotColor withWedges:YES];
    }

//    CGPoint center = CGPointMake(bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0);
//    UIFont * font = [UIFont systemFontOfSize:18.0];
//    [@"HOWDY!!!" drawAtPoint:center withFont:font];
     
    CGContextRestoreGState(ctx);
}

@end
