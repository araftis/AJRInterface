/*!
 @header AJRToolbarPopUpButton.h

 @author A.J. Raftis
 @updated 12/4/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@interface AJRToolbarPopUpButton : NSButton

- (id)initWithFrame:(NSRect)frame;

@property (nonatomic,assign) NSTimeInterval popDelay;
@property (nonatomic,strong) IBOutlet NSMenu *buttonMenu;

@end
