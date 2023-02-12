/*
 NSAffineTransform+Extensions.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
