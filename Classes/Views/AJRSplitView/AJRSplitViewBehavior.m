
#import "AJRSplitViewBehavior.h"

@implementation AJRSplitViewBehavior

#pragma mark - Properties

@synthesize constraint = _constraint;
@synthesize view = _view;
@synthesize edge = _edge;
@synthesize trackingRect = _trackingRect;
@synthesize min = _min;
@synthesize minBeforeSnap = _minBeforeSnap;
@synthesize max = _max;
@synthesize resizeTrackingBlock = _resizeTrackingBlock;
@synthesize resizeCompletionBlock = _resizeCompletionBlock;

#pragma mark - Creation

- (id)init {
    if ((self = [super init])) {
        _min = 0.0;
        _minBeforeSnap = 0.0;
        _max = CGFLOAT_MAX;
    }
    return self;
}

+ (id)behaviorWithConstraint:(NSLayoutConstraint *)constraint view:(NSView *)view edge:(AJRViewEdge)edge; {
    AJRSplitViewBehavior   *container = [[AJRSplitViewBehavior alloc] init];
    
    [container setConstraint:constraint];
    [container setView:view];
    [container setEdge:edge];
    
    return container;
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return [_constraint hash] ^ [_view hash] ^ _edge;
}

- (BOOL)isEqual:(id)object {
    return [_constraint isEqual:[object constraint]] && [_view isEqual:[object view]] && _edge == [(AJRSplitViewBehavior *)object edge];
}

@end

