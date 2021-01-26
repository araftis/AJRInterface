/*!
 @header NSView+Extensions.h

 @author A.J. Raftis
 @updated 2/19/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRWindowOperation) {
	AJRWindowOperationResizeTopLeft = 0,
	AJRWindowOperationResizeTop = 1,
	AJRWindowOperationResizeTopRight = 2,
	AJRWindowOperationResizeLeft = 3,
	AJRWindowOperationMove = 4,
	AJRWindowOperationResizeRight = 5,
	AJRWindowOperationResizeBottomLeft = 6,
	AJRWindowOperationResizeBottom = 7,
	AJRWindowOperationResizeBottomRight = 8,
};

/*!
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface NSView (AJRInterfaceExtensions) 

- (NSRect)frameInScreenCoordinates;

/*! Returns true if the view is in an active application. */
- (BOOL)isActive;
/*! Returns true if the view is in an active application and is in the key window. */
- (BOOL)isActiveAndKey;
/*! Returns true if the view is in an active application, in a key window, and is also the first responder. */
- (BOOL)isActiveKeyAndFirstResponder;

/*! Sets up the view to potentially be called for automatic redraw when the view's application or window changes state. */
- (void)setRedrawOnApplicationOrWindowStatusChange:(BOOL)flag;
- (BOOL)redrawsOnApplicationOrWindowStatusChange;

/*! Checks itself and all its subviews for the view with the provided identifier. The identifier is set via the "Identity" inspector in Interface Builder. */
- (nullable NSView *)findViewWithIdentifier:(NSString *)identifier;

- (void)trackMouseForOperation:(AJRWindowOperation)operation fromEvent:(NSEvent *)event;

- (nullable NSButton *)selectedRadioButtonTargetting:(nullable id)target withAction:(SEL)action;
- (void)selectRadioButtonTargetting:(nullable id)target withAction:(SEL)action andIdentifier:(NSUserInterfaceItemIdentifier)identifier;

@property (nonatomic,readonly) NSString *subtreeDescription;

@end

@interface NSButton (Extensions)

/*! Basically, AppKit is suppose to treat all buttons in a group that target the same object/action as a radio group, but sometimes that fails. If it's failing for you, call this method with your selected radio button, and all buttons in the same parent will be updated correctly. */
- (void)ajr_updateRadioGroup;

@end

NS_ASSUME_NONNULL_END
