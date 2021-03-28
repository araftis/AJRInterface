
#import "NSTreeController+Extensions.h"

@implementation NSTreeController (AJRInterfaceExtensions)

- (void)_selectFirstObject {
    [self setSelectionIndexPath:[NSIndexPath indexPathWithIndex:0]];
}

- (IBAction)selectFirstObject:(id)sender {
    [self selectFirstObject];
}

- (void)selectFirstObject {
    [self performSelector:@selector(_selectFirstObject) withObject:nil afterDelay:0.1];
}

@end
