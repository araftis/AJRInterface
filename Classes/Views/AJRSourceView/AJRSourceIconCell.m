/*
 AJRSourceIconCell.m
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

#import "AJRSourceIconCell.h"

#import "NSColor+Extensions.h"

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>
#import <objc/runtime.h>

@implementation AJRSourceIconCell

- (void)_setup {
    NSFont *font;
    NSShadow *shadow;
    NSMutableParagraphStyle *style;
    
    font = [NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]];
    shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowOffset:(NSSize){0, -1}];
    [shadow setShadowBlurRadius:1.0];
    style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
    _selectedTextAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               font, NSFontAttributeName,
                               shadow, NSShadowAttributeName,
                               [NSColor colorWithCalibratedWhite:1.0 alpha:1.0], NSForegroundColorAttributeName,
                               style, NSParagraphStyleAttributeName,
                               nil];
    
    font = [NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]];
    shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor whiteColor]];
    [shadow setShadowOffset:(NSSize){0, -1}];
    [shadow setShadowBlurRadius:1.0];
    style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
    _categoryTextAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               font, NSFontAttributeName,
                               shadow, NSShadowAttributeName,
                               [NSColor colorWithCalibratedWhite:93.0 / 255.0 alpha:1.0], NSForegroundColorAttributeName,
                               style, NSParagraphStyleAttributeName,
                               nil];
    
    style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    font = [NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]];
    _badgeHighlightedAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   font, NSFontAttributeName, 
                                   [NSColor sourceBadgeTextHighlightColor], NSForegroundColorAttributeName,
                                   style, NSParagraphStyleAttributeName, 
                                   nil];
    _badgeAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        font, NSFontAttributeName, 
                        [NSColor sourceBadgeTextColor], NSForegroundColorAttributeName, 
                        style, NSParagraphStyleAttributeName, 
                        nil];
}

- (id)init {
    if ((self = [super init])) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self _setup];
    }
    return self;
}


@synthesize icon = _icon;
@synthesize alternateIcon = _alternateIcon;
@synthesize badge = _badge;
@synthesize iconTarget = _iconTarget;
@synthesize iconAction = _iconAction;
@synthesize activity = _activity;

- (NSRect)badgeRectForCellFrame:(NSRect)cellFrame {
    if (_badge) {
        NSDictionary *badgeAttributes = nil;
        NSSize badgeSize;
        NSRect badgeRect;
        
        if ([self isHighlighted]) {
            badgeAttributes = _badgeHighlightedAttributes;
        } else {
            badgeAttributes = _badgeAttributes;
        }
        
        badgeSize = [_badge sizeWithAttributes:badgeAttributes];
        if (badgeSize.width < 10.0) badgeSize.width = 10.0;
        badgeRect.origin.x = cellFrame.origin.x + cellFrame.size.width - 15.0 - badgeSize.width;
        badgeRect.origin.y = cellFrame.origin.y + 2.0;
        badgeRect.size.width = badgeSize.width + 10.0;
        badgeRect.size.height = cellFrame.size.height - 5.0;
        if (badgeRect.size.height > 14.0) badgeRect.size.height = 14.0;
        
        return badgeRect;
    }
    
    return NSZeroRect;
}

- (NSRect)iconRectForBounds:(NSRect)cellFrame inView:(NSView *)controlView {
    if (_icon) {
        NSSize iconSize = [self.icon size];
        float scale = 1.0;
        
        if (iconSize.height > cellFrame.size.height) {
            if (iconSize.height > iconSize.width) {
                scale = cellFrame.size.height / iconSize.height;
            } else {
                scale = cellFrame.size.height / iconSize.width;
            }
        }
        return (NSRect){{cellFrame.origin.x, cellFrame.origin.y}, {round(iconSize.width * scale), round(iconSize.height * scale)}};
    }
    return NSZeroRect;
}

- (void)drawActivityWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    CGFloat radius = 8.0;
    NSRect activityFrame;
    NSPoint center;
    CGFloat lineWidth = 1.5;

    activityFrame.size.width = radius * 2.0;
    activityFrame.size.height = radius * 2.0;
    activityFrame.origin.x = cellFrame.origin.x + cellFrame.size.width - 20.0;
    activityFrame.origin.y = rint(cellFrame.origin.y + (cellFrame.size.height / 2.0) - (activityFrame.size.height / 2.0)) - 1.0;
    
    center.x = activityFrame.origin.x + activityFrame.size.width / 2.0;
    center.y = activityFrame.origin.y + activityFrame.size.height / 2.0;
    
    if ([_activity isIndeterminate]) {
        NSInteger        x;
        NSInteger        steps = 12;
        NSInteger        increment;
        CGFloat            step = 360.0 / (double)steps;
        NSBezierPath    *path;
        CGFloat            effectiveRadius = radius - lineWidth / 2.0;
        CGFloat            colorStep;
        
        if ([self isHighlighted]) {
            colorStep = ((double)(0xFF - 0x4F) / 255.0) / (double)steps;
        } else {
            colorStep = ((double)(0xC6 - 0x4F) / 255.0) / (double)steps;
        }

        increment = (NSInteger)(([NSDate timeIntervalSinceReferenceDate] - [[_activity startTime] timeIntervalSinceReferenceDate]) * 12.0) % steps;
        
        path = [[NSBezierPath alloc] init];
        [path setLineCapStyle:NSLineCapStyleRound];
        [path setLineWidth:lineWidth];
        for (x = 0; x < steps; x++) {
            NSPoint        point1, point2;
            
            point1.x = center.x + AJRCos(step * (double)((steps - x) + increment)) * effectiveRadius;
            point1.y = center.y + AJRSin(step * (double)((steps - x) + increment)) * effectiveRadius;
            point2.x = center.x + AJRCos(step * (double)((steps - x) + increment)) * (effectiveRadius - 3.0);
            point2.y = center.y + AJRSin(step * (double)((steps - x) + increment)) * (effectiveRadius - 3.0);
            
            [path removeAllPoints];
            [path moveToPoint:point1];
            [path lineToPoint:point2];
            
            if ([self isHighlighted]) {
                [[NSColor colorWithCalibratedWhite:1.0 alpha:((double)0xFF / 255.0) - colorStep * (double)x] set];
            } else {
                [[NSColor colorWithCalibratedWhite:((double)0x4F / 255.0) + colorStep * (double)x  alpha:1.0] set];
            }
            [path stroke];
        }
    } else {
        NSBezierPath    *path = [[NSBezierPath alloc] init];
        NSPoint            point;
        CGFloat            progress;
        CGFloat            effectiveRadius = radius - lineWidth / 2.0;
        
        if ([self isHighlighted]) {
            [[NSColor whiteColor] set];
        } else {
            [[NSColor colorWithDeviceRed:(float)0x8A / 255.0 green:(float)0xA4 / 255.0 blue:(float)0xCE / 255.0 alpha:1.0] set];
        }
        
        point = (NSPoint){center.x, center.y - effectiveRadius};
        [path moveToPoint:point];
        [path appendBezierPathWithArcWithCenter:center radius:effectiveRadius startAngle:270.0 endAngle:270.0 + 360.0];
        [path closePath];
        [path setLineWidth:lineWidth];
        [path stroke];
        
        progress = [_activity progress];
        if (progress > 0.0) {
            [path removeAllPoints];
            [path moveToPoint:center];
            [path appendBezierPathWithArcWithCenter:center radius:effectiveRadius startAngle:270.0 endAngle:270.0 + 360.0 * progress];
            [path closePath];
            [path fill];
        }
    }
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    BOOL leftMost = NO;
    NSRect badgeRect = [self badgeRectForCellFrame:cellFrame];
    CGFloat badgeAdjust = 0.0;
    
    if ([controlView isKindOfClass:[NSOutlineView class]]) {
        NSInteger        row = [(NSOutlineView *)controlView rowAtPoint:cellFrame.origin];
        if ([(NSOutlineView *)controlView levelForRow:row] == 0) {
            leftMost = YES;
        }
    }
    
    [NSGraphicsContext saveGraphicsState];
    
    cellFrame.origin.x += 2.0;
    cellFrame.size.width -= 2.0;
    NSRectClip(cellFrame);
    if (self.icon) {
        NSSize    iconSize = [self.icon size];
        float    scale = 1.0;
        NSRect    iconRect;
        
        if (iconSize.height > cellFrame.size.height) {
            if (iconSize.height > iconSize.width) {
                scale = cellFrame.size.height / iconSize.height;
            } else {
                scale = cellFrame.size.height / iconSize.width;
            }
        }
        if ([controlView isFlipped]) {
            NSAffineTransform    *transform;
            
            [[NSGraphicsContext currentContext] saveGraphicsState];

            transform = [[NSAffineTransform alloc] init];
            [transform translateXBy:0.0 yBy:cellFrame.origin.y];
            [transform scaleXBy:1.0 yBy:-1.0];
            [transform translateXBy:0.0 yBy:-cellFrame.origin.y - cellFrame.size.height];
            [transform translateXBy:0.0 yBy:round((fabs(cellFrame.size.height - iconSize.height * scale)) / 2.0)];
            [transform concat];
            
        }
        iconRect = (NSRect){{cellFrame.origin.x, cellFrame.origin.y}, {round(iconSize.width * scale), round(iconSize.height * scale)}};
        //AJRPrintf(@"%C: _inIcon: %B\n", self, _inIcon);
        [_inIcon ? self.alternateIcon : self.icon drawInRect:iconRect fromRect:(NSRect){{0.0, 0.0}, iconSize} operation:NSCompositingOperationSourceOver fraction:1.0];
        //[self.icon compositeToPoint:(NSPoint){cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - 1.0} operation:NSCompositingOperationSourceOver];
        cellFrame.origin.x += round(iconSize.width * scale);
        cellFrame.size.width -= round(iconSize.width * scale);
        if ([controlView isFlipped]) {
            [[NSGraphicsContext currentContext] restoreGraphicsState];
        }
    }
    
    if (_activity) {
        badgeAdjust = 18.0;
    } else if (_badge) {
        badgeAdjust = (cellFrame.origin.x + cellFrame.size.width) - badgeRect.origin.x;
    }
    
    cellFrame.origin.x += 2.0;
    cellFrame.size.width -= (2.0 + badgeAdjust);
    cellFrame.origin.y += 2.0;
    if (leftMost) {
        NSMutableDictionary *textAttributes = ([self isHighlighted] ? _selectedTextAttributes : _categoryTextAttributes);
        [textAttributes setObject:[[NSFontManager sharedFontManager] convertFont:[self font] toHaveTrait:NSFontBoldTrait] forKey:NSFontAttributeName];
        [[[self stringValue] uppercaseString] drawInRect:cellFrame withAttributes:textAttributes];
    } else if ([self isHighlighted]) {
        [_selectedTextAttributes setObject:[[NSFontManager sharedFontManager] convertFont:[self font] toHaveTrait:NSFontBoldTrait] forKey:NSFontAttributeName];
        [[self stringValue] drawInRect:cellFrame withAttributes:_selectedTextAttributes];
    } else {
        [[self attributedStringValue] drawInRect:cellFrame];
    }
    
    cellFrame.origin.y -= 2.0;
    cellFrame.size.width += badgeAdjust;
    
    if (_activity) {
        [self drawActivityWithFrame:cellFrame inView:controlView];
    } else if (_badge) {
        NSDictionary            *badgeAttributes = nil;
        NSBezierPath            *path;
        
        if ([self isHighlighted]) {
            badgeAttributes = _badgeHighlightedAttributes;
            [[NSColor sourceBadgeHighlightColor] set];
        } else {
            badgeAttributes = _badgeAttributes;
            [[NSColor sourceBadgeColor] set];
        }

        
        path = [[NSBezierPath alloc] init];
        [path appendBezierPathWithRoundedRect:badgeRect xRadius:floor(badgeRect.size.height / 2.0) yRadius:floor(badgeRect.size.height / 2.0)];
        [path fill];
        
        badgeRect.origin.y -= 0.0;
        badgeRect.origin.x += 1.0;
        badgeRect.size.width -= 1.0;
        [_badge drawInRect:badgeRect withAttributes:badgeAttributes];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (id)copyWithZone:(NSZone *)zone {
    AJRSourceIconCell *cell = [super copyWithZone:zone];
    
    [cell setIcon:[self icon]];
    [cell setAlternateIcon:[self alternateIcon]];
    cell->_selectedTextAttributes = [_selectedTextAttributes mutableCopy];
    cell->_categoryTextAttributes = [_categoryTextAttributes mutableCopy];
    cell->_badgeAttributes = [_badgeAttributes mutableCopy];
    cell->_badgeHighlightedAttributes = [_badgeHighlightedAttributes mutableCopy];
    cell->_badge = _badge;
    cell->_activity = _activity;
    cell->_iconTarget = _iconTarget;
    cell->_iconAction = _iconAction;
    cell->_inIcon = NO;
    
    return cell;
}

#pragma mark Event Tracking

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
    Method method = class_getInstanceMethod([NSActionCell class], _cmd);
    BOOL (*original)(id, SEL, NSEvent *, NSRect, NSView *, BOOL) = (BOOL (*)(id, SEL, NSEvent *, NSRect, NSView *, BOOL))method_getImplementation(method);

    [controlView setNeedsDisplayInRect:cellFrame];
    
    original(self, _cmd, theEvent, cellFrame, controlView, untilMouseUp);
    
    return YES;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    //AJRPrintf(@"%C: %S\n", self, _cmd);
    return YES;
}

- (BOOL)_isPointInButton:(NSPoint)point inView:(NSView *)controlView {
    return NSPointInRect(point, [self iconRectForBounds:_cellFrame inView:controlView]);
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
    BOOL oldState = _inIcon;
    
//    AJRPrintf(@"%C: %.0f >= %.0f <= %.0f\n", 
//             self, 
//             _cellFrame.origin.x + _cellFrame.size.width - 15.0,
//             currentPoint.x, 
//             _cellFrame.origin.x + _cellFrame.size.width);
    
    _inIcon = [self _isPointInButton:currentPoint inView:controlView];
    if ((_inIcon && !oldState) || (!_inIcon && oldState)) {
        [controlView setNeedsDisplayInRect:_cellFrame];
    }
    return YES;
}

- (void)_sendButtonAction {
    _inIcon = NO;
    [NSApp sendAction:_iconAction to:_iconTarget from:self];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
//    AJRPrintf(@"%C: %S\n", self, _cmd);
    _inIcon = NO;
    if ([self _isPointInButton:stopPoint inView:controlView]) {
        [self performSelector:@selector(_sendButtonAction) withObject:nil afterDelay:0.01];
    }
    _inIcon = NO;
    [controlView setNeedsDisplay:YES];
}

- (NSCellHitResult)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSPoint where = [controlView convertPoint:[event locationInWindow] fromView:nil];
    
    if (_iconAction && NSPointInRect(where, [self iconRectForBounds:cellFrame inView:controlView])) {
//        AJRPrintf(@"%C: hitTestForEvent: %P, %R\n", self, where, [self iconRectForBounds:cellFrame inView:controlView]);        
        _inIcon = NO;//YES;
        _cellFrame = cellFrame;
        return NSCellHitTrackableArea;
    }
    
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
}

+ (BOOL)prefersTrackingUntilMouseUp {
    return YES;
}

@end
