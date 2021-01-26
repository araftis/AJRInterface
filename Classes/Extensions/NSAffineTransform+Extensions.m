
#import "NSAffineTransform+Extensions.h"

#import <AJRInterfaceFoundation/AJRTrigonometry.h>

@implementation NSAffineTransform (AJRInterfaceExtensions)

+ (NSAffineTransform *)currentTransform {
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    NSAffineTransform *transform = [NSAffineTransform transform];
    NSAffineTransformStruct transformStruct;
    CGAffineTransform cgTransform;
    
    cgTransform = CGContextGetCTM(context);
    transformStruct.m11 = cgTransform.a;
    transformStruct.m12 = cgTransform.b;
    transformStruct.m21 = cgTransform.c;
    transformStruct.m22 = cgTransform.d;
    transformStruct.tX = cgTransform.tx;
    transformStruct.tY = cgTransform.ty;
    
    return transform;
}

+ (void)scaleBy:(CGFloat)scale {
   CGContextScaleCTM([[NSGraphicsContext currentContext] CGContext], scale, scale);
}

+ (void)scaleXBy:(CGFloat)deltaX yBy:(CGFloat)deltaY {
   CGContextScaleCTM([[NSGraphicsContext currentContext] CGContext], deltaX, deltaY);
}

+ (void)translateXBy:(CGFloat)deltaX yBy:(CGFloat)deltaY {
   CGContextTranslateCTM([[NSGraphicsContext currentContext] CGContext], deltaX, deltaY);
}

+ (void)rotateByDegrees:(CGFloat)angle {
   [self rotateByRadians:AJRDegreesToRadians(angle)];
}

+ (void)rotateByRadians:(CGFloat)angle {
   CGContextRotateCTM([[NSGraphicsContext currentContext] CGContext], angle);
}

+ (CGFloat)currentScale {
   CGAffineTransform aTransform = CGContextGetCTM([[NSGraphicsContext currentContext] CGContext]);
   return aTransform.a;
}

+ (void)getCurrentXScale:(CGFloat *)xScale yScale:(CGFloat *)yScale {
   CGAffineTransform aTransform = CGContextGetCTM([[NSGraphicsContext currentContext] CGContext]);

   if (xScale) *xScale = aTransform.a;
   if (yScale) *yScale = aTransform.d;
}

+ (void)flipCoordinateSystemInRect:(NSRect)frame {
	[NSAffineTransform translateXBy:frame.origin.x yBy:frame.origin.y];
	[NSAffineTransform scaleXBy:1.0 yBy:-1.0];
	[NSAffineTransform translateXBy:0.0 yBy:-frame.size.height];
}

@end
