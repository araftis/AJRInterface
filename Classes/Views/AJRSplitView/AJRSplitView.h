//
//  AJRSplitView.h
//  AJRInterface
//
//  Created by A.J. Raftis on 9/28/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRBorder;

typedef enum {
    AJRViewEdgeTop,
    AJRViewEdgeBottom,
    AJRViewEdgeLeft,
    AJRViewEdgeRight
} AJRViewEdge;

@class AJRSplitViewBehavior;

@interface AJRSplitView : NSView

@property (nonatomic,strong) AJRBorder *border;

- (void)addBehavior:(AJRSplitViewBehavior *)behavior;
- (void)removeBehavior:(AJRSplitViewBehavior *)behavior;
- (void)removeAllBehaviors;
- (AJRSplitViewBehavior *)trackConstraint:(NSLayoutConstraint *)constraint ofView:(NSView *)view forEdge:(AJRViewEdge)edge;

@end
