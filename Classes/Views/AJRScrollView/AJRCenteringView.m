
#import "AJRCenteringView.h"

#import "AJRScrollView.h"
#import "AJRBorder.h"
#import "AJRDropShadowBorder.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterface/NSBezierPath+Extensions.h>

@implementation AJRCenteringView

- (id)initWithFrame:(NSRect)aFrame {
    NSShadow *shadow;
    
    if ((self = [super initWithFrame:aFrame])) {
        self.gutter = 8.0;
        self.scale = 1.0;
        self.pageColor = [NSColor whiteColor];
        shadow = [[NSShadow alloc] init];
        [shadow setShadowColor:[NSColor darkGrayColor]];
        [shadow setShadowBlurRadius:_gutter];
        [shadow setShadowOffset:(NSSize){0.0, -_gutter / 2.0}];
        self.pageShadow = shadow;
    }
    return self;
}

- (id)initFromPrevious:(AJRCenteringView *)otherView {
    if ((self = [super initWithFrame:[otherView frame]])) {
        [self setBackgroundColor:[otherView backgroundColor]];
        self.scale = otherView.scale;
        self.gutter = otherView.gutter;
        self.pageColor = otherView.pageColor;
        self.pageShadow = otherView.pageShadow;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_frameCache) {
        NSZoneFree(NULL, _frameCache);
    }
}

#pragma mark Properties

