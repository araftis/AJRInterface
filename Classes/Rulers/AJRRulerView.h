
#import <AppKit/AppKit.h>

@interface AJRRulerView : NSRulerView

@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSColor *rulerBackgroundColor;
@property (nonatomic,strong) NSColor *rulerMarginBackgroundColor;
@property (nonatomic,strong) NSColor *tickColor;
@property (nonatomic,strong) NSColor *unitColor;

- (NSString *)rulerUnitAbbreviation;
- (CGFloat)rulerUnitConversionFactor;

@end

@protocol AJRRulerViewClient <NSObject>

@optional - (NSArray<NSView *> *)horizontalViews;
@optional - (NSArray<NSView *> *)verticalViews;

@optional - (NSArray<NSValue *> *)horizontalMarginRanges;
@optional - (NSArray<NSValue *> *)verticalMarginRanges;
@optional - (void)rulerViewDidSetClientView:(NSRulerView *)rulerView;

@end
