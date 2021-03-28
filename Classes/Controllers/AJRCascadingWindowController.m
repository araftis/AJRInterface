
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
