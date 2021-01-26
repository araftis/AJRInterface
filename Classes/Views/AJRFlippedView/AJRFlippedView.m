
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
