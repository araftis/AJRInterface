/*
 AJRSparklineRenderer.h
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
