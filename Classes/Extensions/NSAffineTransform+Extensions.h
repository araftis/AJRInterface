
#import <Cocoa/Cocoa.h>

@interface NSAffineTransform (AJRInterfaceExtensions)

+ (id)currentTransform;

+ (void)scaleBy:(CGFloat)scale;
+ (void)scaleXBy:(CGFloat)deltaX yBy:(CGFloat)deltaY;
+ (void)translateXBy:(CGFloat)deltaX yBy:(CGFloat)deltaY;
+ (void)rotateByDegrees:(CGFloat)angle;
+ (void)rotateByRadians:(CGFloat)angle;
+ (CGFloat)currentScale;
+ (void)getCurrentXScale:(CGFloat *)xScale yScale:(CGFloat *)yScale;

+ (void)flipCoordinateSystemInRect:(NSRect)frame;

@end
