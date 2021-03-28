
#import "AJRPagedScrollView.h"

#import "AJRPageLayout.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRPagedScrollView

#pragma mark - Init

- (NSMenuItem *)addZoom:(CGFloat)zoom toMenu:(NSMenu *)menu {
    NSMenuItem  *item;
    
    item = [menu addItemWithTitle:[NSString stringWithFormat:@"%.0f%%", zoom * 100.0] action:@selector(selectZoom:) keyEquivalent:@""];
    [item setTarget:self];
    [item setRepresentedObject:[NSNumber numberWithFloat:zoom]];
    
    return item;
}

- (void)_commonInit {
    NSMenu *menu;
    NSMenuItem *item;
    
    // Because this doesn't look right for right now.
    [self setAutohidesScrollers:NO];
    
    _viewPopUp = [[NSPopUpButton alloc] initWithFrame:(NSRect){{0.0, 0.0}, {62.0, 18.0}} pullsDown:NO];
    [_viewPopUp setBordered:NO];
    [[_viewPopUp cell] setControlSize:NSControlSizeSmall];
    [[_viewPopUp cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]]];
    
    [_viewPopUp removeAllItems];
    menu = [_viewPopUp menu];
    for (Class pageLayout in [[AJRPageLayout pageLayouts] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] caseInsensitiveCompare:[obj2 name]];
    }]) {
        NSMenuItem  *item = [[_viewPopUp menu] addItemWithTitle:[pageLayout name] action:@selector(selectPageLayout:) keyEquivalent:@""];
        [item setTarget:self];
        [item setRepresentedObject:[pageLayout identifier]];
    }
    [menu addItem:[NSMenuItem separatorItem]];
    [self addZoom:0.25 toMenu:menu];
    [self addZoom:0.50 toMenu:menu];
    [self addZoom:0.75 toMenu:menu];
    [self addZoom:1.00 toMenu:menu];
    [self addZoom:1.25 toMenu:menu];
    [self addZoom:1.50 toMenu:menu];
    [self addZoom:2.00 toMenu:menu];
    [self addZoom:3.00 toMenu:menu];
    [self addZoom:4.00 toMenu:menu];
    [menu addItem:[NSMenuItem separatorItem]];
    item = [menu addItemWithTitle:@"Fit Width" action:@selector(zoomToWidth:) keyEquivalent:@""];
    [item setTarget:self];
    item = [menu addItemWithTitle:@"Fit Height" action:@selector(zoomToHeight:) keyEquivalent:@""];
    [item setTarget:self];
    
    _controlsGradient = [[NSGradient alloc] initWithColorsAndLocations:
                         [NSColor colorWithDeviceWhite:0.97 alpha:1.0], 0.0,
                         [NSColor colorWithDeviceWhite:1.00 alpha:1.0], 0.25,
                         [NSColor colorWithDeviceWhite:0.84 alpha:1.0], 1.0,
                         nil];
    _controlsDividerColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
    _controlsTopDividerColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    
    _pagesLabel = [[NSTextField alloc] initWithFrame:(NSRect){NSZeroPoint, {100.0, 18.0}}];
    [_pagesLabel setBordered:NO];
    [_pagesLabel setDrawsBackground:NO];
    [_pagesLabel setBackgroundColor:[NSColor clearColor]];
    [_pagesLabel setEditable:NO];
    [_pagesLabel setSelectable:NO];
    [_pagesLabel setStringValue:@""];
    [[_pagesLabel cell] setControlSize:NSControlSizeSmall];
    [_pagesLabel setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]]];
    
    [self setBackgroundColor:NSColor.underPageBackgroundColor];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self _commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        [self _commonInit];
    }
    return self;
}

#pragma mark - Destruction

- (void)dealloc {
    [[self documentView] removeObserver:self forKeyPath:@"scale"];
}

#pragma mark - Utilities

- (AJRPagedView *)pagedView {
    return AJRObjectIfKindOfClassOrAssert([self documentView], AJRPagedView);
}

- (void)_syncPopUp {
    AJRPagedView *pagedView = [self pagedView];
    CGFloat scale = [pagedView scale];
    
    for (NSMenuItem *item in [_viewPopUp itemArray]) {
        id    representedObject = [item representedObject];
        
        if ([representedObject isKindOfClass:[NSNumber class]]) {
            if ([[item representedObject] floatValue] == scale) {
                [_viewPopUp selectItem:item];
            }
        }
    }
}

#pragma mark - Properties

- (void)setScale:(CGFloat)scale {
    [[self pagedView] setScale:scale];
    [self _syncPopUp];
}

- (CGFloat)scale {
    return [[self pagedView] scale];
}

#pragma mark - NSScrollView

- (void)setDocumentView:(NSView *)view {
    NSView *current = [self documentView];
    
    if (current && current != view) {
        [current removeObserver:self forKeyPath:@"scale"];
    }
    
    [super setDocumentView:view];
    
    if (view) {
        [view addObserver:self forKeyPath:@"scale" options:NSKeyValueObservingOptionInitial context:NULL];
        [view addObserver:self forKeyPath:@"visiblePageIndexes" options:NSKeyValueObservingOptionInitial context:NULL];
    }
}

