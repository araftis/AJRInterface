/*!
 @header AJRSubviewController.h

 @author Alex Raftis
 @updated 12/10/08.
 @copyright 2008 Apple, Inc.. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRMultiViewController;

@interface AJRViewController : NSObject 
{
    NSString                *_nibName;
    NSString                *_title;
    NSString                *_identifier;
    NSView                    *_view;
    NSObject                *_object;
    AJRMultiViewController    *_viewController;
}

- (id)initWithViewController:(AJRMultiViewController *)viewController;

- (NSString *)nibName;

@property (nonatomic,retain) NSString *nibName;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) IBOutlet NSView *view;
@property (nonatomic,assign) AJRMultiViewController *viewController;
@property (nonatomic,retain) NSObject *object;

- (NSView *)viewWithParentController:(NSController *)parentController;

- (void)viewDidLoad;

@end
