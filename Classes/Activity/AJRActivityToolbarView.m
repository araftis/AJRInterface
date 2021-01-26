//
//  AJRActivityToolbarView.m
//  Meta Monkey
//
//  Created by A.J. Raftis on 9/7/12.
//
//

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
