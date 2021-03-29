/*
AJRLineBorder.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#import "AJRLineBorder.h"

#import <AJRInterfaceFoundation/AJRTrigonometry.h>

@implementation AJRLineBorder

+ (void)load {
    [AJRBorder registerBorder:self];
}

+ (NSString *)name {
    return @"Line";
}

- (id)init {
	if ((self = [super init])) {
		[self setColor:[NSColor colorWithCalibratedWhite:.541 alpha:1.0]];
		[self setWidth:1.0];
		[self setRadius:0.0];
	}
    return self;
}

- (BOOL)isOpaque {
    return (radius == 0.0) && ([color alphaComponent] == 1.0) && ([tabs count] == 0);
}

- (NSSize)sizeForTab:(NSUInteger)index {
    NSSize        size = [super sizeForTab:index];
    
    size.width += 10.0;
    
    return size;
}

- (AJRBorderTabMask)availableTabEdges {
    return AJRBorderTabsAll;
}

- (CGFloat)marginBetweenTabs:(NSInteger)index1 and:(NSInteger)index2 {
    if (index1 == -1 || index2 == -1) {
        if (radius > 15.0) return 5.0 + radius;
        return 20.0;
    }
    return 10.0;
}

- (NSRect)unclippedContentRectForRect:(NSRect)rect {
    NSPoint origin;
    NSPoint insetPoint;
    CGFloat inset;
    
    if (radius == 0.0) return [self contentRectForRect:rect];
    
    origin = (NSPoint){ rect.origin.x + radius + width, rect.origin.y + radius + width };
    insetPoint.x = AJRCos(225.0) * radius + origin.x;
    insetPoint.y = AJRSin(225.0) * radius + origin.y;
    
    inset = AJRDistanceBetweenPoints(rect.origin, insetPoint);
    
    rect.origin.x += inset;
    rect.origin.y += inset;
    rect.size.width -= inset * 2;
    rect.size.height -= inset * 2;
    
    return rect;
}

- (void)setWidth:(CGFloat)aWidth {
    if (width != aWidth) {
        [self willUpdate];
        width = aWidth;
        [self didUpdate];
    }
}

- (CGFloat)width {
    return width;
}

- (void)setColor:(NSColor *)aColor {
    if (color != aColor) {
        [self willUpdate];
        color = aColor;
        [self didUpdate];
    }
}

- (NSColor *)color {
    return color;
}

- (void)setRadius:(CGFloat)aRadius {
    if (radius != aRadius) {
        [self willUpdate];
        radius = aRadius;
        [self didUpdate];
    }
}

- (CGFloat)radius {
    return radius;
}

// This methods takes the tabs into account...
- (NSRect)contentRectForRect:(NSRect)rect {
    NSSize    size;
    
    rect = [super contentRectForRect:rect];
    rect.origin.x += width;
    rect.origin.y += width;
    rect.size.width -= width * 2;
    rect.size.height -= width * 2;
    
    if ([tabs count] == 0) return rect;
    
    size = [self rectForTab:0 inRect:rect].size;
    
    switch (tabType) {
        case NSTopTabsBezelBorder:
            rect.size.height -= size.height;
            break;
        case NSLeftTabsBezelBorder:
            rect.size.width -= size.width;
            rect.origin.x += size.width;
            break;
        case NSBottomTabsBezelBorder:
            rect.origin.y += size.height;
            rect.size.height -= size.height;
            break;
        case NSRightTabsBezelBorder:
            rect.size.width -= size.width;
            break;
        default:
            return rect;
    }
    
    return rect;
}

- (AJRInset)shadowInset {
    return (AJRInset){width, width, width, width};
}

#define r2 5.0
#define r3 5.0

- (void)appendSelectedTabToPath:(NSBezierPath *)path inRect:(NSRect)rect forStroke:(BOOL)strokeFlag disabledTabsOnly:(BOOL)disabledTabsFlag {
    NSRect original = rect;
    NSRect selectedRect;
    
    if (disabledTabsFlag) return;
    
    rect = [self contentRectForRect:rect];
    selectedRect = [self rectForTab:selectedTab inRect:original];
    
    switch (tabType) {
        default:
        case NSTopTabsBezelBorder:
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, selectedRect.origin.y + selectedRect.size.height - width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
            break;
        case NSLeftTabsBezelBorder:
            [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y - r2} toPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + r2} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + r2} toPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} toPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2} toPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height - width / 2.0} radius:r3];
            break;
        case NSBottomTabsBezelBorder:
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y - selectedRect.size.height + width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y - selectedRect.size.height + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y - selectedRect.size.height + width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y - selectedRect.size.height + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + width / 2.0} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} radius:r3];
            break;
        case NSRightTabsBezelBorder:
            [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + r2} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + r2} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y - r2} radius:r3];
            [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y - r2} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y - width / 2.0} radius:r3];
            break;
    }
}

- (void)appendDisabledTabsToPath:(NSBezierPath *)path inRect:(NSRect)rect forStroke:(BOOL)strokeFlag disabledTabsOnly:(BOOL)disabledTabsFlag {
    NSRect original = rect;
    NSRect selectedRect;
    NSInteger x;
    NSInteger tabCount = [tabs count];
    
    rect = [self contentRectForRect:rect];
    selectedRect = [self rectForTab:selectedTab inRect:original];
    
    switch (tabType) {
        default:
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
            for (x = 0; x < tabCount; x++) {
                if (x == selectedTab) continue;
                selectedRect = [self rectForTab:x inRect:original];
                if (x == 0) {
                    [path moveToPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y - r2 - r2}];
                    [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y - r2} toPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + r2} radius:r3];
                } else {
                    [path moveToPoint:(NSPoint){rect.origin.x - selectedRect.size.width / 2.0, selectedRect.origin.y}];
                }
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + r2} toPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} radius:r3];
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} toPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2} radius:r3];
                if (x == selectedTab - 1) {
                    [path lineToPoint:(NSPoint){rect.origin.x - selectedRect.size.width / 2.0, selectedRect.origin.y + selectedRect.size.height}];
                    if (!strokeFlag) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x +  width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} toPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y + r2} radius:r3];
                    }
                } else {
                    [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2} toPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height} radius:r3];
                }
                if (!strokeFlag) {
                    if (x != 0) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y + r2} toPoint:(NSPoint){rect.origin.x + width / 2.0, selectedRect.origin.y - r2 - r2} radius:r3];
                    }
                    [path closePath];
                }
            }
            break;
        case NSBottomTabsBezelBorder:
            for (x = tabCount - 1; x >= 0; x--) {
                if (x == selectedTab) continue;
                selectedRect = [self rectForTab:x inRect:original];
                if (x == tabCount - 1) {
                    [path moveToPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2 + r3, rect.origin.y + width / 2.0}];
                    [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width + r2, rect.origin.y + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y - selectedRect.size.height + width / 2.0} radius:r3];
                } else {
                    [path moveToPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width, rect.origin.y - selectedRect.size.height / 2.0}];
                }
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y - selectedRect.size.height + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y - selectedRect.size.height + width / 2.0} radius:r3];
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y - selectedRect.size.height + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + width / 2.0} radius:r3];
                if (x == selectedTab + 1) {
                    [path lineToPoint:(NSPoint){selectedRect.origin.x, rect.origin.y - selectedRect.size.height / 2.0}];
                    if (!strokeFlag) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + r2, rect.origin.y + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y + width / 2.0} radius:r3];
                    }
                } else {
                    [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x - r2, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x, rect.origin.y + width / 2.0} radius:r3];
                }
                if (!strokeFlag) {
                    if (x != tabCount - 1) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - r2, rect.origin.y + width / 2.0} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width, rect.origin.y - selectedRect.size.height / 2.0} radius:r3];
                    }
                    [path closePath];
                }
            }
            break;
        case NSRightTabsBezelBorder:
            for (x = 0; x < tabCount; x++) {
                if (x == selectedTab) continue;
                selectedRect = [self rectForTab:x inRect:original];
                if (x == 0) {
                    [path moveToPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2 + r2}];
                    [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} radius:r3];
                } else {
                    [path moveToPoint:(NSPoint){rect.origin.x + rect.size.width + selectedRect.size.width / 2.0, selectedRect.origin.y + selectedRect.size.height}];
                }
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} toPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + r2} radius:r3];
                [path appendBezierPathWithArcFromPoint:(NSPoint){selectedRect.origin.x + selectedRect.size.width - width / 2.0, selectedRect.origin.y + r2} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y - r2} radius:r3];
                if (x == selectedTab - 1) {
                    [path lineToPoint:(NSPoint){rect.origin.x + rect.size.width + selectedRect.size.width / 2.0, selectedRect.origin.y}];
                    if (!strokeFlag) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + r2} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.width - r2} radius:r3];
                    }
                } else {
                    [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + - r2} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y} radius:r3];
                }
                if (!strokeFlag) {
                    if (x != 0) {
                        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height - r2} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, selectedRect.origin.y + selectedRect.size.height + r2 + r2} radius:r3];
                    }
                    [path closePath];
                }
            }
            break;
    }
}

- (NSBezierPath *)pathForRect:(NSRect)rect forStroke:(BOOL)strokeFlag disabledTabsOnly:(BOOL)disabledTabsFlag {
    NSBezierPath *path;
    NSRect original = rect;
    NSRect selectedRect;
    BOOL hasTabs = [tabs count] != 0 && tabType != NSNoTabsBezelBorder;
    
    rect = [self contentRectForRect:rect];
    rect = NSInsetRect(rect, -width, -width);
    selectedRect = [self rectForTab:selectedTab inRect:original];
    
    path = [[NSBezierPath allocWithZone:nil] init];
    if (radius == 0.0) {
        if (hasTabs) {
            if (!disabledTabsFlag) {
                [path moveToPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0}];
                if (tabType == NSLeftTabsBezelBorder) {
                    [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
                }
                [path lineToPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height - width / 2.0}];
                if (tabType == NSTopTabsBezelBorder) {
                    [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
                }
                [path lineToPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0}];
                if (tabType == NSRightTabsBezelBorder) {
                    [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
                }
                [path lineToPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0}];
                if (tabType == NSBottomTabsBezelBorder) {
                    [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
                }
                [path closePath];
            }
            // Add in paths for other tabs...
            [self appendDisabledTabsToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
        } else {
            [path appendBezierPathWithRect:(NSRect){{rect.origin.x + width / 2.0, rect.origin.y + width / 2.0}, {rect.size.width - width, rect.size.height - width}}];
        }
    } else {
        if (hasTabs) {
            [self appendDisabledTabsToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
            if (!disabledTabsFlag) {
            }
        }
        [path appendBezierPathWithRoundedRect:(NSRect){{rect.origin.x + width / 2.0, rect.origin.y + width / 2.0}, {rect.size.width - width, rect.size.height - width}} xRadius:radius yRadius:radius];
//        [path moveToPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height / 2.0 - width / 2.0}];
//        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0} radius:radius];
//        if (hasTabs && tabType == NSTopTabsBezelBorder) {
//            [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
//        }
//        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0} radius:radius];
//        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} radius:radius];
//        if (hasTabs && tabType == NSBottomTabsBezelBorder) {
//            [self appendSelectedTabToPath:path inRect:original forStroke:strokeFlag disabledTabsOnly:disabledTabsFlag];
//        }
//        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - width / 2.0} radius:radius];
//        [path closePath];
    }
    
    return path;
}

- (NSBezierPath *)clippingPathForRect:(NSRect)rect {
    return [self pathForRect:rect forStroke:NO disabledTabsOnly:NO];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    NSBezierPath *path;
    
    if ([tabs count] && tabType != NSNoTabsBezelBorder) {
        // Let's "tint" the disabled tabs...
        path = [self pathForRect:rect forStroke:NO disabledTabsOnly:YES];
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
        [path fill];
    }
    
    [color set];
    path = [self pathForRect:rect forStroke:YES disabledTabsOnly:NO];
    [path setLineWidth:width];
    [path stroke];
    
    if ([tabs count] && tabType != NSNoTabsBezelBorder) {
        [self drawTabTextInRect:rect clippedToRect:clippingRect];
    }
    
    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"width"]) {
			width = [coder decodeFloatForKey:@"width"];
			color = [coder decodeObjectForKey:@"color"];
			radius = [coder decodeFloatForKey:@"radius"];
		} else {
			[coder decodeValueOfObjCType:@encode(CGFloat) at:&width];
			[self setColor:[coder decodeObject]];
			[coder decodeValueOfObjCType:@encode(CGFloat) at:&radius];
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeFloat:width forKey:@"width"];
        [coder encodeObject:color forKey:@"color"];
        [coder encodeFloat:radius forKey:@"radius"];
    } else {
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&width];
        [coder encodeObject:color];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&radius];
    }
}

@end
