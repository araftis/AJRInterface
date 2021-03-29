/*
_AJRCalendarItemInspectorFrame.h
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

#import <AJRInterface/AJRCalendarItemInspectorWindow.h>

@class AJRCalendarItemInspector, AJRDropShadowBorder;

typedef enum __AJRPointerDirection {
    _AJRPointUp,
    _AJRPointDown,
    _AJRPointLeft,
    _AJRPointRight
} _AJRPointerDirection;

@interface AJRCalendarItemInspectorWindow (Private) 

/*!
 Sets the window title, without calling back to the frame view.
 */
- (void)_setTitle:(NSString *)title;

@end

@interface _AJRCalendarItemInspectorFrame : NSView <NSTextFieldDelegate>
{
    NSGradient *_backgroundGradient;
    NSScrollView *_scrollView;
    NSView *_contentView;
    NSTextField *_titleField;
    NSButton *_rightButton;
    NSButton *_middleButton;
    NSButton *_leftButton;
    NSMutableDictionary *_titleAttributes;
    BOOL _isScrolling;
    BOOL _isTiling;
    _AJRPointerDirection _pointerDirection;
    AJRDropShadowBorder *_dropShadow;
    
    NSRect _desiredBounds;
    NSRect extraFrame;
    NSSize _lastSize;
}

- (AJRCalendarItemInspector *)inspector;

- (NSRect)desiredBounds;
- (CGFloat)desiredHeight;
- (CGFloat)desiredHeightForHeight:(CGFloat)inputHeight;
- (CGFloat)titleHeight;

- (NSRect)contentViewFrame;
- (NSRect)titleFrame;

- (NSRect)buttonFrameForLocation:(AJRButtonLocation)location;
- (NSButton *)buttonForLocation:(AJRButtonLocation)location;

@property (nonatomic,strong) NSScrollView *scrollView;
@property (nonatomic,strong) NSTextField *titleField;
@property (nonatomic,strong) NSButton *rightButton;
@property (nonatomic,strong) NSButton *middleButton;
@property (nonatomic,strong) NSButton *leftButton;
@property (nonatomic,strong) NSMutableDictionary *titleAttributes;
@property (nonatomic,assign) _AJRPointerDirection pointerDirection;

- (NSView *)contentView;
- (void)setContentView:(NSView *)contentView;

- (void)setTitle:(NSString *)title;
- (NSTextField *)titleField;
- (void)setButtonTitle:(NSString *)title 
         keyEquivalent:(NSString *)keyEquivalent
               enabled:(BOOL)enabled
                target:(id)target
                action:(SEL)action
           forLocation:(AJRButtonLocation)location;

- (void)tile;
- (void)tileToContainHeight:(CGFloat)height withAnimation:(BOOL)animate;

- (NSRect)frameForDropShadowForFirstResponder:(NSResponder *)responder;

@end
