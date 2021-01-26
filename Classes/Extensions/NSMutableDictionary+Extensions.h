/*!
 @header NSMutableDictionary+Extensions.h

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
@interface NSMutableDictionary (AJRInterfaceExtensions)

- (void)setColor:(NSColor *)color forKey:(id)key;
- (void)setFont:(NSFont *)font forKey:(id)key;
         
@end
