//
//  AJRSparklineView.m
//  AJRInterface
//
//  Created by Alex Raftis on 12/16/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRSparklineView.h"

#import "AJRSparklineCell.h"

@implementation AJRSparklineView

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _cell = [[AJRSparklineCell alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_cell release];
    
    [super dealloc];
}

@synthesize cell = _cell;

- (void)setSparklineChart:(AJRSparklineChart *)sparklineChart
{
    [self.cell setSparklineChart:sparklineChart];
    [self setNeedsDisplay:YES];
}

- (AJRSparklineChart *)sparklineChart
{
    return [self.cell sparklineChart];
}

@end
