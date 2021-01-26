//
//  AJRSplitViewBehavior.h
//  AJRInterface
//
//  Created by A.J. Raftis on 9/28/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AJRInterface/AJRSplitView.h>

typedef CGFloat (^AJRSplitViewTracker)(CGFloat value);
typedef void (^AJRSplitViewCompletion)(CGFloat value);

@interface AJRSplitViewBehavior : NSObject 

+ (id)behaviorWithConstraint:(NSLayoutConstraint *)constraint view:(NSView *)view edge:(AJRViewEdge)edge;

@property (nonatomic,strong) NSLayoutConstraint *constraint;
@property (nonatomic,strong) NSView *view;
@property (nonatomic,assign) AJRViewEdge edge;
@property (nonatomic,assign) NSRect trackingRect;
@property (nonatomic,assign) CGFloat min;
@property (nonatomic,assign) CGFloat minBeforeSnap;
@property (nonatomic,assign) CGFloat max;
@property (nonatomic,copy) AJRSplitViewTracker resizeTrackingBlock;
@property (nonatomic,copy) AJRSplitViewCompletion resizeCompletionBlock;

@end
