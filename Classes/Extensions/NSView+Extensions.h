/*
NSView+Extensions.h
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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
