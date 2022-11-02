/*
 AJRFlippedView.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import "AJRFlippedView.h"

#import "NSBezierPath+Extensions.h"

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

@implementation AJRFlippedView

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    BOOL isActive = NSApp.isActive && self.window.isKeyWindow;

    if (_backgroundColor) {
        [_backgroundColor set];
        NSRectFill(rect);
    }
    if (_crossColor) {
        [_crossColor set];
        [[NSBezierPath bezierPathWithCrossedRect:[self bounds]] stroke];
    }
    
    CGFloat hairline = 1.0;
    if (self.borderIsHairline && self.window.screen) {
        hairline = 1.0 / self.window.screen.backingScaleFactor;
    }
    if (_borderColorTop || _borderColorLeft || _borderColorBottom || _borderColorRight) {
        CGContextRef context = AJRGetCurrentContext();
        CGPoint points[2];
        CGContextSetLineWidth([[NSGraphicsContext currentContext] CGContext], hairline);
        if (_borderColorBottom) {
            if (!isActive && _inactiveBorderColorBottom) {
                [_inactiveBorderColorBottom set];
            } else {
                [_borderColorBottom set];
            }
            points[0] = (CGPoint){NSMinX(bounds), NSMaxY(bounds) - hairline / 2.0};
            points[1] = (CGPoint){NSMaxX(bounds), NSMaxY(bounds) - hairline / 2.0};
            CGContextStrokeLineSegments(context, points, 2);
        }
        if (_borderColorTop) {
            if (!isActive && _inactiveBorderColorTop) {
                [_inactiveBorderColorTop set];
            } else {
                [_borderColorTop set];
            }
            points[0] = (CGPoint){NSMinX(bounds), NSMinY(bounds) + hairline / 2.0};
            points[1] = (CGPoint){NSMaxX(bounds), NSMinY(bounds) + hairline / 2.0};
            CGContextStrokeLineSegments(context, points, 2);
        }
        if (_borderColorLeft) {
            if (!isActive && _inactiveBorderColorLeft) {
                [_inactiveBorderColorLeft set];
            } else {
                [_borderColorLeft set];
            }
            points[0] = (CGPoint){NSMinX(bounds) + hairline / 2.0, NSMinY(bounds)};
            points[1] = (CGPoint){NSMinX(bounds) + hairline / 2.0, NSMaxY(bounds)};
            CGContextStrokeLineSegments(context, points, 2);
        }
        if (_borderColorRight) {
            if (!isActive && _inactiveBorderColorRight) {
                [_inactiveBorderColorRight set];
            } else {
                [_borderColorRight set];
            }
            points[0] = (CGPoint){NSMaxX(bounds) - hairline / 2.0, NSMinY(bounds)};
            points[1] = (CGPoint){NSMaxX(bounds) - hairline / 2.0, NSMaxY(bounds)};
            CGContextStrokeLineSegments(context, points, 2);
        }
    } else if (_borderColor) {
        if (!isActive && _inactiveBorderColorBottom) {
            [_inactiveBorderColor set];
        } else {
            [_borderColor set];
        }
        CGContextSetLineWidth([[NSGraphicsContext currentContext] CGContext], hairline);
        NSFrameRect(bounds);
    }
    [super drawRect:rect];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_backgroundColor forKey:@"backgroundColor"];
    [coder encodeObject:_borderColor forKey:@"borderColor"];
    [coder encodeObject:_crossColor forKey:@"crossColor"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        _backgroundColor = [coder decodeObjectForKey:@"backgroundColor"];
        _borderColor = [coder decodeObjectForKey:@"borderColor"];
        _crossColor = [coder decodeObjectForKey:@"crossColor"];
    }
    return self;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    __weak AJRFlippedView *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf setNeedsDisplay:YES];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf setNeedsDisplay:YES];
    }];
}

@end
