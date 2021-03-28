
#import "AJRSourceOutlineView.h"

#import "NSColor+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@interface NSOutlineView (Private)

- (struct _NSRect)_frameOfOutlineCellAtRow:(NSInteger)row;

@end


@implementation AJRSourceOutlineView

//- (void)_drawOutlineCell:(id)cell withFrame:(NSRect)frame inView:(id)aView
//{
//   [[NSColor redColor] set];
//   NSFrameRect(frame);
//}

- (void)_setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActiveApplication:) name:NSApplicationWillBecomeActiveNotification object:NSApp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActiveApplication:) name:NSApplicationWillResignActiveNotification object:NSApp];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self _setup];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (NSGradient *)highlightFocusedGradient {
    @synchronized (self) {
        if (highlightFocusedGradient == nil) {
            highlightFocusedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:93.0 / 255.0 green:148.0 / 255.0 blue:214.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithDeviceRed:25.0 / 255.0 green:86.0 / 255.0 blue:173.0 / 255.0 alpha:1.0]];
        }
    }
    return highlightFocusedGradient;
}

- (NSGradient *)highlightGradient {
    @synchronized (self) {
        if (highlightGradient == nil) {
            highlightGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:161.0 / 255.0 green:176.0 / 255.0 blue:207.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithDeviceRed:113.0 / 255.0 green:133.0 / 255.0 blue:171.0 / 255.0 alpha:1.0]];
        }
    }
    return highlightGradient;
}

- (void)drawRow:(NSInteger)row clipRect:(NSRect)frame; {
    if ([[self selectedRowIndexes] containsIndex:row]) {
//        if ([self levelForRow:row] == 0) {
//            [[self backgroundColor] set];
//            NSRectFill([self rectOfRow:row]);            
//        } else {
            NSGradient        *gradient;
            NSRect            rect = [self rectOfRow:row];
            
            if ([[self window] firstResponder] == self && [NSApp isActive]) {
                gradient = [self highlightFocusedGradient];
            } else {
                gradient = [self highlightGradient];
            }
            rect.size.height -= 1.0;
            [gradient drawInRect:rect angle:90.0];
            [[gradient interpolatedColorAtLocation:1.0/3.0] set];
            rect.size.height = 1.0;
            NSRectFill(rect);
//        }
    }
    
    [super drawRow:row clipRect:frame];
}

- (void)tile {
    NSRect        frame = [[self enclosingScrollView] documentVisibleRect];
    
    if ([[self tableColumns] count] > 1) {
        [[[self tableColumns] objectAtIndex:0] setWidth:frame.size.width - 20];
        [[[self tableColumns] objectAtIndex:1] setWidth:15];
    } else {
        [[[self tableColumns] objectAtIndex:0] setWidth:frame.size.width];
    }
    [super tile];
//    AJRPrintf(@"%C: outline view's frame: %R\n", self, [self frame]);
//    AJRPrintf(@"%C: scroll view's frame: %R\n", self, [[self enclosingScrollView] frame]);
//    AJRPrintf(@"%C: content view's frame: %R\n", self, [[[self enclosingScrollView] contentView] frame]);
//    AJRPrintf(@"%C: document view's frame: %R\n", self, [[[self enclosingScrollView] documentView] frame]);
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self tile];
}

- (void)setFrameSize:(NSSize)size {
    [super setFrameSize:size];
    [self tile];
}

- (NSColor *)backgroundColor {
    if ([NSApp isActive]) {
        return [NSColor sourceActiveBackgroundColor];
    }
    return [NSColor sourceInactiveBackgroundColor];
}

- (void)toggleActiveApplication:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

@end
