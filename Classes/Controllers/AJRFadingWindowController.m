/*
 AJRFadingWindowController.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

#import "AJRFadingWindowController.h"
#import <Quartz/Quartz.h>

@implementation AJRFadingWindowController

- (void) windowDidLoad {
    maxAlphaValue = [self.window alphaValue];
    CAAnimation *anim = [CABasicAnimation animation];
    [anim setDelegate:self];
    [self.window setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"alphaValue"]];    
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if(self.window.alphaValue == 0.00) [self close]; //detect end of fade out and close the window
}


- (IBAction)showWindow:(id)sender {
    // If the window was hidden, animate its alpha value so it fades in.
    if (![self.window isVisible]) {
        //move to current event location
        NSEvent *event = [self.window currentEvent];
        NSPoint point = [event locationInWindow];
        [self.window setFrameTopLeftPoint:point];
        
        self.window.alphaValue = 0.0;
        [self.window.animator setAlphaValue:maxAlphaValue];
    }
    [super showWindow:sender];
}

- (BOOL)windowShouldClose:(id)window {
    // Animate the window's alpha value so it fades out.
    [self.window.animator setAlphaValue:0.0];
    // Don't close the window immediately so we can see the animation.
    return NO;
}

@end
