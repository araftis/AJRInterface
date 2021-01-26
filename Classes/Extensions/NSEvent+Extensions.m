//
//  NSEvent+Extensions.m
//  MMFoundation
//
//  Created by A.J. Raftis on 12/28/17.
//  Copyright © 2017 A.J. Raftis. All rights reserved.
//

#import "NSEvent+Extensions.h"

@implementation NSEvent (AJRInterfaceExtensions)

- (NSPoint)ajr_locationInView:(NSView *)view {
    return [view convertPoint:[self locationInWindow] fromView:nil];
}

+ (NSPoint)ajr_locationInView:(NSView *)view {
    NSPoint where = [NSEvent mouseLocation];
    where = [[view window] convertRectFromScreen:(NSRect){where, {1.0, 1.0}}].origin;
    where = [view convertPoint:where fromView:nil];
    return where;
}

@end
