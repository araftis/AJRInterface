
#import "AJRToggleButton.h"

#import "AJRToggleButtonCell.h"

@implementation AJRToggleButton

+ (id)cellClass {
    return [AJRToggleButtonCell class];
}

- (void)setBackgroundColor:(NSColor *)color {
    [(AJRToggleButtonCell *)[self cell] setBackgroundColor:color];
}

- (NSColor *)backgroundColor {
    return [(AJRToggleButtonCell *)[self cell] backgroundColor];
}

- (void)setAlternateBackgroundColor:(NSColor *)color {
    [(AJRToggleButtonCell *)[self cell] setAlternateBackgroundColor:color];
}

- (NSColor *)alternateBackgroundColor {
    return [(AJRToggleButtonCell *)[self cell] alternateBackgroundColor];
}

@end
