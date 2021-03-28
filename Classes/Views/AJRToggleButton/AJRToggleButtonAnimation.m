
#import "AJRToggleButtonAnimation.h"

#import "AJRToggleButtonCell.h"

@interface AJRToggleButtonCell (Private)

- (void)_updateThumbOffsetForAnimationProgress:(NSAnimationProgress)progress;

@end


@implementation AJRToggleButtonAnimation

#pragma mark NSAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    // Call super to update the progress value.
    [super setCurrentProgress:progress];

    [_toggleButtonCell _updateThumbOffsetForAnimationProgress:progress];
    
    if (progress == 1.0 && [[self delegate] respondsToSelector:@selector(animationDidStop:)]) {
        [[self delegate] animationDidStop:self];
    }
}
    
@end
