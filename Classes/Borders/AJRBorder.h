
#import <AppKit/AppKit.h>

#import <AJRInterfaceFoundation/AJRInset.h>

@class AJRBorderInspector;

extern NSString *AJRBorderWillUpdateNotification;
extern NSString *AJRBorderDidUpdateNotification;

typedef enum _ajrBorderTabMask {
    AJRBorderTabsNone = 0,
    AJRBorderTabsOnTop = 1,
    AJRBorderTabsOnBottom = 2,
    AJRBorderTabsOnLeft = 4,
    AJRBorderTabsOnRight = 8,
    AJRBorderTabsAll = AJRBorderTabsOnTop | AJRBorderTabsOnBottom | AJRBorderTabsOnLeft | AJRBorderTabsOnRight
} AJRBorderTabMask;

@interface AJRBorder : NSObject <NSCoding>
{
    NSArray                *tabs;
    NSSize                *tabSizes;
    NSInteger            selectedTab;
    NSTextFieldCell        *titleCell;

    NSTitlePosition        titlePosition;
    NSTextAlignment        titleAlignment;
    NSTabViewType        tabType:3;
    BOOL                tabsCanTruncate:1;
}

+ (void)registerBorder:(Class)aClass;

+ (NSArray *)borderTypes;
+ (NSArray *)borderNames;
+ (AJRBorder *)borderForType:(NSString *)type;
+ (AJRBorder *)borderForName:(NSString *)type;

+ (NSString *)name;

#pragma mark - Title

@property (nonatomic,strong) NSTextFieldCell *titleCell;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSTitlePosition titlePosition;
@property (nonatomic,assign) NSTextAlignment titleAlignment;

- (NSSize)titleSize;
- (NSRect)titleRectForRect:(NSRect)rect;

- (void)setTabs:(NSArray *)tabs;
- (NSArray *)tabs;
- (void)setTabsCanTruncate:(BOOL)flag;
- (BOOL)tabsCanTruncate;
- (void)setSelectedTabIndex:(NSUInteger)index;
- (void)setTabViewType:(NSTabViewType)aType;
- (NSTabViewType)tabViewType;
- (AJRBorderTabMask)availableTabEdges;

- (void)willUpdate;
- (void)didUpdate;

- (BOOL)isOpaque;
- (NSRect)contentRectForRect:(NSRect)rect;
- (NSRect)unclippedContentRectForRect:(NSRect)rect;
- (NSRect)rectForContentRect:(NSRect)rect;
- (NSBezierPath *)clippingPathForRect:(NSRect)rect;
- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView;
- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView;
- (void)drawBorderInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView;
- (void)drawBorderInRect:(NSRect)rect controlView:(NSView *)controlView;

- (NSSize)sizeForTab:(NSUInteger)index;
- (CGFloat)marginBetweenTabs:(NSInteger)index1 and:(NSInteger)index2;
- (NSRect)rectForTab:(NSUInteger)index inRect:(NSRect)bounds;
- (void)drawTabTextInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect;
- (NSUInteger)tabForPoint:(NSPoint)point inRect:(NSRect)rect;

- (AJRInset)shadowInset;

- (BOOL)isControlViewActive:(NSView *)controlView;
- (BOOL)isControlViewFocused:(NSView *)controlView;

@end
