//
//  AJRFadingWindowController.h
//  AJRInterface
//
//  Created by Damien Uern on 8/12/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AJRFadingWindowController : NSWindowController <CAAnimationDelegate> {
    CGFloat maxAlphaValue;
}

@end
