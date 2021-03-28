
#import "NSArrayController+Extensions.h"

@implementation NSArrayController (AJRInterfaceExtensions)

- (IBAction)selectFirstObject:(id)sender {
    [self selectFirstObject];
}

- (void)selectFirstObject {
    NSArray *arrangedObjects = [self arrangedObjects];
    
    if ([arrangedObjects count]) {
		[self setSelectedObjects:@[[arrangedObjects firstObject]]];
    }
}

- (id)firstSelectedObject {
	return [[self selectedObjects] firstObject];
}

- (IBAction)selectLastObject:(id)sender {
	[self selectLastObject];
}

- (void)selectLastObject {
	NSArray *arrangedObjects = [self arrangedObjects];
	
	if ([arrangedObjects count]) {
		[self setSelectedObjects:@[[arrangedObjects lastObject]]];
	}
}

- (id)lastSelectedObject {
	return [[self selectedObjects] lastObject];
}

- (NSInteger)numberOfObjects {
	return [[self arrangedObjects] count];
}

@end
