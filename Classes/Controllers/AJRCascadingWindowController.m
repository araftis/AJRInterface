/*
 AJRCascadingWindowController.m
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

#import "AJRCascadingWindowController.h"

@implementation AJRCascadingWindowController

- (BOOL)hasWindowWithTopLeftOrigin:(NSPoint)topLeftOrigin {
	NSArray<NSDocument *> *documents = [[NSDocumentController sharedDocumentController] documents];
	
	for (NSDocument *document in documents) {
		for (NSWindowController *windowController in [document windowControllers]) {
			NSWindow *window = [windowController window];
			NSRect windowFrame = [window frame];
			if (windowFrame.origin.x == topLeftOrigin.x && windowFrame.origin.y + windowFrame.size.height == topLeftOrigin.y) {
				return YES;
			}
		}
	}
	return NO;
}

- (NSPoint)nextAvailableWindowTopLeftOrigin {
	NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
	NSPoint topLeftOrigin = {screenFrame.origin.x + 100.0, screenFrame.origin.y + screenFrame.size.height - 75.0};
	
	while ([self hasWindowWithTopLeftOrigin:topLeftOrigin]) {
		topLeftOrigin.x += 21.0;
		topLeftOrigin.y -= 23.0;
	}
	
	return topLeftOrigin;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSRect windowFrame = [[self window] frame];
    NSValue *desiredSize = [self desiredWindowSize];
    if (desiredSize) {
        windowFrame.size = [desiredSize sizeValue];
        [[self window] setFrame:windowFrame display:NO];
    }
	NSPoint topLeftOrigin = [self nextAvailableWindowTopLeftOrigin];
	
	windowFrame.origin.x = topLeftOrigin.x;
	windowFrame.origin.y = topLeftOrigin.y - windowFrame.size.height;
	
	[[self window] setFrameOrigin:windowFrame.origin];
}

- (NSValue *)desiredWindowSize {
    return nil;
}

@end
