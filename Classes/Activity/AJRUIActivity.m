//
//  AJRActivity.m
//
//  Created by A.J. Raftis on Mon Nov 18 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

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
