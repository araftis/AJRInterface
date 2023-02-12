/*
 AJRSpeechBorder.m
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

#import "AJRSpeechBorder.h"

#import <AJRFoundation/AJRFunctions.h>

@implementation AJRSpeechBorder

+ (void)load
{
    [AJRBorder registerBorder:self];
}

#pragma mark Initialization

- (id)init
{
    if ((self = [super init])) {
        _color = [NSColor colorWithCalibratedRed:204.0 / 255.0 green:170.0 / 255.0 blue:232.0 / 255.0 alpha:1.0];
        
        _noShadow = [[NSShadow alloc] init];
        
        _baseShadow = [[NSShadow alloc] init];
        [_baseShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
        [_baseShadow setShadowBlurRadius:6.887755];
        [_baseShadow setShadowOffset:(NSSize){0.0, -4.336735}];

        _edgeShadow = [[NSShadow alloc] init];
        [_edgeShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
        [_edgeShadow setShadowBlurRadius:0.0];
        [_edgeShadow setShadowOffset:(NSSize){0.0, -1.0}];
        
        _shineGradient = [[NSGradient alloc] initWithColorsAndLocations:
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.85], 0.0,
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.25], 182.0 / 382.0,
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.00], 303.0 / 382.0,
                          nil];
        
        _darkShadow = [[NSShadow alloc] init];
        [_darkShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
        [_darkShadow setShadowBlurRadius:13.520408];
        [_darkShadow setShadowOffset:(NSSize){0.0, -4.846939}];
        
        _highlightShadow = [[NSShadow alloc] init];
        [_highlightShadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.333]];
        [_highlightShadow setShadowBlurRadius:13.520408];
        [_highlightShadow setShadowOffset:(NSSize){0.0, 11.989796}];
    }
    return self;
}


@synthesize color = _color;
@synthesize speechOrigin = _speechOrigin;

#pragma mark AJRBorder

+ (NSString *)name
{
    return @"Speech Bubble";
}

// Even though the border itself is opaque, it's non-opaque around the edges, so we return NO.
- (BOOL)isOpaque
{
    return NO;
}

// Returns our clipping path. This is basically the portion that defines the "interior" section of
// of the border.
- (NSBezierPath *)clippingPathForRect:(NSRect)rect
{
    if (_path == nil || !NSEqualRects(rect, _previousRect)) {
        const CGFloat    left = rect.origin.x + 5.0;        //   5.77
        const CGFloat    right = rect.origin.x + rect.size.width - 10.0;  // 278.27
        const CGFloat    top = rect.origin.y + 1.0;        //   3.36
        const CGFloat    bottom = rect.origin.y + rect.size.height - 5.0;    //  52.61
        
        
        // _path is the main outline of the speech bubble.
        _path = [[NSBezierPath alloc] init];
        [_path moveToPoint: NSMakePoint(right - 10.00, bottom)];
        [_path curveToPoint:NSMakePoint(right -  3.50, bottom -  2.43)
              controlPoint1:NSMakePoint(right -  8.36, bottom -  0.22)
              controlPoint2:NSMakePoint(right -  4.96, bottom -  0.95)];
        [_path curveToPoint:NSMakePoint(right +  6.00, bottom -  2.23)
              controlPoint1:NSMakePoint(right +  0.42, bottom -  0.43)
              controlPoint2:NSMakePoint(right +  5.00, bottom -  1.26)];
        [_path curveToPoint:NSMakePoint(right        , bottom - 10.39)
              controlPoint1:NSMakePoint(right +  0.38, bottom -  3.66)
              controlPoint2:NSMakePoint(right -  0.36, bottom -  7.47)];
        [_path lineToPoint: NSMakePoint(right        , top    + 10.36)];
        [_path curveToPoint:NSMakePoint(right - 10.00, top)
              controlPoint1:NSMakePoint(right        , top    +  4.84)
              controlPoint2:NSMakePoint(right -  4.48, top)];
        [_path lineToPoint: NSMakePoint(left  + 10.75, top)];
        [_path curveToPoint:NSMakePoint(left         , top    + 10.36)
              controlPoint1:NSMakePoint(left  +  5.25, top)
              controlPoint2:NSMakePoint(left         , top    +  4.84)];
        [_path lineToPoint: NSMakePoint(left         , bottom - 10.39)];
        [_path curveToPoint:NSMakePoint(left  + 10.75, bottom)
              controlPoint1:NSMakePoint(left         , bottom -  4.86)
              controlPoint2:NSMakePoint(left  +  5.25, bottom)];
        [_path lineToPoint: NSMakePoint(right - 10.00, bottom)];
        [_path closePath];
        
        // This is the "shine" highlight see in the top portion of the speech bubble.
        _shinePath = [[NSBezierPath alloc] init];
        [_shinePath appendBezierPathWithRoundedRect:(NSRect){{left + 5.0, top + 1.0}, {(right - left) - 10.0, 20.0}} xRadius:7.5 yRadius:7.5];
        [_shinePath closePath];
        
        _previousRect = rect;
    }
    
    return _path;
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    NSBezierPath        *innerPath;
    NSAffineTransform    *transform = nil;
    
    // Fault our path...
    [self clippingPathForRect:rect];
    
    // Flip when necessary
    if (![controlView isFlipped]) {
        if (transform == nil) {
            transform = [[NSAffineTransform alloc] init];
        }
        [transform translateXBy:0.0 yBy:rect.origin.y];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform translateXBy:0.0 yBy:-rect.origin.y - rect.size.height];
    }
    // We just flip horizontally if our bubble is oriented to the left. This is easier than maintaining
    // two separate paths.
    if (_speechOrigin == AJRSpeechOriginLeft) {
        if (transform == nil) {
            transform = [[NSAffineTransform alloc] init];
        }
        [transform translateXBy:rect.origin.x yBy:0.0];
        [transform scaleXBy:-1.0 yBy:1.0];
        [transform translateXBy:-rect.origin.x - rect.size.width yBy:0.0];
    }
    
    // If transform is non-nil, then we created a transform, so we need to save the graphics state
    // and appy the transform.
    if (transform) {
        [NSGraphicsContext saveGraphicsState];
        [transform concat];
    }
    
    // Now we can start to draw it.
    [_color set];        // First, draw the base color.
    [_baseShadow set];    // With the primary shadow.
    [_path fill];        // And fill.
    [_edgeShadow set];    // Then, we set the "shallow" shadow that creates a dark edge along the bottom.
    [_path fill];        // And fill again.

    [_noShadow set];    // Clear the shadow.
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
    [_path stroke];        // And lightly stroke the edge. This helps the bubble standout from the
                        // background.
    
    // Create and draw our inner highlight path. This path the our speech bubble, subtracted out 
    // from a large rectangle. This allows us to draw everything around the bubble, which, if we
    /// set the clipping path to the bubble, allows us to draw interior shadows.
    innerPath = [[NSBezierPath alloc] init];
    // Make sure to use this winding rule, since we don't know the directions of our subpaths.
    [innerPath setWindingRule:NSWindingRuleEvenOdd];
    [innerPath appendBezierPathWithRect:NSInsetRect(rect, -25.0, -25.0)];
    [innerPath appendBezierPath:_path];

    // Save the graphics state.
    [NSGraphicsContext saveGraphicsState];
    // Make the speech bubble the current clipping path.
    [_path addClip];
    // Set a neutral color. We must have some color, or the shadow won't draw. We choose a neutral,
    // because we'll get a little bleed when we draw.
    [[NSColor grayColor] set];
    // Set the dark shadow, which is the upper, inside portion of the bubble.
    [_darkShadow set];
    // And fill the path we constructed above.
    [innerPath fill];
    // Now set the highlight shadow. This is the light colored shadow along the inner edge of the
    // bubble.
    [_highlightShadow set];
    // And fill.
    [innerPath fill];
    // Finally, we're done drawing while clipping, so restore the graphics state.
    [NSGraphicsContext restoreGraphicsState];
    
    // Done with our inner path, so release
    
    // Clear the shadow.
    [_noShadow set];
    if ([NSGraphicsContext currentContextDrawingToScreen]) {
        // And finally have the _shine gradient draw shine path.
        [_shineGradient drawInBezierPath:_shinePath angle:90.0];
    } else {
        // This stupid hack is because gradients don't draw properly when outputting to a printer.
        NSRect    bounds = [_shinePath bounds];
        CGFloat    y;
        
        [NSGraphicsContext saveGraphicsState];
        [_shinePath addClip];
        for (y = bounds.origin.y; y < bounds.origin.y + bounds.size.height; y += 1.0) {
            CGFloat    where = (y - bounds.origin.y) / bounds.size.height;
            [[_shineGradient interpolatedColorAtLocation:where] set];
            [NSBezierPath strokeLineFromPoint:(NSPoint){bounds.origin.x, y} toPoint:(NSPoint){bounds.origin.x + bounds.size.width, y}];
        }
        [NSGraphicsContext restoreGraphicsState];
    }
    
    // And if we transformed above, restore the graphics state.
    if (transform) {
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    NSRect        contentRect = rect;
    
    if (_speechOrigin == AJRSpeechOriginLeft) {
        contentRect.origin.x += 15.0;
    } else {
        contentRect.origin.x += 10.0;
    }
    contentRect.size.width -= 25.0;
    contentRect.origin.y += 9.0;
    contentRect.size.height -= 29.0;
    
    return contentRect;
}

@end
