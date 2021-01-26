/*!
 @header NSToolbar+Extensions.h

 @author A.J. Raftis
 @updated 2/26/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRTranslator;

/*!
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface NSToolbar (AJRInterfaceExtensions)

- (NSToolbarItem *)toolbarItemForItemIdentifier:(NSString *)identifier;

- (void)translateWithTranslator:(AJRTranslator *)translator;

@end
