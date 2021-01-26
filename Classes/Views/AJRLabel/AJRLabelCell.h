
#import <AppKit/AppKit.h>

typedef enum _ajrTextStyle {
    AJRTextNormal            = 0,
    AJRTextOutline            = 1,
    AJRTextShadow            = 2,
    AJRTextBezeledIn            = 3,
    AJRTextBezeledOut        = 4,
    AJRTextGroove            = 5,
    AJRTextBezeledInClean    = 6,
    AJRTextBezeledOutClean    = 7
} AJRTextStyle;

typedef enum _ajrFades {
    AJRFadeSolid            = 0,
    AJRFadeTopToBottom    = 1,
    AJRFadeBottomToTop    = 2,
    AJRFadeLeftToRight    = 3,
    AJRFadeRightToLeft    = 4
} AJRFades;

typedef enum _ajrBorderType {
    AJRNoBorder            = 0,
    AJRLineBorderDep        = 1,
    AJRBezelBorder        = 2,
    _AJRGrooveBorder        = 3,
    AJRButtonBorder        = 4
} AJRBorderType;

@class AJRPathRenderer;

@interface AJRLabelCell : NSTextFieldCell
{
    NSMutableArray    *renderers;
    NSBezierPath    *path;
}

- (id)init;
- (id)initTextCell:(NSString *)string;
- (id)initImageCell:(NSImage *)icon;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)aView;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView;
- (NSSize)cellSize;
- (NSSize)cellSizeForBounds:(NSRect)rect;

- (NSArray *)renderers;
- (NSUInteger)renderersCount;
- (AJRPathRenderer *)rendererAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfRenderer:(AJRPathRenderer *)renderer;
- (AJRPathRenderer *)lastRenderer;
- (void)addRenderer:(AJRPathRenderer *)renderer;
- (void)insertRenderer:(AJRPathRenderer *)renderer atIndex:(NSUInteger)index;
- (void)removeRendererAtIndex:(NSUInteger)index;
- (void)removeRenderersAtIndexes:(NSIndexSet *)indexes;
- (void)moveRendererAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

