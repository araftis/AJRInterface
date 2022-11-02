/*
 AJRSplitView.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import "AJRSplitView.h"

#import "AJRBorder.h"
#import "AJRGradientColor.h"
#import "AJRSeparatorBorder.h"
#import "AJRSplitViewBehavior.h"
#import "NSView+Extensions.h"

#import <AJRFoundation/AJRLogging.h>

@interface AJRSplitView ()

@property (nonatomic,strong) NSMutableSet *trackedViews;
@property (nonatomic,strong) AJRSplitViewBehavior *trackingContainer;
@property (nonatomic,assign) NSPoint trackingInitialPoint;
@property (nonatomic,assign) CGFloat trackingInitialConstant;
@property (nonatomic,strong) NSMutableDictionary *observations;

@end


@implementation AJRSplitView

#pragma mark - Properties

@synthesize border = _border;
@synthesize trackedViews = _trackedViews;
@synthesize trackingContainer = _trackingContainer;
@synthesize trackingInitialPoint = _trackingInitialPoint;
@synthesize trackingInitialConstant = _trackingInitialConstant;
@synthesize observations = _observations;

- (void)setBorder:(AJRBorder *)border {
    if (border != _border) {
        _border = border;
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Creation

- (void)commonInit {
    [self setBorder:[[AJRSeparatorBorder alloc] init]];
    [(AJRSeparatorBorder *)_border setBackgroundColor:[AJRGradientColor gradientColorWithColor:NSColor.underPageBackgroundColor]];
    _trackedViews = [[NSMutableSet alloc] init];
    _observations = [[NSMutableDictionary alloc] init];
    [self setRedrawOnApplicationOrWindowStatusChange:YES];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    
    return self;
}

#pragma mark - Views

- (void)addSubview:(NSView *)aView {
    [super addSubview:aView];
    
    [aView setPostsFrameChangedNotifications:YES];
    [_observations setObject:[[NSNotificationCenter defaultCenter] addObserverForName:NSViewFrameDidChangeNotification object:aView queue:nil usingBlock:^(NSNotification *note) {
        if (!self->_trackingContainer) {
            [[self window] invalidateCursorRectsForView:self];
        }
    }] forKey:[NSValue valueWithPointer:(__bridge const void *)aView]];
}

- (void)willRemoveSubview:(NSView *)subview {
    id token = [_observations objectForKey:[NSValue valueWithPointer:(__bridge const void *)subview]];
    NSMutableSet *toRemove;
    
    if (token) {
        [[NSNotificationCenter defaultCenter] removeObserver:token];
    }
    
    toRemove = [NSMutableSet set];
    for (AJRSplitViewBehavior *behavior in _trackedViews) {
        if ([behavior view] == subview) {
            [toRemove addObject:behavior];
        }
    }
    for (AJRSplitViewBehavior *behavior in toRemove) {
        [_trackedViews removeObject:behavior];
    }
}

- (void)addBehavior:(AJRSplitViewBehavior *)behavior {
    [_trackedViews addObject:behavior];
    [[self window] invalidateCursorRectsForView:self];
}

- (void)removeBehavior:(AJRSplitViewBehavior *)behavior {
    [_trackedViews removeObject:behavior];
    [[self window] invalidateCursorRectsForView:self];
}

- (void)removeAllBehaviors {
    [_trackedViews removeAllObjects];
    [[self window] invalidateCursorRectsForView:self];
}

- (AJRSplitViewBehavior *)trackConstraint:(NSLayoutConstraint *)constraint ofView:(NSView *)view forEdge:(AJRViewEdge)edge {
    AJRSplitViewBehavior *behavior = [AJRSplitViewBehavior behaviorWithConstraint:constraint view:view edge:edge];
    
    [self addBehavior:behavior];
    
    return behavior;
}

- (AJRSplitViewBehavior *)containerForPoint:(NSPoint)point {
    for (AJRSplitViewBehavior *behavior in _trackedViews) {
        NSRect trackingRect = [behavior trackingRect];
        
        if (NSPointInRect(point, trackingRect)) {
            return behavior;
        }
    }
    
    return nil;
}

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect {
    [_border drawBorderInRect:[self bounds] controlView:self];
}

- (NSRect)trackingRectForView:(NSView *)view edge:(AJRViewEdge)edge {
    NSRect  trackingRect = NSZeroRect;
    NSRect  frame = [view frame];
    
    if (edge == AJRViewEdgeTop) {
        trackingRect.origin.x = frame.origin.x;
        trackingRect.origin.y = frame.origin.y + frame.size.height - 3.0;
        trackingRect.size.width = frame.size.width;
        trackingRect.size.height = 6.0;
    } else if (edge == AJRViewEdgeBottom) {
        trackingRect.origin.x = frame.origin.x;
        trackingRect.origin.y = frame.origin.y - 3.0;
        trackingRect.size.width = frame.size.width;
        trackingRect.size.height = 6.0;
    } else if (edge == AJRViewEdgeLeft) {
        trackingRect.origin.x = frame.origin.x - 3.0;
        trackingRect.origin.y = frame.origin.y;
        trackingRect.size.width = 6.0;
        trackingRect.size.height = frame.size.height;
    } else if (edge == AJRViewEdgeRight) {
        trackingRect.origin.x = frame.origin.x + frame.size.width - 3.0;
        trackingRect.origin.y = frame.origin.y;
        trackingRect.size.width = 6.0;
        trackingRect.size.height = frame.size.height;
    }
    
    return trackingRect;
}

- (void)resetCursorRects {
    if (!_trackingContainer) {
        for (AJRSplitViewBehavior *behavior in _trackedViews) {
            NSView *view = [behavior view];
            AJRViewEdge edge = [behavior edge];
            NSRect trackingRect;
            NSCursor *cursor = nil;
            
            switch (edge) {
                case AJRViewEdgeTop:
                    trackingRect = [self trackingRectForView:view edge:AJRViewEdgeTop];
                    cursor = [NSCursor resizeUpDownCursor];
                    break;
                case AJRViewEdgeBottom:
                    trackingRect = [self trackingRectForView:view edge:AJRViewEdgeBottom];
                    cursor = [NSCursor resizeUpDownCursor];
                    break;
                case AJRViewEdgeLeft:
                    trackingRect = [self trackingRectForView:view edge:AJRViewEdgeLeft];
                    cursor = [NSCursor resizeLeftRightCursor];
                    break;
                case AJRViewEdgeRight:
                    trackingRect = [self trackingRectForView:view edge:AJRViewEdgeRight];
                    cursor = [NSCursor resizeLeftRightCursor];
                    break;
            }
            
            if (cursor) {
                [behavior setTrackingRect:trackingRect];
                [self addCursorRect:trackingRect cursor:cursor];
            }
        }
    }
}

- (NSView *)hitTest:(NSPoint)aPoint {
    if ([self containerForPoint:[self convertPoint:aPoint fromView:[self superview]]] != nil) {
        return self;
    }
    
    return [super hitTest:aPoint];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil];
    AJRSplitViewBehavior *behavior = [self containerForPoint:where];
    
    if (behavior) {
        _trackingContainer = behavior;
        _trackingInitialPoint = where;
        _trackingInitialConstant = [[behavior constraint] constant];
        
        [[self window] invalidateCursorRectsForView:self];
        switch ([_trackingContainer edge]) {
            case AJRViewEdgeTop:
            case AJRViewEdgeBottom:
                [[NSCursor resizeUpDownCursor] set];
                break;
            case AJRViewEdgeLeft:
            case AJRViewEdgeRight:
                [[NSCursor resizeLeftRightCursor] set];
                break;
        }
    }
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat offset = 0.0;
    CGFloat newConstant;
    
    switch ([_trackingContainer edge]) {
        case AJRViewEdgeTop:
            offset = _trackingInitialPoint.y - where.y;
            break;
        case AJRViewEdgeBottom:
            offset = where.y - _trackingInitialPoint.y;
            break;
        case AJRViewEdgeLeft:
            offset = where.x - _trackingInitialPoint.x;
            break;
        case AJRViewEdgeRight:
            offset = _trackingInitialPoint.x - where.x;
            break;
    }
    
    newConstant = _trackingInitialConstant - offset;
    if (newConstant < [_trackingContainer minBeforeSnap]) {
        newConstant = [_trackingContainer min];
    }
    if (newConstant > [_trackingContainer max]) {
        newConstant = [_trackingContainer max];
    }
    
    if ([_trackingContainer resizeTrackingBlock]) {
        newConstant = [_trackingContainer resizeTrackingBlock](newConstant);
    }
    
    [[_trackingContainer constraint] setConstant:newConstant];
}

- (void)mouseUp:(NSEvent *)event {
    if ([_trackingContainer resizeCompletionBlock]) {
        [_trackingContainer resizeCompletionBlock]([[_trackingContainer constraint] constant]);
    }
    
    _trackingInitialConstant = 0.0;
    _trackingContainer = nil;
    _trackingInitialPoint = NSZeroPoint;
    
    [NSCursor pop];
    [[self window] invalidateCursorRectsForView:self];
}

@end
