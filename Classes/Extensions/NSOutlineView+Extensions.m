
#import "NSOutlineView+Extensions.h"

@implementation NSOutlineView (AJRInterfaceExtensions)

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger row = [self rowAtPoint:where];
	NSMenu *menu = nil;
	
	if (row != NSNotFound) {
		if ([[self delegate] respondsToSelector:@selector(outlineView:menuForItem:)]) {
            menu = [(id <AJROutlineViewDataSource>)[self delegate] outlineView:self menuForItem:[self itemAtRow:row]];
		}
	}
	
	return menu ?: [super menuForEvent:event];
}

- (NSView *)viewForItem:(id)item column:(NSInteger)columnIndex {
    NSInteger row = [self rowForItem:item];
    
    if (row >= 0) {
        return [self viewAtColumn:columnIndex row:row makeIfNecessary:NO];
    }
    
    return nil;
}

@end
