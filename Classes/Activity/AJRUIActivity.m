/*
AJRUIActivity.m
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

#import "AJRUIActivity.h"

#import "AJRActivityViewer.h"
#import "NSBundle+Extensions.h"

@implementation AJRUIActivity

+ (void)load {
    [AJRActivity setInstanceClass:self];
}

- (NSView *)view {
    if (!view) {
        if (![NSBundle ajr_loadNibNamed:@"AJRActivity" owner:self]) {
            [NSException raise:NSInternalInconsistencyException format:@"Unable to load nib AJRActivity."];
        }
        [progressView setIndeterminate:NO];
        [progressView setMinValue:0.0];
        [progressView setMaxValue:1.0];
        [progressView setDoubleValue:0.0];
    }
    return view;
}

- (void)_setProgress:(NSNumber *)progress {
    double percent = [progress doubleValue];
    
    [super setProgress:percent];
    if (!progressView) [self view];
    [progressView setDoubleValue:self.progressMin + (self.progressMax - self.progressMin) * percent];
}

- (void)setProgress:(double)percent {
    [self performSelectorOnMainThread:@selector(_setProgress:) withObject:[NSNumber numberWithDouble:percent] waitUntilDone:NO];
}

- (void)updateMessageText {
    [super updateMessageText];

    AJRRunAsyncOnMainThread(^{
        NSRect frame;
        NSMutableString *message;
        NSInteger x;
        
        if (!self->messageText) {
            [self view];
        }
        message = [NSMutableString string];
        for (x = 0; x < (const NSInteger)[self.messages count]; x++) {
            [message appendString:AJRFormat(@"%*s%@\n", x * 3, "", [self.messages objectAtIndex:x])];
        }
        [self->messageText setStringValue:message];
        
        frame = [self->view frame];
        [self->view setFrame:(NSRect){frame.origin, {frame.size.width, [self.messages count] * 14.0 + 24.0}}];
        
        [self->view setNeedsDisplay:YES];
        [(AJRActivityView *)[self->view superview] tile];
    });
}

- (void)setIndeterminate:(BOOL)flag {
    [super setIndeterminate:flag];
    AJRRunAsyncOnMainThread(^{
        [self->progressView setIndeterminate:flag];
        if (flag) {
            [self->progressView setUsesThreadedAnimation:YES];
            [self->progressView startAnimation:nil];
        } else {
            [self->progressView stopAnimation:nil];
        }
    });
}

- (void)_addToViewer {
    [[AJRActivityViewer sharedInstance] addActivity:self];
}

- (void)addToViewer {
    [self performSelectorOnMainThread:@selector(_addToViewer) withObject:nil waitUntilDone:NO];
}

- (void)removeFromViewer {
    [[AJRActivityViewer sharedInstance] performSelectorOnMainThread:@selector(removeActivity:) withObject:self waitUntilDone:NO];
}

@end
