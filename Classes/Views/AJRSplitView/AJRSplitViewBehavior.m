/*
AJRSplitViewBehavior.m
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

