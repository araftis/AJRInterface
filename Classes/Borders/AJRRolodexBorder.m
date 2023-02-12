/*
 AJRRolodexBorder.m
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

#import "AJRRolodexBorder.h"

@implementation AJRRolodexBorder

static NSColor *colors[13];

+ (void)load
{
    [AJRBorder registerBorder:self];
}

+ (void)initialize
{
    colors[ 0] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0050];
    colors[ 1] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0050];
    colors[ 2] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0060];
    colors[ 3] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0175];
    colors[ 4] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0210];
    colors[ 5] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0250];
    colors[ 6] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0400];
    colors[ 7] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0500];
    colors[ 8] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0550];
    colors[ 9] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0650];
    colors[10] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.0750];
    colors[11] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.1375];
    colors[12] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.1375];
}

+ (NSString *)name
{
    return @"Rolodex";
}

- (BOOL)isOpaque
{
    return NO;
}

- (AJRBorderTabMask)availableTabEdges
{
    return AJRBorderTabsOnTop;
}

- (AJRInset)shadowInset
{
    return (AJRInset){10.0, 7.0, 10.0, 13.0};
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    NSSize    size;
    
    rect = [super contentRectForRect:rect];
    
    rect.origin.x += 10;
    rect.origin.y += 13.0;
    rect.size.width -= 20.0;
    rect.size.height -= 20.0;
    
    if ([tabs count] == 0) return rect;
    
    size = [self rectForTab:0 inRect:rect].size;
    
    switch (tabType) {
        case NSTopTabsBezelBorder:
            rect.size.height -= size.height;
            break;
        case NSLeftTabsBezelBorder:
        case NSBottomTabsBezelBorder:
        case NSRightTabsBezelBorder:
        default:
            return rect;
    }
    
    return rect;
}

#define r2 5.0
#define r3 5.0

- (void)appendSelectedTabToPath:(NSBezierPath *)path inRect:(NSRect)rect forStroke:(BOOL)strokeFlag disabledTabsOnly:(BOOL)disabledTabsFlag
{
    NSRect            original = rect;
    NSRect            selectedRect;
    NSInteger                width = 1.0;
    
    if (disabledTabsFlag) return;
    
    rect = [self contentRectForRect:rect];
    selectedRect = [self rectForTab:selectedTab inRect:original];
    
    switch (tabType) {
        case NSTopTabsBezelBorder:
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
            break;
        case NSLeftTabsBezelBorder:
            break;
        case NSBottomTabsBezelBorder:
            break;
        case NSRightTabsBezelBorder:
            break;
        default:
            break;
    }
}

- (void)appendDisabledTabsToPath:(NSBezierPath *)path inRect:(NSRect)rect forStroke:(BOOL)strokeFlag disabledTabsOnly:(BOOL)disabledTabsFlag
{
    NSRect            original = rect;
    NSRect            selectedRect;
    NSInteger                x;
    NSInteger                tabCount = [tabs count];
    NSInteger                width = 1.0;
    
    rect = [self contentRectForRect:rect];
    selectedRect = [self rectForTab:selectedTab inRect:original];
    
    switch (tabType) {
        case NSTopTabsBezelBorder:
            for (x = 0; x < tabCount; x++) {
                if (x == selectedTab) continue;
                selectedRect = [self rectForTab:x inRect:original];
                if (x == 0) {
                    [path moveToPoint:(NSPoint){selectedRect.origin.x - r2 - r2, rect.origin.y + rect.size.height - width / 2.0}];
                    [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} radius:r3];
                } else {
                    [path moveToPoint:(NSPoint){selectedRect.origin.x, selectedRect.origin.y + selectedRect.size.height / 2.0}];
                }
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} radius:r3];
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
                if (x == selectedTab - 1) {
                    [path lineToPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width, selectedRect.origin.y + selectedRect.size.height / 2.0}];
                    if (!strokeFlag) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
                    }
                } else {
                    [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
                }
                if (!strokeFlag) {
                    if (x != 0) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x, selectedRect.origin.y + selectedRect.size.height / 2.0} radius:r3];
                    }
                    [path closePath];
                }
            }
            break;
        case NSLeftTabsBezelBorder:
            break;
        case NSBottomTabsBezelBorder:
            break;
        case NSRightTabsBezelBorder:
            break;
        default:
            break;
    }
}

- (NSBezierPath *)pathForRect:(NSRect)rect forStroke:(BOOL)strokeFlag disabledTabsOnly:(BOOL)disabledTabsFlag
{
    NSBezierPath        *path;
    NSRect                original = rect;
    float                    x, y, width, height, right, top, margin, radius, t;
    
    rect = [self contentRectForRect:rect];
    x = rect.origin.x;
    y = rect.origin.y;
    width = rect.size.width;
    height = rect.size.height;
    top = y + height;
    right = x + width;
    margin = (width / 2.0) - (1.25 * 72.0) / 2;
    radius = 9;
    
    path = [[NSBezierPath alloc] init];
    
    if (!disabledTabsFlag) {
        [path moveToPoint:(NSPoint){x, y + height / 2.0}];
        [path appendBezierPathWithArcFromPoint:(NSPoint){x, top} toPoint:(NSPoint){right, top} radius:radius];
        if ([tabs count] && tabType != NSNoTabsBezelBorder) {
            [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
        }
        [path appendBezierPathWithArcFromPoint:(NSPoint){right, top} toPoint:(NSPoint){right, y} radius:radius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){right, y} toPoint:(NSPoint){x, y} radius:radius / 2.0];
        
        t = right - margin;
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 4.5, y} toPoint:(NSPoint){t - 4.5, y + 13.5} radius:4.5];
        [path lineToPoint:(NSPoint){t - 4.5, y + 13.5}];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t, y + 13.5} toPoint:(NSPoint){t, y + 36.0} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t, y + 36.0} toPoint:(NSPoint){t - 18.0, y + 36.0} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 18.0, y + 36.0} toPoint:(NSPoint){t - 18.0, y + 13.5} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 18.0, y + 13.5} toPoint:(NSPoint){t - 13.5, y + 13.5} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 13.5, y} toPoint:(NSPoint){t - 18.0, y} radius:4.5];
        
        t = right - margin - 72.0;
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 4.5, y} toPoint:(NSPoint){t - 4.5, y + 13.5} radius:4.5];
        [path lineToPoint:(NSPoint){t - 4.5, y + 13.5}];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t, y + 13.5} toPoint:(NSPoint){t, y + 36.0} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t, y + 36.0} toPoint:(NSPoint){t - 18.0, y + 36.0} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 18.0, y + 36.0} toPoint:(NSPoint){t - 18.0, y + 13.5} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 18.0, y + 13.5} toPoint:(NSPoint){t - 13.5, y + 13.5} radius:4.5];
        [path appendBezierPathWithArcFromPoint:(NSPoint){t - 13.5, y} toPoint:(NSPoint){t - 18.0, y} radius:4.5];
        
        [path appendBezierPathWithArcFromPoint:(NSPoint){x, y} toPoint:(NSPoint){x, y + height / 2.0} radius:radius / 2.0];
        [path closePath];
    }
    if ([tabs count] && tabType != NSNoTabsBezelBorder) {
        [self appendDisabledTabsToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
    }
    
    return path;
}

- (NSBezierPath *)clippingPathForRect:(NSRect)rect
{
    return [self pathForRect:rect forStroke:NO disabledTabsOnly:NO];
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    CGContextRef    context = [[NSGraphicsContext currentContext] CGContext];
    NSBezierPath    *path = [self clippingPathForRect:rect];
    NSBezierPath    *clippingPath;
    
    CGContextSaveGState(context);
    
    clippingPath = [[NSBezierPath alloc] init];
    [clippingPath appendBezierPathWithRect:rect];
    [clippingPath appendBezierPath:path];
    [clippingPath setWindingRule:NSWindingRuleEvenOdd];
    [clippingPath addClip];
    
    CGContextTranslateCTM(context, 0.0, -3.0);
    [colors[ 0] set];
    [path setLineWidth:20.0];
    [path stroke];
    [colors[ 1] set];
    [path setLineWidth:18.0];
    [path stroke];
    [colors[ 2] set];
    [path setLineWidth:16.0];
    [path stroke];
    [colors[ 3] set];
    [path setLineWidth:14.0];
    [path stroke];
    [colors[ 4] set];
    [path setLineWidth:12.0];
    [path stroke];
    [colors[ 5] set];
    [path setLineWidth:10.0];
    [path stroke];
    [colors[ 6] set];
    [path setLineWidth:8.0];
    [path stroke];
    [colors[ 7] set];
    [path setLineWidth:6.0];
    [path stroke];
    [colors[ 8] set];
    [path setLineWidth:4.0];
    [path stroke];
    [colors[ 9] set];
    [path setLineWidth:2.0];
    [path stroke];
    [colors[10] set];
    [path fill];
    CGContextTranslateCTM(context, 0.0, 1.0);
    [colors[11] set];
    [path fill];
    CGContextTranslateCTM(context, 0.0, 1.0);
    [colors[12] set];
    [path fill];
    
    CGContextRestoreGState(context);
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    NSBezierPath    *path;
    
    if ([tabs count] && tabType != NSNoTabsBezelBorder) {
        // Let's "tint" the disabled tabs...
        path = [self pathForRect:rect forStroke:NO disabledTabsOnly:YES];
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
        [path fill];
        
        // Further more, tint the edges of the disabled tabs.
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
        path = [self pathForRect:rect forStroke:YES disabledTabsOnly:YES];
        [path setLineWidth:1.0];
        [path stroke];
        
        [self drawTabTextInRect:rect clippedToRect:clippingRect];
    }

    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}   

@end
