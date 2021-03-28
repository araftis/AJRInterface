
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRSegmentedCell : NSSegmentedCell

@property (nonatomic,assign) IBInspectable CGFloat cornerRadius;

- (NSRect)rectForSegment:(NSInteger)index inFrame:(NSRect)frame;
- (NSRect)titleRectForBounds:(NSRect)bounds;

@end

NS_ASSUME_NONNULL_END