- (void)setBackgroundColor:(NSColor *)aColor {
    if (_backgroundColor != aColor) {
        _backgroundColor = aColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setPageShadow:(NSShadow *)pageShadow {
    if (_pageShadow != pageShadow) {
        _pageShadow = pageShadow;
        [self setNeedsDisplay:YES];
    }
}

- (void)setPageColor:(NSColor *)pageColor {
    if (_pageColor != pageColor) {
        _pageColor = pageColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setScale:(CGFloat)scale {
    if (_scale != scale) {
        _scale = scale;
        if (ncvFlags._documentRespondsToViewForPage) {
            [self tile];
        } else {
            BOOL        saveFrameChange = [subview postsFrameChangedNotifications];
            BOOL        saveBoundsChange = [subview postsBoundsChangedNotifications];
            NSRect        bounds = [subview bounds];
            
            [subview setPostsFrameChangedNotifications:NO];
            [subview setPostsBoundsChangedNotifications:NO];
            [subview setFrame:(NSRect){{0.0, 0.0}, {bounds.size.width * scale, bounds.size.height * scale}}];
            [subview setBounds:(NSRect){{0.0, 0.0}, bounds.size}];
            [subview setPostsBoundsChangedNotifications:saveBoundsChange];
            [subview setPostsFrameChangedNotifications:saveFrameChange];
        }
    }
}

- (void)setGutter:(CGFloat)gutter {
    if (_gutter != gutter) {
        _gutter = gutter;
        [self tile];
    }
}

#pragma mark Layout

- (NSSize)sizeOfContentRect {
    AJRScrollView *scrollView = (AJRScrollView *)[clipView superview];
    NSSize size = [subview rectForPage:firstPage].size;
    
    size.width *= _scale;
    size.height *= _scale;
    
    pagePosition = AJRPagesSingle;
    
    if ([scrollView isKindOfClass:[AJRScrollView class]]) {
        NSInteger                pageCount = [scrollView pageCount];
        
        firstPage = [scrollView firstPage];
        lastPage = [scrollView lastPage];
        pagePosition = [scrollView pagePosition];
        if (_frameCache) {
            NSZoneFree(NULL, _frameCache); _frameCache = NULL;
        }
        
        if (activePage < firstPage) activePage = firstPage;
        if (activePage > lastPage) activePage = lastPage;
        
        if (lastPage == NSNotFound) {
            lastPage = firstPage;
            size.width += (_gutter * 2.0);
            size.height += (_gutter * 2.0);
            _frameCache = NSZoneCalloc(NULL, 1, sizeof(NSRect));
        } else {
            switch (pagePosition) {
                case AJRPagesVertical:
                    size.width += (_gutter * 2.0);
                    size.height = (size.height + _gutter) * pageCount + _gutter;
                    break;
                case AJRPagesHorizontal:
                    size.width = (size.width + _gutter) * pageCount + _gutter;
                    size.height += (_gutter * 2.0);
                    break;
                case AJRPagesTwoUpOddRight:
                    size.width = (size.width + _gutter) * 2.0 + _gutter;
                    if (firstPage % 2 == 1) {
                        size.height = (size.height + _gutter) * ((pageCount / 2) + 1) + _gutter;
                    } else {
                        size.height = (size.height + _gutter) * (((pageCount - 1) / 2) + 1) + _gutter;
                    }
                    break;
                case AJRPagesTwoUpOddLeft:
                    size.width = (size.width + _gutter) * 2.0 + _gutter;
                    if (firstPage % 2 == 0) {
                        size.height = (size.height + _gutter) * ((pageCount / 2) + 1) + _gutter;
                    } else {
                        size.height = (size.height + _gutter) * (((pageCount - 1) / 2) + 1) + _gutter;
                    }
                    break;
                case AJRPagesSingle:
                    size.width += (_gutter * 2.0);
                    size.height += (_gutter * 2.0);
                    break;
            }
            _frameCache = NSZoneCalloc(NULL, pageCount, sizeof(NSRect));
        }
    } else {
        size.width += (_gutter * 2.0);
        size.height += (_gutter * 2.0);
        
        firstPage = 0;
        lastPage = 0;
        activePage = 0;
        pagePosition = AJRPagesSingle;
    }
    
    return size;
}

- (void)tile {
    NSRect visibleRect = [clipView documentVisibleRect];
    NSRect newFrame;
    static BOOL recursionCatch = NO;
    
    if (recursionCatch) return;
    recursionCatch = YES;
    
    // First, get the size or our content rect. This is computed as the maximum boundary needed to display all our pages in the current layout.
    contentRect.origin = (NSPoint){0.0, 0.0};
    contentRect.size = [self sizeOfContentRect];
    
    // Make our actual subview "offscreen". This is because we fake it being on screen, and only move it on screen when an action occurs that requires it to be there.
    [subview setPostsFrameChangedNotifications:NO];
    [subview setPostsBoundsChangedNotifications:NO];
    if (ncvFlags._documentRespondsToViewForPage) {
        NSInteger pageNumber;
        NSRect pageRect;
        NSView *page;
        NSRect boundingRect = NSZeroRect;
        
        if ((firstPage != 0) && (lastPage != 0)) {
            for (pageNumber = firstPage; pageNumber <= lastPage; pageNumber++) {
                pageRect = [self pageRectangleForPage:pageNumber];
                //AJRPrintf(@"pageRect: %@\n", NSStringFromRect(pageRect));
                page = [subview viewForPage:pageNumber];
                if (!NSEqualRects(pageRect, [page frame])) {
                    [page setFrame:pageRect];
                    [page setBounds:NSIntegralRect((NSRect){{0.0, 0.0}, [subview rectForPage:pageNumber].size})];
                }
                if (_frameCache) {
                    _frameCache[pageNumber - firstPage] = pageRect;
                }
                //AJRPrintf(@"%C: %d: %R\n", self, pageNumber, pageRect);
                if (!NSEqualPoints(NSZeroPoint, [page bounds].origin)) {
                    [page setBounds:NSIntegralRect((NSRect){{0.0, 0.0}, [subview rectForPage:pageNumber].size})];
                }
                if ([[subview subviews] indexOfObjectIdenticalTo:page] == NSNotFound) {
                    [subview addSubview:page];
                }
                if (pageNumber == firstPage) {
                    boundingRect = pageRect;
                } else {
                    boundingRect = NSUnionRect(boundingRect, pageRect);
                }
            }
        }
        [subview setFrame:boundingRect];
    }
    
    // Initialize newFrame origin.
    newFrame.origin.x = 0.0;
    newFrame.origin.y = 0.0;
    
    // Decide if we going to use our contentRect's size or our visibleRect's size for our size. We use our visibleRect's size when it's larger than our contentRect's size. This is true for both the width and height computed separately.
    newFrame.size.width = (contentRect.size.width < visibleRect.size.width) ? visibleRect.size.width : contentRect.size.width;
    newFrame.size.height = (contentRect.size.height < visibleRect.size.height) ? visibleRect.size.height : contentRect.size.height;
    
    // Effectively, we now know the size our frame will be. Knowing this, we can place the origin of our contentRect, which will be at minimum our gutter size, and at best, centered in our clip view.
    contentRect.origin.x = rint((newFrame.size.width - contentRect.size.width) / 2.0);
    if (contentRect.origin.x < _gutter) contentRect.origin.x = _gutter;
    contentRect.origin.y = rint((newFrame.size.height - contentRect.size.height) / 2.0);
    if (contentRect.origin.y < _gutter) contentRect.origin.y = _gutter;
    
    if (ncvFlags._documentRespondsToViewForPage) {
        [subview setFrameOrigin:contentRect.origin];
    } else {
        [subview setFrame:[self pageRectangleForPage:activePage]];
    }
    
    [subview setPostsFrameChangedNotifications:YES];
    [subview setPostsBoundsChangedNotifications:YES];
    
    // Set our own frame. We'll turn of notifications from the clip view for a moment, because we don't want to enter this code recursively.
    [clipView setPostsFrameChangedNotifications:NO];
    NSRect    saveFrame = [subview frame]; // Because sometimes calling [self setFrame:], resizes my
    // subviews, even though my autoresizeSubviews mask is 0.
    [self setFrame:newFrame];
    [subview setFrame:saveFrame];
    [clipView setPostsFrameChangedNotifications:YES];
    
    recursionCatch = NO;
}

- (NSView *)subview {
    return subview;
}

- (NSView *)documentView {
    if (ncvFlags._documentRespondsToViewForPage) {
        return [subview viewForPage];
    }
    return subview;
}

- (NSView *)viewForPage:(NSInteger)pageNumber {
    if (ncvFlags._documentRespondsToViewForPage) {
        return [subview viewForPage:pageNumber];
    }
    return subview;
}

#pragma mark NSView

- (NSRect)pageRectangleForPage:(NSInteger)pageNumber {
    NSRect rect = [subview frame];
    NSInteger oneAdjustedPage = pageNumber - firstPage + 1;
    NSInteger row;
    
    if ((pageNumber < firstPage) || (pageNumber > lastPage)) return NSZeroRect;
    
    rect = [subview rectForPage:pageNumber];
    rect.size.width *= _scale;
    rect.size.height *= _scale;
    
    switch (pagePosition) {
        case AJRPagesVertical:
            rect.origin.x = contentRect.origin.x;
            rect.origin.y = contentRect.origin.y + contentRect.size.height - (rect.size.height + _gutter) * oneAdjustedPage - _gutter;
            break;
        case AJRPagesHorizontal:
            rect.origin.x = contentRect.origin.x + (rect.size.width + _gutter) * (oneAdjustedPage - 1);
            rect.origin.y = contentRect.origin.y;
            break;
        case AJRPagesTwoUpOddRight:
            if (firstPage % 2 == 0) {
                row = (oneAdjustedPage - 1) / 2;
                if (oneAdjustedPage % 2 == 1) {
                    rect.origin.x = contentRect.origin.x;
                } else {
                    rect.origin.x = contentRect.origin.x + rect.size.width + _gutter;
                }
            } else {
                row = oneAdjustedPage / 2;
                if (oneAdjustedPage % 2 == 1) {
                    rect.origin.x = contentRect.origin.x + rect.size.width + _gutter;
                } else {
                    rect.origin.x = contentRect.origin.x;
                }
            }
            rect.origin.y = contentRect.origin.y + contentRect.size.height - (rect.size.height + _gutter) * (row + 1) - _gutter;
            break;
        case AJRPagesTwoUpOddLeft:
            if (firstPage % 2 == 0) {
                row = oneAdjustedPage / 2;
                if (oneAdjustedPage % 2 == 0) {
                    rect.origin.x = contentRect.origin.x;
                } else {
                    rect.origin.x = contentRect.origin.x + rect.size.width + _gutter;
                }
            } else {
                row = (oneAdjustedPage - 1) / 2;
                if (oneAdjustedPage % 2 == 0) {
                    rect.origin.x = contentRect.origin.x + rect.size.width + _gutter;
                } else {
                    rect.origin.x = contentRect.origin.x;
                }
            }
            rect.origin.y = contentRect.origin.y + contentRect.size.height - (rect.size.height + _gutter) * (row + 1);
            break;
        case AJRPagesSingle:
            rect.origin = contentRect.origin;
            break;
    }
    
    return rect;
}

// Draw the page number. This is the page number that always displays. The user might opt to have a different page number that displays in a header or footer, but this is the phisical page number of the page.
- (void)drawPageNumber:(NSInteger)aPageNumber inRect:(NSRect)rect {
    CGFloat pointSize = 12.0 / _scale;
    NSFont *font;
    NSString *string;
    NSDictionary *attributes;
    
    font = [NSFont boldSystemFontOfSize:pointSize];
	attributes = @{
				   NSForegroundColorAttributeName:[NSColor controlHighlightColor],
				   NSFontAttributeName:font,
				   };
    
    string = [NSString stringWithFormat:@"%ld", aPageNumber];
    [string drawAtPoint:(NSPoint){rect.size.width - [string sizeWithAttributes:attributes].width - 5.0, rect.size.height - pointSize - 4.0} withAttributes:attributes];
}

- (void)drawPageBorderAroundRect:(NSRect)rect {
    [NSGraphicsContext saveGraphicsState];
    [_pageColor set];
    [_pageShadow set];
    NSRectFill(rect);
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawRect:(NSRect)aRect {
    NSRect rect, pageRect;
    NSInteger pageNumber;
    
    if (ncvFlags._isPrinting) {
        AJRPrintf(@"How odd\n");
        return;
    }
    
    if (!ncvFlags._documentRespondsToViewForPage) {
        [subview setPostsFrameChangedNotifications:NO];
        [subview setPostsBoundsChangedNotifications:NO];
    }
    
    [_backgroundColor set];
    NSRectFill(aRect);
    
    rect = [self bounds];
    
    for (pageNumber = firstPage; pageNumber <= lastPage; pageNumber++) {
        pageRect = _frameCache[pageNumber - firstPage];
        pageRect = [self convertRect:pageRect fromView:subview];
        if (NSIntersectsRect(pageRect, aRect)) {
            [self drawPageBorderAroundRect:pageRect];
        }
    }
    
    if (!ncvFlags._documentRespondsToViewForPage) {
        [subview setFrame:[self pageRectangleForPage:activePage]];
        [subview setPostsFrameChangedNotifications:YES];
        [subview setPostsBoundsChangedNotifications:YES];
    }
}

- (void)addSubview:(NSView *)aSubview {
    if (subview) {
        [subview setPostsFrameChangedNotifications:NO];
        [subview setPostsBoundsChangedNotifications:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:subview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:subview];
    }
    
    subview = aSubview;
    
    if (subview) {
        [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        ncvFlags._documentRespondsToViewForPage = [subview respondsToSelector:@selector(viewForPage:)];
        
        [super addSubview:subview];
        [self tile];
        
        _savedSubviewSize = [subview frame].size;
        [subview setPostsFrameChangedNotifications:YES];
        [subview setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewFrameDidChange:) name:NSViewFrameDidChangeNotification object:subview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:subview];
    }
}

- (void)subviewFrameDidChange:(NSNotification *)notification {
    NSSize newSize;
    
    newSize = [(NSView *)[notification object] frame].size;
    if (!NSEqualSizes(_savedSubviewSize, newSize)) {
        [self tile];
        _savedSubviewSize = newSize;
    }
}

- (void)subviewBoundsDidChange:(NSNotification *)notification {
    NSSize newSize;
    
    newSize = [(NSView *)[notification object] frame].size;
    if (!NSEqualSizes(_savedSubviewSize, newSize)) {
        [self tile];
        _savedSubviewSize = newSize;
    }
}

- (void)superviewFrameDidChange:(NSNotification *)notification {
    [self tile];
}

- (void)viewWillMoveToWindow:(NSWindow *)aWindow {
    if ([[self subviews] indexOfObjectIdenticalTo:subview] == NSNotFound) {
        [self addSubview:subview];
    }
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    if (clipView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:clipView];
    }
    
    clipView = (NSClipView *)newSuperview;
    [self tile];
    
    [newSuperview setPostsFrameChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(superviewFrameDidChange:) name:NSViewFrameDidChangeNotification object:clipView];
}

- (BOOL)isFlipped {
    return YES;
}

- (void)setActivePage:(NSInteger)aPage {
    NSRect rect;
    
    if ((activePage != aPage) && ((aPage >= firstPage) && (aPage <= lastPage))) {
        activePage = aPage;
        [self setNeedsDisplay:YES];
        if ([[clipView superview] isKindOfClass:[NSScrollView class]]) {
            [[(NSScrollView *)[clipView superview] horizontalRulerView] setNeedsDisplay:YES];
            [[(NSScrollView *)[clipView superview] verticalRulerView] setNeedsDisplay:YES];
        }
    }
    
    if (_frameCache) {
        rect = _frameCache[activePage - firstPage];
    } else {
        rect = [self pageRectangleForPage:activePage];
    }
    rect = NSInsetRect(rect, -_gutter, -_gutter);
    [self scrollRectToVisible:[self convertRect:rect fromView:subview]];
}

- (NSInteger)activePage {
    return activePage;
}

// Messages we forward to our subview. These are mostly events, and require us to move the actual view over the page being acted upon. This will allow the view to respond in a normal manner and in such a way that it doesn't have to be aware that it's being displayed in multiple views.

- (NSInteger)pageForEvent:(NSEvent *)anEvent {
    return [self pageForPoint:[self convertPoint:[anEvent locationInWindow] fromView:nil]];
}

- (NSInteger)pageForPoint:(NSPoint)aPoint {
    if (_frameCache) {
        aPoint = [self convertPoint:aPoint fromView:subview];
        for (NSInteger x = firstPage; x <= lastPage; x++) {
            if (NSPointInRect(aPoint, _frameCache[x - firstPage])) return x;
        }
    }
    
    return NSNotFound;
}

- (NSRange)pageRangeForRect:(NSRect)rect {
    NSInteger minPage = NSIntegerMax;
    NSInteger maxPage = 0;
    
    if (_frameCache) {
        rect = [self convertRect:rect fromView:subview];
        for (NSInteger x = firstPage; x <= lastPage; x++) {
            if (NSIntersectsRect(rect, _frameCache[x - firstPage])) {
                if (x < minPage) minPage = x;
                if (x > maxPage) maxPage = x;
            }
        }
    }
    
    return (NSRange){minPage, (maxPage - minPage) + 1};
}

// These are methods that must be forwarded to our correct page. Mostly, they'll just focus the correct page and then allow normal mechanisms to take over.

- (void)mouseDown:(NSEvent *)event {
    static BOOL recursionCatch = NO;
    
    if (!recursionCatch) {
        NSInteger        pageNumber = [self pageForEvent:event];
        
        recursionCatch = YES;
        
        //AJRPrintf(@"Mouse down %@\n", pageNumber == NSNotFound ? @"missed" : [NSString stringWithFormat:@"in page %d", pageNumber]);
        
        if (pageNumber != NSNotFound) {
            AJRScrollView    *scrollView = (AJRScrollView *)[clipView superview];
            
            if ([scrollView isKindOfClass:[AJRScrollView class]]) {
                [scrollView setPageNumber:pageNumber];
            } else {
                [self setActivePage:pageNumber];
            }
            
            [subview mouseDown:event];
        }
        
        recursionCatch = NO;
    }
}

- (void)printOperationDidRun:(id)context {
    ncvFlags._isPrinting = NO;
}

- (void)print:(id)sender {
    NSPrintInfo *printInfo;
    NSPrintOperation *operation;
    
    printInfo = [[NSPrintInfo sharedPrintInfo] copy];
    [printInfo setPaperSize:[[self subview] rectForPage:printingPageNumber].size];
    
    ncvFlags._isPrinting = YES;
    [operation runOperationModalForWindow:[self window] delegate:self didRunSelector:@selector(printOperationDidRun:) contextInfo:nil];
}

- (void)printRect:(NSRect)rect {
    NSView *view = [[self subview] viewForPage:printingPageNumber];
    NSRect frame, bounds;
    
    rect = (NSRect){{0, 0}, [[self subview] rectForPage:printingPageNumber].size};
    //AJRPrintf(@"printRect:%@, %@, %d\n", NSStringFromRect(rect), view, printingPageNumber);
    frame = [view frame];
    bounds = [view bounds];
    [view setFrame:rect];
    [view setBounds:rect];
    //[view lockFocus];
    [view drawRect:rect];
    //[view unlockFocus];
    [view setFrame:frame];
    [view setBounds:bounds];
}

- (NSRect)rectForPage:(NSInteger)aPageNumber {
    printingPageNumber = aPageNumber;
    
    //AJRPrintf(@"-[%@ %@%d]\n", NSStringFromClass([self class]), NSStringFromSelector(_cmd), printingPageNumber);
    
    return [[self subview] rectForPage:aPageNumber];
}

- (BOOL)knowsPageRange:(NSRangePointer)range {
    BOOL result = [[self subview] knowsPageRange:range];
    
    return result;
}

- (NSPoint)locationOfPrintRect:(NSRect)aRect {
    return (NSPoint){0.0, 0.0};
}

- (void)displayRectIgnoringOpacity:(NSRect)rect {
    if (ncvFlags._isPrinting) {
        //[self lockFocus];
        [self printRect:rect];
        //[self unlockFocus];
    } else {
        [super displayRectIgnoringOpacity:rect];
    }
}

@end
