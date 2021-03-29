/*
AJRCalendarItemInspector.h
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

#import <Cocoa/Cocoa.h>

@class EKCalendarItem, AJRCalendarItemInspectorController;

@interface AJRCalendarItemInspector : NSObject 
{
    __weak AJRCalendarItemInspectorController    *_owner;
    NSView                                      *_view;
    NSObjectController                          *_itemController;
}

- (id)initWithOwner:(AJRCalendarItemInspectorController *)owner;

@property (nonatomic,readonly,weak) AJRCalendarItemInspectorController *owner;
@property (nonatomic,strong) IBOutlet NSView *view;
@property (nonatomic,strong) IBOutlet NSObjectController *itemController;
@property (nonatomic,strong) EKCalendarItem *item;

/*!
 @methodgroup Actions
 */
- (void)dismiss:(id)sender;

/*!
 This method examines event and returns an integer who'd value depends on whether or not it should be the inspector for the event. The superclass implementation always returns 0. If you want to register an inspector and have it inspect an event, you should then return something from this method that return a value larger 0. Note that returning 0 means that you cannot inspect the event. System inspectors will return a value of 100.
 */
+ (NSUInteger)shouldInspectCalendarItem:(EKCalendarItem *)event;

/*!
 @methodgroup Observable values
 */
- (NSString *)title;
- (BOOL)isTitleEditable;
- (BOOL)editTitleOnFirstAppearance;
- (void)titleDidChange:(NSString *)title;

- (NSString *)rightButtonTitle;
- (NSString *)rightButtonKeyEquivalent;
- (BOOL)rightButtonEnabled;
- (id)rightButtonTarget;
- (SEL)rightButtonAction;
- (NSString *)middleButtonTitle;
- (NSString *)middleButtonKeyEquivalent;
- (BOOL)middleButtonEnabled;
- (id)middleButtonTarget;
- (SEL)middleButtonAction;
- (NSString *)leftButtonTitle;
- (NSString *)leftButtonKeyEquivalent;
- (BOOL)leftButtonEnabled;
- (id)leftButtonTarget;
- (SEL)leftButtonAction;

- (id)initialFirstResponder;

@end
