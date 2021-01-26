//
//  NSEvent+Extensions.h
//  MMFoundation
//
//  Created by A.J. Raftis on 12/28/17.
//  Copyright © 2017 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (AJRInterfaceExtensions)

- (NSPoint)ajr_locationInView:(NSView *)view;
+ (NSPoint)ajr_locationInView:(NSView *)view;

@end
