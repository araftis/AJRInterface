
#import "AJRScrollView.h"

#import "AJRCenteringView.h"
#import "AJRFlippedCenteringView.h"
#import "AJRImages.h"
#import "AJRScrollViewAccessories.h"
#import "AJRScrollViewPrivate.h"
#import "NSBundle+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>

NSString *AJRScrollViewDidChangeZoomPercent = @"AJRScrollViewDidChangeZoomPercent";
NSString *AJRScrollViewPercentKey = @"AJRScrollViewPercentKey";

NSString *AJRViewDidChangePageCount = @"AJRViewDidChangePageCount";

@interface NLSScrollView : AJRScrollView
@end

@implementation NLSScrollView
@end


@implementation AJRScrollView

- (void)awakeFromNib
{
    _hasAwakened = YES;
    [[[super documentView] subview] addObserver:self forKeyPath:@"pages" options:0 context:NULL];
}

+ (NSImage *)_pagesImage
{
    static NSImage        *image = nil;
    
    if (!image) {
        NSString     *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Scroll View Pop Up Paper" ofType:@"tiff"];
        if (path) {
            image = [[NSImage alloc] initWithContentsOfFile:path];
        }
    }
    
    return image;
}

+ (NSImage *)_pagesImageD
{
    static NSImage        *image = nil;
    
    if (!image) {
        NSString     *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Scroll View Pop Up Paper D" ofType:@"tiff"];
        if (path) {
            image = [[NSImage alloc] initWithContentsOfFile:path];
        }
    }
    
    return image;
}

- (NSPopUpButton *)_createPagesMatrix
{
    NSInteger        x;
    NSMenuItem        *subitem;
    NSPopUpButton    *popUpButton;
    NSArray            *names;
    
    names = [NSArray arrayWithObjects:@"AJRPagesVertical", @"AJRPagesHorizontal", @"AJRPagesTwoUpOddRight", @"AJRPagesTwoUpOddLeft", @"AJRPagesSingle", nil];
    
    popUpButton = [[NSPopUpButton alloc] initWithFrame:(NSRect){{0.0, 0.0}, {15.0, 15.0}} pullsDown:NO];
    [[NSNotificationCenter defaultCenter] addObserver:popUpButton selector:@selector(setNeedsDisplay:) name:NSWindowDidResignKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:popUpButton selector:@selector(setNeedsDisplay:) name:NSWindowDidBecomeKeyNotification object:[self window]];
    
    for (x = 0; x < (const NSInteger)[names count]; x++) {
        [popUpButton addItemWithTitle:[names objectAtIndex:x]];
        subitem = [[popUpButton itemArray] lastObject];
        [subitem setImage:[AJRImages imageNamed:[names objectAtIndex:x] forObject:self]];
        [subitem setTarget:self];
        [subitem setAction:@selector(selectPagePosition:)];
        [subitem setTag:x];
    }
    
    return popUpButton;
}

- (id)_test
{
    return [super documentView];
}

- (void)_setup
{
    if (!_hasSetup && [super documentView]) {
        AJRCenteringView        *center;
        id                    documentView;
        
        _hasSetup = YES;
        
        documentView = [super documentView];
        //center = [[AJRFlippedCenteringView alloc] initWithFrame:[self documentVisibleRect]];
        center = [[AJRCenteringView alloc] initWithFrame:[self documentVisibleRect]];
        [center setBackgroundColor:[NSColor controlShadowColor]];
        [super setDocumentView:center];
        [center addSubview:documentView];
        
        horizontalAccessoriesRight = [[NSMutableArray allocWithZone:nil] init];
        horizontalAccessoriesLeft = [[NSMutableArray allocWithZone:nil] init];
        verticalAccessoriesTop = [[NSMutableArray allocWithZone:nil] init];
        verticalAccessoriesBottom = [[NSMutableArray allocWithZone:nil] init];
        
        showsZoom = YES;
        zoomButton = [[_AJRSVPopUpButton alloc] initWithFrame:(NSRect){{0.0, 0.0}, {85.0, 15.0}} pullsDown:NO];
        [zoomButton addItemWithTitle:@"25%"];
        [zoomButton addItemWithTitle:@"50%"];
        [zoomButton addItemWithTitle:@"75%"];
        [zoomButton addItemWithTitle:@"100%"];
        [zoomButton addItemWithTitle:@"125%"];
        [zoomButton addItemWithTitle:@"150%"];
        [zoomButton addItemWithTitle:@"200%"];
        [zoomButton addItemWithTitle:@"400%"];
        [zoomButton addItemWithTitle:@"800%"];
        [zoomButton addItemWithTitle:@"Size to Fit"];
        [zoomButton addItemWithTitle:@"Custom..."];
        [zoomButton setTitle:@"100%"];
        [zoomButton setTarget:self];
        [zoomButton setAction:@selector(setZoom:)];
        [zoomButton setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [zoomButton setBordered:NO];
        
        [self addHorizontalAccessory:zoomButton position:AJRAccessoriesRight];
        
        oldScalePercent = 100;
        
        [self addVerticalAccessory:[self _createPagesMatrix] position:AJRAccessoriesTop];
    }
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    [self _setup];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[super documentView] subview] removeObserver:self forKeyPath:@"pages"];
}

