
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSGradient (AJRInterfaceExtensions)

- (void)strokeBezierPath:(NSBezierPath *)path angle:(CGFloat)angle;

@end

NS_ASSUME_NONNULL_END
