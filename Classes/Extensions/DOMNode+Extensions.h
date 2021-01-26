/*!
 @header DOMNode-Extensions.h

 @author A.J. Raftis
 @updated 12/19/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <WebKit/WebKit.h>

/*!
 @category DOMNode (Extensions)
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface DOMNode (Extensions)

- (void)removeAllChildren;
- (BOOL)matchesName:(NSString *)name withAttribute:(NSString *)attributeName equalTo:(NSString *)value;

@end
