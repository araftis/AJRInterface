//
//  AJRToggleButtonCell.h
//  AJRInterface
//
//  Created by A.J. Raftis on 9/14/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRToggleButtonAnimation;

@interface AJRToggleButtonCell : NSButtonCell <NSCoding, NSAnimationDelegate>
{
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
