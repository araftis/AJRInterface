
#import "AJRProgressView.h"

@implementation AJRProgressView

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        NSProgressIndicator *progress;
        NSRect frame;
        
        self.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.25];
        
        frame.size.width = 32.0;
        frame.size.height = 32.0;
        frame.origin.x = frameRect.origin.x + (frameRect.size.width - frame.size.width) / 2.0;
        frame.origin.y = frameRect.origin.y + (frameRect.size.height - frame.size.height) / 2.0;
        progress = [[NSProgressIndicator alloc] initWithFrame:frame];
        [progress setAutoresizingMask:NSViewMaxXMargin | NSViewMinXMargin | NSViewMaxYMargin | NSViewMinYMargin];
		[progress setStyle:NSProgressIndicatorStyleSpinning];
        [progress setIndeterminate:YES];
        [self addSubview:progress];
        [progress startAnimation:self];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@synthesize backgroundColor = _backgroundColor;

- (void)drawRect:(NSRect)rect {
    [_backgroundColor set];
    NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (void)viewDidMoveToSuperview {
    NSView *superview = [self superview];
    
    if (superview) {
        [superview setPostsFrameChangedNotifications:YES];
        [self setFrame:[superview frame]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(superviewFrameDidChange:) name:NSViewFrameDidChangeNotification object:superview];
    }
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    if ([self superview]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)superviewFrameDidChange:(NSNotification *)notification {
    [self setFrame:[[self superview] frame]];
}

- (BOOL)isOpaque {
    return NO;
}

@end
