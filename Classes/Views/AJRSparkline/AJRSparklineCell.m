/*
 AJRSparklineCell.m
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
//  AJRSparklineCell.m
//  AJRInterface
//
//  Created by Alex Raftis on 12/16/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRSparklineCell.h"

#import "AJRSparklineRenderer.h"

#import <AJRFoundation/AJRSeries.h>
#import <AJRFoundation/AJRSparkline.h>
#import <AJRFoundation/AJRSparklineChart.h>

#import <Log4Cocoa/Log4Cocoa.h>

@implementation AJRSparklineCell

- (id)init
{
    if ((self = [super init])) {
        self.objectValue = nil;
        _renderer = [[AJRSparklineRenderer alloc] initWithMarginFactor:2.0];
        [_renderer setBackgroundColor:CGColorCreateGenericRGB(1.0, 1.0, 1.0, 0.0)];
    }
    return self;
}

- (id)initTextCell:(NSString *)text
{
    return [self init];
}

- (id)initImageCell:(NSImage *)image
{
    return [self init];
}

- (void)dealloc
{
    [_renderer release];
    
    [super dealloc];
}

@synthesize renderer = _renderer;

- (void)setObjectValue:(id)object
{
    @try {
        if ([object isKindOfClass:[AJRSparklineChart class]]) {
            [super setObjectValue:object];
        } else {
            [super setObjectValue:nil];
        }
    } @catch (NSException *exception) {
        log4Error(@"%@", exception);
    }
}

- (void)setSparklineChart:(AJRSparklineChart *)sparklineChart
{
    [self setObjectValue:sparklineChart];
}

- (AJRSparklineChart *)sparklineChart
{
    return [self objectValue];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    CGRect        chartBounds;

    if (self.objectValue == nil || _renderer == nil) {
        return;
    }
    
    chartBounds.origin.x = cellFrame.origin.x;
    chartBounds.origin.y = cellFrame.origin.y;
    chartBounds.size.height = cellFrame.size.height;
    chartBounds.size.width = cellFrame.size.width;
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSRectClip(cellFrame);
    [_renderer drawChart:self.objectValue inBounds:chartBounds withContext:[[NSGraphicsContext currentContext] graphicsPort]];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (id)copyWithZone:(NSZone *)zone
{
    AJRSparklineCell    *copy = [super copyWithZone:zone];
    
    copy->_renderer = [_renderer retain];
    
    return copy;
}

@end
