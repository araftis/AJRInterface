//
//  AJRRatingsView.m
//  AJRInterface
//
//  Created by Mike Lee on 1/21/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRRatingsView.h"

@implementation AJRRatingsView

#pragma mark NSView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}


#pragma mark NSLevelIndicator

- (void)setCriticalValue:(double)criticalValue {
    super.criticalValue = criticalValue;
    self.needsDisplay = YES;
}

@end
