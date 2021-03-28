
#import <Cocoa/Cocoa.h>

@class AJRExpansionViewItem;

@interface AJRExpansionView : NSCollectionView 

//@property (nonatomic,retain) AJRExpansionViewItem *itemPrototype;
//@property (nonatomic,retain) NSArray *content;
@property (nonatomic,assign) CGFloat headerHeight;
@property (nonatomic,strong) NSFont *font;
@property (nonatomic,strong) NSGradient *highlightFocusedGradient;
@property (nonatomic,strong) NSGradient *highlightGradient;
@property (nonatomic,strong) NSString *titleBindingKey;

/*
 * Expanding and contracting sections
 */
- (IBAction)expandAll:(id)sender;
- (IBAction)contractAll:(id)sender;
- (BOOL)isSectionExpanded:(NSUInteger)index;
- (void)setSection:(NSUInteger)index expanded:(BOOL)flag;

/*
 * Accessing items
 */
- (void)createExpansionViewItems;
- (AJRExpansionViewItem *)itemForSection:(NSInteger)section;
- (NSInteger)sectionForItem:(AJRExpansionViewItem *)item;

/*
 * Supporting layout
 */
- (void)tileWithAnimation:(BOOL)animate;
- (NSRect)frameForSection:(NSUInteger)section;
- (NSRect)headerFrameForSection:(NSUInteger)section;

@end
