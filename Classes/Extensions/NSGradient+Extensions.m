/*
 NSGradient+Extensions.m
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

#import "NSGradient+Extensions.h"

#import "NSBezierPath+Extensions.h"

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

@implementation NSGradient (AJRInterfaceExtensions)

#pragma mark - Utilities

- (void)getStartingPoint:(CGPoint *)startingPoint andEndingPoint:(CGPoint *)endingPoint forRect:(CGRect)rect andAngle:(CGFloat)angleIn {
	CGFloat angle = remainder(angleIn, 360.0);
	CGFloat radians = angle * (M_PI / 180.0);
	CGFloat a, b; // a = opposite, b = adjacent
	
	a = rect.size.height / 2.0;
	b = a / tan(radians);
	
	if (fabs(b) > rect.size.width / 2.0) {
		b = copysign(rect.size.width / 2.0, b);
		a = b * tan(radians);
	}
	
	// This block helps with the fact that tangent is opposite over adjacent. That means we're dividing positives and negatives, which only gives us a range of 180°. Thus, when we have a "negative" angle, caused by the call remainder() above, we can effectively invert the results by swapping the signs of a and b.
	if (angle >= 0.0 && angle < 180.0) {
		startingPoint->x = rect.origin.x + rect.size.width / 2.0 - b;
		startingPoint->y = rect.origin.y + rect.size.height / 2.0 - a;
		endingPoint->x = rect.origin.x + rect.size.width / 2.0 + b;
		endingPoint->y = rect.origin.y + rect.size.height / 2.0 + a;
	} else {
		startingPoint->x = rect.origin.x + rect.size.width / 2.0 + b;
		startingPoint->y = rect.origin.y + rect.size.height / 2.0 + a;
		endingPoint->x = rect.origin.x + rect.size.width / 2.0 - b;
		endingPoint->y = rect.origin.y + rect.size.height / 2.0 - a;
	}
	
	//    NSLog(@"width: %.0f, height: %.0f, a: %.1f, b: %.1f, start: {%.1f, %.1f}, end: {%.1f, %.1f}, angle: %.1f", rect.size.width, rect.size.height, a, b, startingPoint->x, startingPoint->y, endingPoint->x, endingPoint->y, angle);
}

- (void)getCenter:(CGPoint *)center andRadius:(CGFloat *)radius forRect:(CGRect)rect andRelativeCenter:(CGPoint)relativeCenter
{
	CGFloat     midX = rect.size.width / 2.0;
	CGFloat     midY = rect.size.height / 2.0;
	CGFloat     maxX;
	CGFloat     maxY;
	
	center->x = rect.origin.x + (midX + midX * relativeCenter.x) / 2.0;
	center->y = rect.origin.y + (midY + midY * relativeCenter.y) / 2.0;
	
	if (center->x - rect.origin.x > midX) {
		maxX = center->x - rect.origin.x;
	} else {
		maxX = rect.origin.x + rect.size.width - center->x;
	}
	if (center->y - rect.origin.y > midY) {
		maxY = center->y - rect.origin.y;
	} else {
		maxY = rect.origin.y + rect.size.height - center->y;
	}
	
	*radius = sqrt(maxX * maxX + maxY * maxY);
}

#pragma mark - Drawing

- (void)strokeBezierPath:(NSBezierPath *)path angle:(CGFloat)angle {
	CGPoint startingPoint, endingPoint;
	CGContextRef context = AJRGetCurrentContext();
	
	[self getStartingPoint:&startingPoint andEndingPoint:&endingPoint forRect:[path controlPointBounds] andAngle:angle];
	
	CGContextSaveGState(context);
	[[path bezierPathFromStrokedPath] addClip];
	[self drawFromPoint:startingPoint toPoint:endingPoint options:kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation];
	CGContextRestoreGState(context);
}


@end
