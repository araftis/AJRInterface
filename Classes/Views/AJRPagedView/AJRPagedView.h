
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger AJRPageIndexMasterSingle;
extern const NSInteger AJRPageIndexMasterEven;
extern const NSInteger AJRPageIndexMasterOdd;
extern const NSInteger AJRPageIndexFirst;

typedef NS_ENUM(uint8_t, AJRMasterPageDisplay) {
    AJRMasterPageDisplayNone,
    AJRMasterPageDisplaySingle,
    AJRMasterPageDisplayDouble
};

@class AJRBorder, AJRPageLayout, AJRPagedView;

@protocol AJRPagedViewDataSource <NSObject>

@required - (NSUInteger)pageCountForPagedView:(AJRPagedView *)pagedView;
@required - (NSView *)pagedView:(AJRPagedView *)pagedView viewForPage:(NSInteger)pageNumber;
@required - (NSSize)pagedView:(AJRPagedView *)pagedView sizeForPage:(NSInteger)pageNumber;
@optional - (NSColor *)pagedView:(AJRPagedView *)pagedView colorForPage:(NSInteger)pageNumber;

@end

@protocol AJRPagedViewDelegate <NSObject>

@optional - (BOOL)pagedView:(AJRPagedView *)pagedView shouldSwitchToLayout:(AJRPageLayout *)layout;
@optional - (void)pagedView:(AJRPagedView *)pagedView willSwitchToLayout:(AJRPageLayout *)layout;
@optional - (void)pagedView:(AJRPagedView *)pagedView didSwitchToLayout:(AJRPageLayout *)layout;
@optional - (BOOL)pagedView:(AJRPagedView *)pagedView isLayoutValid:(AJRPageLayout *)layout;

@optional - (void)pagedView:(AJRPagedView *)pagedView willScaleTo:(CGFloat)scale;
@optional - (void)pagedView:(AJRPagedView *)pagedView didScaleTo:(CGFloat)scale;

@end

@interface AJRPagedView : NSView

@property (nonatomic,weak) IBOutlet id <AJRPagedViewDelegate> delegate;
@property (nonatomic,strong) IBOutlet id <AJRPagedViewDataSource> pageDataSource;

@property (nonatomic,assign) CGFloat verticalGap;
@property (nonatomic,assign) CGFloat horizontalGap;

@property (nullable,nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) AJRBorder *pageBorder;
@property (nonatomic,assign) CGFloat scale;

@property (nonatomic,strong) AJRPageLayout *pageLayout;
@property (nonatomic,strong) NSString *pageLayoutIdentifier;

@property (nonatomic,assign) AJRMasterPageDisplay masterPageDisplay;

@property (weak, nonatomic,readonly) NSIndexSet *visiblePageIndexes;
@property (weak, nonatomic,readonly) NSString *visiblePageString;

#pragma mark - Page Data Source

- (void)reloadPages;

#pragma mark - Scrolling

- (void)scrollPageToVisible:(NSInteger)pageIndex;
- (void)scrollPagesToVisible:(NSIndexSet *)pageIndex;

@end

NS_ASSUME_NONNULL_END
