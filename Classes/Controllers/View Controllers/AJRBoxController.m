
#import "AJRBoxController.h"

#import "AJRViewController.h"

@implementation AJRBoxController

- (void)selectViewAtIndex:(NSUInteger)index {
    NSString *name = [[[self class] viewControllerNames] objectAtIndex:index];
    NSViewController *viewController = [self viewControllerForName:name];
    NSView *view = [viewController view];
    
    if (view) {
        [(NSBox *)self.view setContentView:view];
    }
    [(NSBox *)self.view setTitle:[viewController title]];
    
    [super selectViewAtIndex:index];
}

@end
