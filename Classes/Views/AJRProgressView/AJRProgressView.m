/*
 AJRProgressView.m
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

#import "AJRProgressView.h"

@implementation AJRProgressView

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        NSProgressIndicator *progress;
        NSRect frame;
        
        self.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.25];
        
        frame.size.width = 32.0;
        frame.size.height = 32.0;
        frame.origin.x = frameRect.origin.x + (frameRect.size.width - frame.size.width) / 2.0;
        frame.origin.y = frameRect.origin.y + (frameRect.size.height - frame.size.height) / 2.0;
        progress = [[NSProgressIndicator alloc] initWithFrame:frame];
        [progress setAutoresizingMask:NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin | NSViewMinYMargin];
		[progress setStyle:NSProgressIndicatorStyleSpinning];
        [progress setIndeterminate:YES];
        [self addSubview:progress];
        [progress startAnimation:self];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@synthesize backgroundColor = _backgroundColor;

- (void)drawRect:(NSRect)rect {
    [_backgroundColor set];
    NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (void)viewDidMoveToSuperview {
    NSView *superview = [self superview];
    
    if (superview) {
        [superview setPostsFrameChangedNotifications:YES];
        [self setFrame:[superview frame]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(superviewFrameDidChange:) name:NSViewFrameDidChangeNotification object:superview];
    }
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    if ([self superview]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)superviewFrameDidChange:(NSNotification *)notification {
    [self setFrame:[[self superview] frame]];
}

- (BOOL)isOpaque {
    return NO;
}

@end
