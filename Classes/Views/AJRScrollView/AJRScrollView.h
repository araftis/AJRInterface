#ifndef __AJR_SCROLL_VIEW_H__
#define __AJR_SCROLL_VIEW_H__

/*
 * Any View that responds to these messages can be a "ruler".
 * This is a nice way to make an object which works in concert
 * with another object, but isn't hardwired into the implementation
 * of that object and, instead, publishes a minimal interface
 * which it expects another object to respond to.
 */

#import <AppKit/AppKit.h>

extern NSString *AJRScrollViewDidChangeZoomPercent;
extern NSString *AJRScrollViewPercentKey;
extern NSString *AJRViewDidChangePageCount API_DEPRECATED("Use KVO on \"pages\" property instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

typedef enum {
    AJRPagesVertical,
    AJRPagesHorizontal,
    AJRPagesTwoUpOddRight,
    AJRPagesTwoUpOddLeft,
    AJRPagesSingle
} AJRPagePosition;

typedef enum {
    AJRAccessoriesLeft,
    AJRAccessoriesRight,
    AJRAccessoriesTop,
    AJRAccessoriesBottom
} AJRAccessoryPosition;

@protocol AJRScrollViewPageProvider <NSObject>

@required - (BOOL)knowsPageRange:(NSRangePointer)aRange;
@required - (NSRect)rectForPage:(NSInteger)pageNumber;

@end

@interface AJRScrollView : NSScrollView
{
    NSMutableArray            *horizontalAccessoriesLeft;
    NSMutableArray            *horizontalAccessoriesRight;
    NSMutableArray            *verticalAccessoriesTop;
    NSMutableArray            *verticalAccessoriesBottom;
    
    id                        delegate;
    
    NSInteger                firstPage, lastPage;
    
    NSInteger                oldScalePercent;
    
    IBOutlet NSTextField    *pageText;
    IBOutlet NSView            *pageAccessory;
    NSPopUpButton            *zoomButton;
    
    BOOL                    showsZoom:1;
    BOOL                    _hasSetup:1;
    BOOL                    _pages:1;
    unsigned                _pagePosition:3;
    BOOL                    _hasAwakened:1;
    unsigned                _reserved:25;
}

- (void)updateRulers:(const NSRect *)rect;

- (void)addHorizontalAccessory:(NSView *)anAccessory position:(AJRAccessoryPosition)aPosition;
- (void)addVerticalAccessory:(NSView *)anAccessory position:(AJRAccessoryPosition)aPosition;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setPagePosition:(AJRPagePosition)pagePosition;
- (AJRPagePosition)pagePosition;
- (NSInteger)pageCount;
- (NSInteger)firstPage;
- (NSInteger)lastPage;

- (void)setPageNumber:(NSInteger)aPageNumber;
- (NSInteger)pageNumber;

- (IBAction)takePageNumberFrom:(id)sender;
- (IBAction)pageForward:(id)sender;
- (IBAction)pageBackward:(id)sender;

- (void)setScale:(float)percent;

@end

@protocol NSScrollViewDelegate

- (void)scrollView:(NSScrollView *)aScrollView didZoomToPercent:(float)aPercent;

@end

#endif //__AJR_SCROLL_VIEW_H__
