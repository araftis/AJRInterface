
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRCIEXYZColorSpace;

extern void AJRRGBToHSB(CGFloat red, CGFloat green, CGFloat blue, CGFloat *hue, CGFloat *saturation, CGFloat *brightness);

@interface NSColor (AJRCIEColor)

+ (NSColor *)colorWithCIEX:(CGFloat)xIn y:(CGFloat)yIn z:(CGFloat)zIn alpha:(CGFloat)alphaIn;

@end


@interface AJRCIEColor : NSColor

+ (NSColor *)colorWithCIEX:(CGFloat)xIn y:(CGFloat)yIn z:(CGFloat)zIn alpha:(CGFloat)alphaIn;
- (id)initWithCIEX:(CGFloat)xIn y:(CGFloat)yIn z:(CGFloat)zIn alpha:(CGFloat)alphaIn;

@end

NS_ASSUME_NONNULL_END
