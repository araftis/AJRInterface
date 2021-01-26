//
//  NSAttributedString-Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (AJRInterfaceExtensions)

- (NSSize)ajr_sizeConstrainedToWidth:(CGFloat)width;

- (void)ajr_drawAtPoint:(NSPoint)point context:(CGContextRef)context;
- (void)ajr_drawInRect:(NSRect)rect context:(CGContextRef)context;

@end