- (void)addHorizontalAccessory:(NSView *)anAccessory position:(AJRAccessoryPosition)aPosition
{
    switch (aPosition) {
        case AJRAccessoriesLeft:
            [horizontalAccessoriesLeft addObject:anAccessory];
            break;
        case AJRAccessoriesRight:
            [horizontalAccessoriesRight addObject:anAccessory];
            break;
        case AJRAccessoriesTop:
        case AJRAccessoriesBottom:
            [NSException raise:NSInvalidArgumentException format:@"Horizontal accessories can only be positioned to the left or the right."];
            break;
    }
    
    [self addSubview:anAccessory];
    
    [self tile];
    [self setNeedsDisplay:YES];
}

- (void)addVerticalAccessory:(NSView *)anAccessory
                    position:(AJRAccessoryPosition)aPosition
{
    switch (aPosition) {
        case AJRAccessoriesLeft:
        case AJRAccessoriesRight:
            [NSException raise:NSInvalidArgumentException format:@"Vertical accessories can only be positioned at the top or bottom."];
            break;
        case AJRAccessoriesTop:
            [verticalAccessoriesTop addObject:anAccessory];
            break;
        case AJRAccessoriesBottom:
            [verticalAccessoriesBottom addObject:anAccessory];
            break;
    }
    
    [self addSubview:anAccessory];
    
    [self tile];
    [self setNeedsDisplay:YES];
}

- (void)removeAccessory:(NSView *)accessory
{
    BOOL        found = NO;
    NSUInteger    index;
    
    if ((index = [verticalAccessoriesTop indexOfObjectIdenticalTo:accessory]) != NSNotFound) {
        found = YES;
        [verticalAccessoriesTop removeObjectAtIndex:index];
    } else if ((index = [verticalAccessoriesBottom indexOfObjectIdenticalTo:accessory]) != NSNotFound) {
        found = YES;
        [verticalAccessoriesBottom removeObjectAtIndex:index];
    } else if ((index = [horizontalAccessoriesLeft indexOfObjectIdenticalTo:accessory]) != NSNotFound) {
        found = YES;
        [horizontalAccessoriesLeft removeObjectAtIndex:index];
    } else if ((index = [horizontalAccessoriesRight indexOfObjectIdenticalTo:accessory]) != NSNotFound) {
        found = YES;
        [horizontalAccessoriesRight removeObjectAtIndex:index];
    }
    
    if (found) {
        [self tile];
        [self setNeedsDisplay:YES];
    }
}

