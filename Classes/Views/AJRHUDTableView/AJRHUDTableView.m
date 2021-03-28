
#import "AJRHUDTableView.h"

#import <AJRFoundation/AJRFunctions.h>

@interface NSTableView (ApplePrivate)

- (id)_alternatingRowBackgroundColors;

@end


@implementation AJRHUDTableView

- (id)_alternatingRowBackgroundColors {
    return [NSArray arrayWithObjects:[[NSColor blackColor] colorWithAlphaComponent:0.700], [[NSColor blackColor] colorWithAlphaComponent:0.725], nil];
}

@end
