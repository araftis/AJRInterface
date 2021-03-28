
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AJRFadingWindowController : NSWindowController <CAAnimationDelegate> {
    CGFloat maxAlphaValue;
}

@end
