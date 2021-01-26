
#import <AppKit/AppKit.h>

#import <AJRInterface/AJRScrollView.h>

@interface NSView (AJRCenterViewAdditions)

- (NSView *)viewForPage;
- (NSView *)viewForPage:(NSInteger)pageNumber;

@end


@interface AJRCenteringView : NSView
{
    NSClipView            *clipView;
    NSView                *subview;
    
    NSRect                contentRect;
    
    NSInteger            firstPage, lastPage;
    AJRPagePosition        pagePosition;
    NSInteger            activePage;
    NSRect                *_frameCache;
    
    NSSize                _savedSubviewSize;
    
    NSInteger            printingPageNumber;        // Only used during printing
    
    struct _ncvFlags {
        BOOL            _documentRespondsToViewForPage:1;
        BOOL            _isPrinting:1;
        NSUInteger        _reserved:30;
    } ncvFlags;
}

// Used to create a new centering view based off an old one. This copies some of the more important shared inforamtion.
- (id)initFromPrevious:(AJRCenteringView *)otherView;

- (NSView *)subview;
- (NSView *)documentView;
- (NSView *)viewForPage:(NSInteger)pageNumber;

@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSShadow *pageShadow;
@property (nonatomic,strong) NSColor *pageColor;
@property (nonatomic,assign) CGFloat scale;
@property (nonatomic,assign) CGFloat gutter;

- (void)tile;

- (NSSize)sizeOfContentRect;
- (NSRect)pageRectangleForPage:(NSInteger)pageNumber;

- (void)setActivePage:(NSInteger)aPage;
- (NSInteger)activePage;

- (NSInteger)pageForEvent:(NSEvent *)anEvent;
- (NSInteger)pageForPoint:(NSPoint)aPoint;
- (NSRange)pageRangeForRect:(NSRect)rect;

- (void)printRect:(NSRect)rect;

@end
