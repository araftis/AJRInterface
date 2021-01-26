//
//  NSString+Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 5/17/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (AJRInterfaceExtensions)

- (NSSize)sizeWithAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes constrainedToWidth:(CGFloat)width NS_SWIFT_NAME(size(withAttributes:constrainedToWidth:));

- (void)drawAtPoint:(NSPoint)point withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs context:(CGContextRef)context;
- (void)drawInRect:(NSRect)rect withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs context:(CGContextRef)contextl;

- (NSString *)stringByReplacingTypographicalSubstitutions;

@end
