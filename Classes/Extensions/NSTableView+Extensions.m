
#import "NSTableView+Extensions.h"

@implementation NSTableView (AJRInterfaceExtensions)

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger row = [self rowAtPoint:where];
	NSMenu *menu = nil;
	
	if (row != NSNotFound) {
		if ([[self delegate] respondsToSelector:@selector(tableView:menuForRow:)]) {
			menu = [(id <AJRTableViewDelegate>)[self delegate] tableView:self menuForRow:row];
		}
	}
	
	return menu;
}

@end
