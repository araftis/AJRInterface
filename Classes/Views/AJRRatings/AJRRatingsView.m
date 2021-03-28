
#import "AJRRatingsView.h"

@implementation AJRRatingsView

#pragma mark NSView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}


#pragma mark NSLevelIndicator

- (void)setCriticalValue:(double)criticalValue {
    super.criticalValue = criticalValue;
    self.needsDisplay = YES;
}

@end
