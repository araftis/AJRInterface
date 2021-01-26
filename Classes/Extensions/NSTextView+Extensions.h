/*!
 @header NSTextView+Extensions.h

 @author A.J. Raftis
 @updated 4/6/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRLineNumberView;

/*!
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface NSTextView (AJRInterfaceExtensions)

- (NSRange)rangeForLine:(NSUInteger)line;
- (AJRLineNumberView *)lineNumberView;

@end
