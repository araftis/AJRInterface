//
//  AJRToggleButton.m
//  AJRInterface
//
//  Created by A.J. Raftis on 9/14/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRToggleButton.h"

#import "AJRToggleButtonCell.h"

@implementation AJRToggleButton

+ (id)cellClass {
    return [AJRToggleButtonCell class];
}

- (void)setBackgroundColor:(NSColor *)color {
    [(AJRToggleButtonCell *)[self cell] setBackgroundColor:color];
}

- (NSColor *)backgroundColor {
    return [(AJRToggleButtonCell *)[self cell] backgroundColor];
}

- (void)setAlternateBackgroundColor:(NSColor *)color {
    [(AJRToggleButtonCell *)[self cell] setAlternateBackgroundColor:color];
}

- (NSColor *)alternateBackgroundColor {
    return [(AJRToggleButtonCell *)[self cell] alternateBackgroundColor];
}

@end