- (void)updateRulers:(const NSRect *)rect {
	NSRulerView *h = [self horizontalRulerView];
	NSRulerView *v = [self verticalRulerView];
	static NSRect old = {{0.0, 0.0}, {0.0, 0.0}};
	NSRect work;
	
	if (!rect) {
		if (!NSIsEmptyRect(old)) {
			[h moveRulerlineFromLocation:old.origin.x toLocation:0.0];
			[h moveRulerlineFromLocation:old.origin.x + old.size.width toLocation:0.0];
			[v moveRulerlineFromLocation:old.origin.y toLocation:0.0];
			[v moveRulerlineFromLocation:old.origin.y + old.size.height toLocation:0.0];
		}
		old = (NSRect){{0.0, 0.0}, {0.0, 0.0}};
	} else {
		work = [h convertRect:*rect fromView:[[super documentView] subview]];
		[h moveRulerlineFromLocation:old.origin.x toLocation:work.origin.x];
		[h moveRulerlineFromLocation:old.origin.x + old.size.width toLocation:work.origin.x + work.size.width];
		old.origin.x = work.origin.x;
		old.size.width = work.size.width;
		work = [v convertRect:*rect fromView:[[super documentView] subview]];
		[v moveRulerlineFromLocation:old.origin.y toLocation:work.origin.y];
		[v moveRulerlineFromLocation:old.origin.y + old.size.height toLocation:work.origin.y + work.size.height];
		old.origin.y = work.origin.y;
		old.size.height = work.size.height;
	}
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (id)delegate {
    return delegate;
}

- (NSRange)visiblePageRange
{
    return [(AJRCenteringView *)[self documentView] pageRangeForRect:[self documentVisibleRect]];
}

- (void)_updatePageText
{
    NSRange        range = [self visiblePageRange];
    NSString    *string;
    
    if (range.length == 1) {
        string = AJRFormat(@"Page %d of %d", range.location, lastPage);
    } else {
        string = AJRFormat(@"Page %d-%d of %d", range.location, range.location + range.length - 1, lastPage);
    }
    
    [pageText setStringValue:string];
}

- (void)_setupAccessory
{
    if (!pageAccessory) {
        [NSBundle ajr_loadNibNamed:@"AJRScrollViewPageAccessory" owner:self];
        [pageText removeFromSuperview];
        [pageAccessory addSubview:pageText positioned:NSWindowAbove relativeTo:[[pageAccessory subviews] lastObject]];
    }
    
    if ([horizontalAccessoriesLeft indexOfObjectIdenticalTo:pageAccessory] == NSNotFound) {
        [self addHorizontalAccessory:pageAccessory position:AJRAccessoriesLeft];
        [[pageText cell] setRepresentedObject:[NSNumber numberWithInteger:firstPage]];
        [pageText setTarget:self];
        [pageText setAction:@selector(selectPageNumber:)];
    }

    [self _updatePageText];
}

- (void)_setupPages
{
    NSView        *documentView = [[super documentView] subview];
    NSRange        temp;
    
    //AJRPrintf(@"documentView = %@\n", documentView);
    firstPage = 0;
    lastPage = INT_MAX;
    temp.location = firstPage;
    temp.length = lastPage - firstPage;
    _pages = [documentView knowsPageRange:&temp];
    if (temp.length == INT_MAX) temp.length = 1;
    firstPage = temp.location;
    lastPage = temp.location + temp.length - 1;
    [[super documentView] tile];
    
    if ((lastPage != NSNotFound) && (lastPage - firstPage > 0)) {
        [self _setupAccessory];
    } else {
        if (pageAccessory) {
            if ([horizontalAccessoriesLeft indexOfObjectIdenticalTo:pageAccessory] == NSNotFound) {
                [self removeAccessory:pageAccessory];
            }
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)tile {
    NSScroller *horizontalScroller = [self horizontalScroller];
    NSScroller *verticalScroller = [self verticalScroller];
    NSRect horizontalRect, workRect;
    NSRect verticalRect;
    NSInteger x;
    NSView *accessory;
    
    if (!_hasSetup) {
        [self _setup];
    }
    
    [self _setupPages];
    
    [super tile];
    
    if ([self hasHorizontalRuler] && [self hasVerticalRuler]) {
        NSRulerView        *hRuler = [self horizontalRulerView];
        NSRulerView        *vRuler = [self verticalRulerView];
        float            adjust = [vRuler reservedThicknessForMarkers] + 3.0;
        
        workRect = [hRuler frame];
        workRect.origin.x -= adjust;
        workRect.size.width += adjust;
        [hRuler setFrame:workRect];
    }
    
    if (horizontalScroller) {
        
        horizontalRect = [horizontalScroller frame];
        
        if ([self rulersVisible]) {
            if ([self hasVerticalRuler]) {
                NSRulerView        *rulerView = [self verticalRulerView];
                NSRect            rvRect = [rulerView frame];
                
                rvRect.size.height -= (horizontalRect.size.height + 1.0);
                [rulerView setFrame:rvRect];
                
                horizontalRect.origin.x -= rvRect.size.width;
                horizontalRect.size.width += rvRect.size.width;
            }
            
            if ([self hasHorizontalRuler]) {
                NSRulerView        *rulerView = [self horizontalRulerView];
                NSRect            rhRect = [rulerView frame];
                NSRect            vRect = [verticalScroller frame];
                
                rhRect.origin.x += (vRect.size.width + 1.0);
                rhRect.size.width -= (vRect.size.width + 1.0);
                [rulerView setFrame:rhRect];
                
                vRect.origin.y -= rhRect.size.height;
                vRect.size.height += rhRect.size.height;
                [verticalScroller setFrame:vRect];
            }
        }
        
        for (x = 0; x < (const NSInteger)[horizontalAccessoriesRight count]; x++) {
            accessory = [horizontalAccessoriesRight objectAtIndex:x];
            workRect = [accessory frame];
            NSDivideRect(horizontalRect, &workRect, &horizontalRect, workRect.size.width, NSMaxXEdge);
            if (x == 0) workRect.origin.x += 1.0;
            workRect.origin.x -= 1.0;
            [accessory setFrame:workRect];
        }
        
        for (x = 0; x < (const NSInteger)[horizontalAccessoriesLeft count]; x++) {
            accessory = [horizontalAccessoriesLeft objectAtIndex:x];
            workRect = [accessory frame];
            NSDivideRect(horizontalRect, &workRect, &horizontalRect, workRect.size.width, NSMinXEdge);
            [accessory setFrame:workRect];
        }
        
        [horizontalScroller setFrame:horizontalRect];
    }
    
    if (verticalScroller) {
        verticalRect = [verticalScroller frame];
        if ([self hasHorizontalRuler]) {
            NSRect    rulerRect = [[self horizontalRulerView] frame];
            verticalRect.size.height -= rulerRect.size.height;
            verticalRect.origin.y += rulerRect.size.height;
        }
        for (x = [verticalAccessoriesBottom count] - 1; x >= 0; x--) {
            accessory = [verticalAccessoriesBottom objectAtIndex:x];
            workRect = [accessory frame];
            NSDivideRect(verticalRect, &workRect, &verticalRect, workRect.size.height, NSMaxYEdge);
            [accessory setFrame:workRect];
        }
        for (x = [verticalAccessoriesTop count] - 1; x >= 0; x--) {
            accessory = [verticalAccessoriesTop objectAtIndex:x];
            workRect = [accessory frame];
            NSDivideRect(verticalRect, &workRect, &verticalRect, workRect.size.height, NSMinYEdge);
            [accessory setFrame:workRect];
        }
        
        [verticalScroller setFrame:verticalRect];
    }
}

- (void)_insertPercent:(NSInteger)percent intoPopUpButton:(NSPopUpButton *)aButton
{
    NSArray        *items = [aButton itemArray];
    NSInteger    x, max;
    NSMenuItem    *item;
    
    max = [items count] - 2;
    for (x = 0; x < max; x++) {
        item = [items objectAtIndex:x];
        if ([[item title] intValue] > percent) {
            [aButton insertItemWithTitle:[NSString stringWithFormat:@"%ld%%", percent] atIndex:x];
            break;
        }
    }
    if (x == max) {
        [aButton insertItemWithTitle:[NSString stringWithFormat:@"%ld%%", percent] atIndex:x];
    }
}

- (void)setScale:(float)percent
{
    [(AJRCenteringView *)[super documentView] setScale:percent];
    [self setNeedsDisplay:YES];
    
    oldScalePercent = rint(percent * 100.0);
    [zoomButton setTitle:[NSString stringWithFormat:@"%ld%%", oldScalePercent]];
}

- (void)setZoom:(id)sender
{
    NSString        *title = [[sender selectedItem] title];
    NSInteger        size;
    float            percent;
    
    if ([title isEqualToString:@"Size to Fit"]) {
        NSRect        docRect = [[[super documentView] subview] bounds];
        NSRect        visRect = [[self contentView] documentVisibleRect];
        NSInteger    percentX = (NSInteger)floor((visRect.size.width / docRect.size.width) * 100.0);
        NSInteger    percentY = (NSInteger)floor((visRect.size.height / docRect.size.height) * 100.0);
        
        if (percentX > percentY) {
            size = percentY;
        } else {
            size = percentX;
        }
    } else if ([title isEqualToString:@"Custom..."]) {
        if ([[AJRScrollViewAccessories sharedInstance] runWithPercent:oldScalePercent] == NSModalResponseOK) {
            size = [[AJRScrollViewAccessories sharedInstance] percent];
            [self _insertPercent:size intoPopUpButton:sender];
        } else {
            size = oldScalePercent;
        }
        [(NSPopUpButton *)sender setTitle:[NSString stringWithFormat:@"%ld%%", size]];
    } else {
        size = [title intValue];
    }
    
    if (size != oldScalePercent) {
        
        percent = (float)size / 100.0;
        
        [(AJRCenteringView *)[super documentView] setScale:percent];
        
        if ([delegate respondsToSelector:@selector(scrollView:didZoomToPercent:)]) {
            [delegate scrollView:self didZoomToPercent:percent];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AJRScrollViewDidChangeZoomPercent object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:percent], AJRScrollViewPercentKey, nil]];
        
        [self setNeedsDisplay:YES];
        [[super documentView] setActivePage:[[[pageText cell] representedObject] intValue]];
        
        oldScalePercent = size;
    }
}

- (void)setDocumentView:(NSView *)aView
{
    AJRCenteringView    *center;
    
    if (!_hasAwakened) return;
    
    if ([[super documentView] subview]) {
        [[[super documentView] subview] removeObserver:self forKeyPath:@"pages"];
    }

    center = [super documentView];
    if (([center isFlipped] && [aView isFlipped]) || (![center isFlipped] && ![aView isFlipped])) {
        // In this case, we were flipped and we remain flipped, so don't do anything.
        [[super documentView] addSubview:aView];
    } else {
        // In this case, our flipped status has changed, so we need to change the type of AJRCenteringView that we are.
        if ([aView isFlipped]) {
            center = [[AJRFlippedCenteringView allocWithZone:nil] initFromPrevious:center];
        } else {
            center = [[AJRCenteringView allocWithZone:nil] initFromPrevious:center];
        }
        [super setDocumentView:center];
        [[super documentView] addSubview:aView];
    }
    [self _setupPages];
    
    if (aView) {
        [aView addObserver:self forKeyPath:@"pages" options:0 context:NULL];
    }
}

- (NSView *)documentView
{
    if (!_hasSetup) [self _setup];
    
    return [super documentView];
}

- (void)documentViewDidChangePageCount:(NSNotification *)notification
{
    [self _setupPages];
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView
{
    [super reflectScrolledClipView:aClipView];
    [self _updatePageText];
}

- (void)setPagePosition:(AJRPagePosition)pagePosition
{
    _pagePosition = pagePosition;
    [[super documentView] tile];
    [[super documentView] setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
}

- (AJRPagePosition)pagePosition
{
    return _pagePosition;
}

- (NSInteger)pageCount
{
    return (lastPage - firstPage) + 1;
}

- (NSInteger)firstPage
{
    return firstPage;
}

- (NSInteger)lastPage
{
    return lastPage;
}

- (void)selectPageNumber:(id)sender
{
    [[pageText cell] setRepresentedObject:[NSNumber numberWithInt:[sender intValue]]];
    [self setPageNumber:[sender intValue]];
}

- (void)setPageNumber:(NSInteger)aPageNumber
{
    if (aPageNumber < firstPage) aPageNumber = firstPage;
    if (aPageNumber > lastPage) aPageNumber = lastPage;
    
    [[super documentView] setActivePage:aPageNumber];

    [self _updatePageText];
}

- (NSInteger)pageNumber
{
    return [[super documentView] activePage];
}

- (IBAction)selectPagePosition:(NSMenuItem *)sender
{
    [self setPagePosition:(AJRPagePosition)[sender tag]];
    [[super documentView] setActivePage:[[[pageText cell] representedObject] intValue]];
}

- (IBAction)takePageNumberFrom:(id)sender
{
    NSInteger aPageNumber;
    
    if ([sender isKindOfClass:[NSMatrix class]]) {
        aPageNumber = [[sender selectedCell] tag];
    } else {
        aPageNumber = [sender intValue];
    }
    
    if (aPageNumber < firstPage) aPageNumber = firstPage;
    else if (aPageNumber > lastPage) aPageNumber = lastPage;
    
    if ([sender isKindOfClass:[NSMatrix class]]) {
        [sender selectCellWithTag:aPageNumber];
    } else {
        [sender setIntegerValue:aPageNumber];
    }
    
    [[super documentView] setActivePage:aPageNumber];
}

- (void)pageForward:(id)sender
{
    [self setPageNumber:[self pageNumber] + 1];
}

- (void)pageBackward:(id)sender
{
    [self setPageNumber:[self pageNumber] - 1];
}

- (void)print:(id)sender
{
    [[super documentView] print:sender];
}

static Class RulerViewClass;

+ (void)setRulerViewClass:(Class)aClass
{
    RulerViewClass = aClass;
}

+ (Class)rulerViewClass
{
    return RulerViewClass;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pages"]) {
        [self _setupPages];
    }
}

//- (void)scrollWheel:(NSEvent *)theEvent
//{
//    NSRect        visible = [[self contentView] documentVisibleRect];
//    CGFloat        scale;
//    
//    scale = pow([theEvent deltaX], 2.0);
//    if ([theEvent deltaX] < 0) scale = -scale;
//    visible.origin.x += scale;
//    
//    scale = pow([theEvent deltaY], 2.0);
//    if ([theEvent deltaY] < 0) scale = -scale;
//    visible.origin.y += scale;
//    
//    [[self contentView] scrollRectToVisible:visible];
//}

@end
