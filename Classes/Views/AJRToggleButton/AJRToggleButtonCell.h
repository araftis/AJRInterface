/*
 AJRToggleButtonCell.h
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

@class AJRToggleButtonAnimation;

@interface AJRToggleButtonCell : NSButtonCell <NSCoding, NSAnimationDelegate> {
    NSColor *_backgroundColor;
    NSColor *_alternateBackgroundColor;
    
    NSShadow *_backgroundShadow;
    
    NSGradient *_shineGradient;
    
    NSGradient *_thumbGradient;
    NSGradient *_thumbDarkGradient;
    NSShadow *_thumbInnerShadow;
    
    NSDictionary *_textAttributes;
    NSDictionary *_textColoredAttributes;
    NSShadow *_textShadow;
    
    // These values are used during mouse tracking.
    BOOL _mouseInThumb;
    BOOL _trackingMouse;
    NSPoint _startPoint;
    CGFloat _thumbOffset; // When tracking, the offset from at rest position of the thumb.
    NSRect _cellFrame;
    BOOL _ignoreNextSetState;
        
    // Used for animation
    AJRToggleButtonAnimation *_animation;
    CGFloat _animationOffset;
    NSControl *_animationControlView;
}

@property (copy) NSColor *backgroundColor;
@property (nonatomic,strong) NSColor *alternateBackgroundColor;

@end
