
#import <Cocoa/Cocoa.h>

@class AJRSectionViewItem;
@protocol AJRSectionViewDelegate;

@interface AJRSectionView : NSView <NSCoding>
{
    NSMutableArray *_sections;
    NSMutableArray *_sectionSnapshots;
    
    // Visual Attributes
    NSColor *_activeBackgroundColor;
    NSColor *_inactiveBackgroundColor;
    NSDictionary *_titleAttributes;
    CGFloat _titleHeight;
    NSGradient *_titleActiveBackgroundGradient;
    NSGradient *_titleInactiveBackgroundGradient;
    NSGradient *_titleHighlightBackgroundGradient;
    NSColor *_titleActiveColor;
    NSColor *_titleInactiveColor;
    
    // Animation place holders
    NSMutableArray *_viewsToInsert;
    NSMutableArray *_viewsToRemove;
    NSMutableSet *_viewsToResize;
    CGFloat _arrowProgress;
    
    // Highlights
    AJRSectionViewItem *_highlightedSection;
    
    id <AJRSectionViewDelegate> __unsafe_unretained _delegate;
    
    BOOL _suppressAnimation;
    BOOL _isTiling;
    BOOL _bordered;
    BOOL _delegateRespondsToShouldCollapse;
    BOOL _delegateRespondsToWillCollapse;
    BOOL _delegateRespondsToDidCollapse;
    BOOL _delegateRespondsToShouldExpand;
    BOOL _delegateRespondsToWillExpand;
    BOOL _delegateRespondsToDidExpand;
}

- (id)initWithFrame:(NSRect)frame;

@property (nonatomic,assign,getter=isAnimationSuppressed) BOOL suppressAnimation;
@property (nonatomic,unsafe_unretained) IBOutlet id<AJRSectionViewDelegate> delegate;

@property (nonatomic,strong) NSColor *activeBackgroundColor;
@property (nonatomic,strong) NSColor *inactiveBackgroundColor;

@property (nonatomic,strong) NSDictionary *titleAttributes;
@property (nonatomic,assign) CGFloat titleHeight;
@property (nonatomic,strong) NSGradient *titleActiveBackgroundGradient;
@property (nonatomic,strong) NSGradient *titleInactiveBackgroundGradient;
@property (nonatomic,strong) NSGradient *titleHighlightBackgroundGradient;
@property (nonatomic,strong) NSColor *titleActiveColor;
@property (nonatomic,strong) NSColor *titleInactiveColor;

@property (nonatomic,assign,getter=isBordered) BOOL bordered;

/*!
 @methodgroup Managing Animation
 */
- (void)suppressAnimation;
- (void)enableAnimation;

/*!
 @methodgroup Managing View Layout
 */
- (void)prepareToTile;
- (void)tile;

/*!
 @methodgroup Managing the View Heirarchy
 */
- (void)addSubview:(NSView *)subview expanded:(BOOL)expanded;
- (void)addSubview:(NSView *)subview withTitle:(NSString *)title expanded:(BOOL)expanded;
- (void)addSubview:(NSView *)aView positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView;
- (void)addSubview:(NSView *)aView positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView expanded:(BOOL)expanded;
- (void)addSubview:(NSView *)aView withTitle:(NSString *)title positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView expanded:(BOOL)expanded;

/*!
 @methodgroup Managing Sections
 */
- (AJRSectionViewItem *)sectionForPoint:(NSPoint)point;
- (AJRSectionViewItem *)sectionForView:(NSView *)view;
- (NSUInteger)indexOfSection:(AJRSectionViewItem *)section;
- (BOOL)isSectionHighlighted:(AJRSectionViewItem *)section;

/*!
 @methodgroup Managing Section Size
 */
- (BOOL)isViewExpanded:(NSView *)view;
- (void)expandView:(NSView *)view;
- (void)collapseView:(NSView *)view;
- (void)setHeight:(CGFloat)height ofView:(NSView *)view;

/*!
 @methodgroup Drawing
 */
- (void)drawSectionTitle:(AJRSectionViewItem *)section inRect:(NSRect)rect;

@end


@protocol AJRSectionViewDelegate <NSObject>

@optional
- (void)sectionView:(AJRSectionView *)sectionView willResizeTo:(NSSize)size byAnimating:(BOOL)animating;
- (BOOL)sectionView:(AJRSectionView *)sectionView shouldCollapseView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView willCollapseView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView didCollapseView:(NSView *)view;
- (BOOL)sectionView:(AJRSectionView *)sectionView shouldExpandView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView willExpandView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView didExpandView:(NSView *)view;

@end
