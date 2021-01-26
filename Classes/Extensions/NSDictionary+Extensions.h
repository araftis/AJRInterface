/*!
 @header NSDictionary+Extensions.h

 @author A.J. Raftis
 @updated 3/20/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

/*!
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface NSDictionary (AJRInterfaceExtensions)

- (NSColor *)colorForKey:(id)key defaultValue:(NSColor *)defaultValue;
- (NSFont *)fontForKey:(id)key defaultValue:(NSFont *)defaultValue;

@end
