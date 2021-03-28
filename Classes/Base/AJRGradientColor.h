
#import <AppKit/AppKit.h>

@interface AJRGradientColor : NSObject

+ (id)gradientColorWithColor:(NSColor *)color;
+ (id)gradientColorWithGradient:(NSGradient *)gradient angle:(CGFloat)angle;
+ (id)gradientColorWithGradient:(NSGradient *)gradient relativeCenterPosition:(NSPoint)relativeCenterPosition;

- (id)initWithColor:(NSColor *)color;
- (id)initWithGradient:(NSGradient *)gradient angle:(CGFloat)angle;
- (id)initWithGradient:(NSGradient *)gradient relativeCenterPosition:(NSPoint)relativeCenterPosition;

@property (strong,readonly) NSColor *color;
@property (strong,readonly) NSGradient *gradient;
@property (readonly) CGFloat angle;
@property (readonly) NSPoint relativeCenterPosition;

- (void)drawBezierPath:(NSBezierPath *)path;
- (void)drawInBezierPath:(NSBezierPath *)path;
- (void)drawInRect:(NSRect)rect;

@end
