/*
 AJRCalendarItemInspectorWindow.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
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
#import <Quartz/Quartz.h>

@class AJRCalendarItemInspector;

typedef NS_ENUM(UInt8) {
    AJRButtonRight = 1,
    AJRButtonMiddle = 2,
    AJRButtonLeft = 3
} AJRButtonLocation;

@interface AJRCalendarItemInspectorWindow : NSWindow <CAAnimationDelegate> {
    CGFloat _arrowShift;

    ///////////////
    // Animation //
    ///////////////
    NSRect _originalWidowFrame;
    NSRect _originalLayerFrame;
    
    NSView *_oldContentView;
    NSResponder *_oldFirstResponder;
    NSView *_animationView;
    CALayer *_animationLayer;
    
    BOOL _growing;
    BOOL _shrinking;
    BOOL _pretendKeyForDrawing;
    NSWindow *_eventualParent;
    CGFloat _minYCoordinate;
    CGFloat _maxXCoordinate;
}

- (id)initWithScreenLocation:(NSPoint)location;

- (AJRCalendarItemInspector *)inspector;

- (CGFloat)arrowShift;
- (void)pointToRect:(NSRect)rect;

- (NSView *)documentView;
- (void)setDocumentView:(NSView *)documentView;
- (IBAction)dismiss:(id)sender;

- (NSTextField *)titleField;
- (void)setButtonTitle:(NSString *)title 
         keyEquivalent:(NSString *)keyEquivalent
               enabled:(BOOL)enabled
                target:(id)target
                action:(SEL)action
           forLocation:(AJRButtonLocation)location;

- (void)popup;
- (void)setEventualParent:(NSWindow *)window;

- (void)updateFrameToAccomodateHeight:(CGFloat)height animate:(BOOL)animate;

@end

@interface NSObject (AJRCalendarItemInspectorWindowDelegate)

- (void)windowDidCompletePopAnimation:(NSWindow *)window;

@end
