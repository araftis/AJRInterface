//
//  AJRFadingWindowController.m
//  AJRInterface
//
//  Created by Damien Uern on 8/12/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRFadingWindowController.h"
#import <Quartz/Quartz.h>

@implementation AJRFadingWindowController

- (id)initWithWindow:(NSWindow *)window
{
    if ((self = [super initWithWindow:window])) {
    }
    return self;
}

- (void) windowDidLoad
{
    maxAlphaValue = [self.window alphaValue];
    CAAnimation *anim = [CABasicAnimation animation];
    [anim setDelegate:self];
    [self.window setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"alphaValue"]];    
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
    if(self.window.alphaValue == 0.00) [self close]; //detect end of fade out and close the window
}


- (IBAction)showWindow:(id)sender
{
    // If the window was hidden, animate its alpha value so it fades in.
    if (![self.window isVisible])
    {
        //move to current event location
        NSEvent *event = [self.window currentEvent];
        NSPoint point = [event locationInWindow];
        [self.window setFrameTopLeftPoint:point];
        
        self.window.alphaValue = 0.0;
        [self.window.animator setAlphaValue:maxAlphaValue];
    }
    [super showWindow:sender];
}

- (BOOL)windowShouldClose:(id)window
{
    // Animate the window's alpha value so it fades out.
    [self.window.animator setAlphaValue:0.0];
    // Don't close the window immediately so we can see the animation.
    return NO;
}

@end