- (void)tile {
    NSScroller *horizontalScroller;
    NSRect horizontalScrollerFrame;
    NSRect verticalRulerFrame = NSZeroRect;
    NSRect frame;
    
    [super tile];
    
    if ([self hasVerticalRuler] && [self rulersVisible]) {
        verticalRulerFrame = [[self verticalRulerView] frame];
    }
    
    horizontalScroller = [self horizontalScroller];
    horizontalScrollerFrame = [horizontalScroller frame];
    
    frame = [_viewPopUp    frame];
    frame.origin.y = horizontalScrollerFrame.origin.y + 1.0;
    frame.size.height = horizontalScrollerFrame.size.height - 1.0;
    frame.origin.x = verticalRulerFrame.origin.x + verticalRulerFrame.size.width;
    
    horizontalScrollerFrame.origin.x += (frame.size.width + 1.0);
    horizontalScrollerFrame.size.width -= (frame.size.width + 1.0);
    
    if ([_viewPopUp superview] != self) {
        [self addSubview:_viewPopUp];
    }
    
    [_viewPopUp setFrame:frame];
    
    frame.origin.x += frame.size.width + 1;
    frame.size.width = 133.0;
    
    if ([_pagesLabel superview] != self) {
        [self addSubview:_pagesLabel];
    }
    
    [_pagesLabel setFrame:frame];
    
    horizontalScrollerFrame.origin.x += (frame.size.width + 1.0);
    horizontalScrollerFrame.size.width -= (frame.size.width + 1.0);
    
    [horizontalScroller setFrame:horizontalScrollerFrame];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect frame = [_viewPopUp frame];
    NSRect topEdgeFrame;
    
    [super drawRect:dirtyRect];
    
    [_controlsGradient drawInRect:frame angle:90.0];
    
    topEdgeFrame = frame;
    
    frame.origin.x += frame.size.width;
    frame.size.width = 1.0;
    [_controlsDividerColor set];
    NSRectFill(frame);
    
    frame = [_pagesLabel frame];
    [_controlsGradient drawInRect:frame angle:90.0];
    
    topEdgeFrame = NSUnionRect(topEdgeFrame, frame);
    
    frame.origin.x += frame.size.width;
    frame.size.width = 1.0;
    [_controlsDividerColor set];
    NSRectFill(frame);
    
    topEdgeFrame.origin.y -= 1.0;
    topEdgeFrame.size.width    += 1.0;
    topEdgeFrame.size.height = 1.0;
    [_controlsTopDividerColor set];
    NSRectFill(topEdgeFrame);
}

#pragma mark - Actions

- (void)selectPageLayout:(id)sender {
    AJRPageLayout *newLayout = [AJRPageLayout pageLayoutForView:[self pagedView] withIdentifier:[sender representedObject]];
    id <AJRPagedViewDelegate> delegate = [[self pagedView] delegate];
    BOOL shouldSet = YES;
    
    if (delegate && [delegate respondsToSelector:@selector(pagedView:shouldSwitchToLayout:)] && ![delegate pagedView:[self pagedView] shouldSwitchToLayout:newLayout]) {
        shouldSet = NO;
    }
    if (shouldSet) {
        if (delegate && [delegate respondsToSelector:@selector(pagedView:willSwitchToLayout:)]) {
            [delegate pagedView:[self pagedView] shouldSwitchToLayout:newLayout];
        }
        [[self pagedView] setPageLayout:newLayout];
        if (delegate && [delegate respondsToSelector:@selector(pagedView:didSwitchToLayout:)]) {
            [delegate pagedView:[self pagedView] didSwitchToLayout:newLayout];
        }
        [self _syncPopUp];
    }
}

- (void)selectZoom:(id)sender {
    AJRPagedView *pagedView = [self pagedView];
    
    if ([pagedView delegate] && [[pagedView delegate] respondsToSelector:@selector(pagedView:willScaleTo:)]) {
        [[pagedView delegate] pagedView:pagedView willScaleTo:[[sender representedObject] floatValue]];
    }
    [pagedView setScale:[[sender representedObject] floatValue]];
    if ([pagedView delegate] && [[pagedView delegate] respondsToSelector:@selector(pagedView:didScaleTo:)]) {
        [[pagedView delegate] pagedView:pagedView didScaleTo:[[sender representedObject] floatValue]];
    }
    [self _syncPopUp];
}

- (void)zoomToWidth:(id)sender {
    [self _syncPopUp];
}

- (void)zoomToHeight:(id)sender {
    [self _syncPopUp];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"scale"]) {
        [self _syncPopUp];
    } else if ([keyPath isEqualToString:@"visiblePageIndexes"]) {
        NSMutableString *string = [NSMutableString string];
        NSIndexSet *indexes;
        AJRPagedView *pagedView = [self pagedView];
        
        indexes = [pagedView visiblePageIndexes]; 
        [indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
            if ([string length]) {
                [string appendString:@", "];
            } else {
                if ([indexes count] != 1) {
                    [string appendString:@"Pages "];
                } else {
                    [string appendString:@"Page "];
                }
            }
            if (range.length == 1) {
                [string appendFormat:@"%lu", range.location + 1];
            } else {
                [string appendFormat:@"%lu-%lu", range.location + 1, range.location + range.length];
            }
        }];
        [string appendFormat:@" of %lu", [[pagedView pageDataSource] pageCountForPagedView:pagedView]];
        
        [_pagesLabel setStringValue:string];
    }
}

#pragma mark - NSMenuValidation

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    id representedObject = [item representedObject];
    AJRPagedView *pagedView = [self pagedView];
    
    if ([representedObject isKindOfClass:[NSString class]]) {
        if ([representedObject isEqualToString:[[[pagedView pageLayout] class] identifier]]) {
            [item setState:NSControlStateValueOn];
        } else {
            [item setState:NSControlStateValueOff];
        }
    }
    return YES;
}

@end
