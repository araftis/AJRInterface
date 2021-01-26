//
//  AJRSparklineRenderer.h
//  Ellipsis
//
//  Created by Gregor Purdy on 2008-07-23.
//  Copyright 2008 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MARGIN_FACTOR 7.5
#define DEFAULT_STD_DEVS 3.0

@class AJRSparklineChart;

@interface AJRSparklineRenderer : NSObject 
{
    BOOL                _includeEntireRange;
    CGFloat                _marginFactor;
    
    CGColorRef            _backgroundColor;
    
    CGColorRef            _endDotColor;
    CGColorRef            _extremaColor;
    
    CGColorRef            _seriesColor;
    
    CGColorRef            _errorRangeColor;
    CGColorRef            _warnRangeColor;
    CGColorRef            _nominalRangeColor;
    
    NSNumberFormatter    *_numberFormatter;
    
}

@property(nonatomic) BOOL includeEntireRange;
@property(nonatomic) CGFloat marginFactor;

@property(nonatomic) CGColorRef backgroundColor;

@property(nonatomic) CGColorRef endDotColor;
@property(nonatomic) CGColorRef extremaColor;

@property(nonatomic) CGColorRef seriesColor;

@property(nonatomic) CGColorRef errorRangeColor;
@property(nonatomic) CGColorRef warnRangeColor;
@property(nonatomic) CGColorRef nominalRangeColor;

@property(nonatomic, retain) NSNumberFormatter * numberFormatter;

- (id)initWithMarginFactor:(CGFloat)aMarginFactor;

- (void)drawChart:(AJRSparklineChart *)chart inBounds:(CGRect)bounds withContext:(CGContextRef)ctx;

@end
