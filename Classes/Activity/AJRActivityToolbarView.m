/*
 AJRActivityToolbarView.m
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

#import "AJRActivityToolbarView.h"

#import "AJRActivityToolbarViewLayer.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRFoundation/AJRFoundation-Swift.h>

NSColorName const AJRActivityActiveTextColor = @"AJRActivityActiveTextColor";
NSColorName const AJRActivityInactiveTextColor = @"AJRActivityInactiveTextColor";
NSColorName const AJRActivitySecondaryActiveTextColor = @"AJRActivitySecondaryActiveTextColor";
NSColorName const AJRActivitySecondaryInactiveTextColor = @"AJRActivitySecondaryInactiveTextColor";

@implementation AJRActivityToolbarView

#pragma mark - Creation

- (void)ajr_commonInit {
	[self setWantsLayer:YES];
    __weak AJRActivityToolbarView *weakSelf = self;
	[AJRActivity addActivityObserver:^(AJRActivityAction action, AJRActivity *activity, NSArray *activities) {
        BOOL isDisplayed = activity.identifier == nil || AJREqual(activity.identifier, weakSelf.activityIdentifier);
        
        if (isDisplayed) {
            if (action == AJRActivityActionAdded) {
                weakSelf.currentActivity = activity;
            } else if (action == AJRActivityActionRemoved) {
                weakSelf.currentActivity = nil;
            }
        }
	}];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder])) {
		[self ajr_commonInit];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self ajr_commonInit];
	}
    return self;
}

#pragma mark - Properties

- (void)setCurrentActivity:(AJRActivity *)currentActivity {
	AJRLogDebug(@"Activity: %@", [currentActivity message]);
	if (_currentActivity) {
		[_currentActivity removeObserver:self forKeyPath:@"message"];
		[_currentActivity removeObserver:self forKeyPath:@"progress"];
		[_currentActivity removeObserver:self forKeyPath:@"progressMin"];
		[_currentActivity removeObserver:self forKeyPath:@"progressMax"];
		[_currentActivity removeObserver:self forKeyPath:@"indeterminate"];
	}
	_currentActivity = currentActivity;
	if (_currentActivity) {
		[_currentActivity addObserver:self forKeyPath:@"message" options:NSKeyValueObservingOptionInitial context:NULL];
		[_currentActivity addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionInitial context:NULL];
		[_currentActivity addObserver:self forKeyPath:@"progressMin" options:NSKeyValueObservingOptionInitial context:NULL];
		[_currentActivity addObserver:self forKeyPath:@"progressMax" options:NSKeyValueObservingOptionInitial context:NULL];
		[_currentActivity addObserver:self forKeyPath:@"indeterminate" options:NSKeyValueObservingOptionInitial context:NULL];
	}
	[self configureForCurrentActivity];
}

- (void)setIdleMessage:(NSString *)idleMessage {
    AJRAssert(NSThread.isMainThread, @"Must run on main thread.");
    [[self activityLayer] setIdleMessage:idleMessage];
}

- (NSString *)idleMessage {
    return [[self activityLayer] idleMessage];
}

- (NSAttributedString *)attributedIdleMessage {
    return [[self activityLayer] attributedIdleMessage];
}

- (void)setAttributedIdleMessage:(NSAttributedString *)idleMessage {
    AJRAssert(NSThread.isMainThread, @"Must run on main thread.");
	[[self activityLayer] setAttributedIdleMessage:idleMessage];
}

- (NSString *)bylineMessage {
    return [[self activityLayer] bylineMessage];
}

- (void)setBylineMessage:(NSString *)byline {
    AJRAssert(NSThread.isMainThread, @"Must run on main thread.");
	[[self activityLayer] setBylineMessage:byline];
}

- (NSAttributedString *)attributedBylineMessage {
    return [[self activityLayer] attributedBylineMessage];
}

- (void)setAttributedBylineMessage:(NSAttributedString *)byline {
    AJRAssert(NSThread.isMainThread, @"Must run on main thread.");
	[[self activityLayer] setAttributedBylineMessage:byline];
}

#pragma mark - Display

- (void)configureForCurrentActivity {
    AJRAssert(NSThread.isMainThread, @"Must run on main thread.");
	AJRActivityToolbarViewLayer	*layer = [self activityLayer];
	
	[layer setMessage:[_currentActivity message]];
	[layer setProgressMinimum:[_currentActivity progressMin]];
	[layer setProgressMaximum:[_currentActivity progressMax]];
	[layer setProgress:[_currentActivity progress]];
	[layer setIndeterminate:[_currentActivity isIndeterminate]];
	if (_currentActivity) {
		[layer showProgress];
	} else {
		[layer hideProgress];
	}
    [self configureDisplayScale];
}

- (void)configureDisplayScale {
    CGFloat displayScale = 2.0; // Assume 2.0, because that's becoming the most common.
    
    if ([self window] && [[self window] screen]) {
        displayScale = [[[self window] screen] backingScaleFactor];
    }
    
    [[self activityLayer] setContentsScale:displayScale];
}

#pragma mark - Retype

- (AJRActivityToolbarViewLayer *)activityLayer {
	return AJRObjectIfKindOfClassOrAssert([self layer], AJRActivityToolbarViewLayer);
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(AJRActivity *)object change:(NSDictionary *)change context:(void *)context {
	if (object == _currentActivity) {
		if ([keyPath isEqualToString:@"message"]) {
			AJRRunAsyncOnMainThread(^{
                [[self activityLayer] setMessage:[self->_currentActivity message]];
			});
		} else if ([keyPath isEqualToString:@"progress"]) {
			AJRRunAsyncOnMainThread(^{
				[[self activityLayer] setProgress:[object progress]];
			});
		} else if ([keyPath isEqualToString:@"progressMin"]) {
			AJRRunAsyncOnMainThread(^{
				[[self activityLayer] setProgressMinimum:[object progressMin]];
			});
		} else if ([keyPath isEqualToString:@"progressMax"]) {
			AJRRunAsyncOnMainThread(^{
				[[self activityLayer] setProgressMaximum:[object progressMax]];
			});
		} else if ([keyPath isEqualToString:@"indeterminate"]) {
			AJRRunAsyncOnMainThread(^{
				[[self activityLayer] setIndeterminate:[object isIndeterminate]];
			});
		}
	}
}

#pragma mark - NSView

- (CALayer *)makeBackingLayer {
    CALayer *layer = [[AJRActivityToolbarViewLayer alloc] init];
    [layer setDelegate:self];
	[layer setNeedsDisplay];
    return layer;
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self configureDisplayScale];
}

- (void)viewDidChangeEffectiveAppearance {
    [[self layer] setNeedsDisplay];
}

@end
