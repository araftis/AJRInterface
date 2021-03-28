
#import <Cocoa/Cocoa.h>

@class AJRBorder;

typedef NS_ENUM(UInt8, AJRViewEdge) {
    AJRViewEdgeTop,
    AJRViewEdgeBottom,
    AJRViewEdgeLeft,
    AJRViewEdgeRight
};

@class AJRSplitViewBehavior;

@interface AJRSplitView : NSView

@property (nonatomic,strong) AJRBorder *border;

- (void)addBehavior:(AJRSplitViewBehavior *)behavior;
- (void)removeBehavior:(AJRSplitViewBehavior *)behavior;
- (void)removeAllBehaviors;
- (AJRSplitViewBehavior *)trackConstraint:(NSLayoutConstraint *)constraint ofView:(NSView *)view forEdge:(AJRViewEdge)edge;

@end
