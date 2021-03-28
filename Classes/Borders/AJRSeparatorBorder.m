
#import "AJRSeparatorBorder.h"

#import "AJRGradientColor.h"

@implementation AJRSeparatorBorder

#pragma mark - Loading

+ (void)load {
    [AJRBorder registerBorder:self];
}

#pragma mark - Properties

- (void)setLeftColor:(AJRGradientColor *)color {
    if (_leftColor != color) {
        [self willUpdate];
        _leftColor = color;
        [self didUpdate];
    }
}

- (void)setRightColor:(AJRGradientColor *)color {
    if (_rightColor != color) {
        [self willUpdate];
        _rightColor = color;
        [self didUpdate];
    }
}

- (void)setTopColor:(AJRGradientColor *)color {
    if (_topColor != color) {
        [self willUpdate];
        _topColor = color;
        [self didUpdate];
    }
}

- (void)setBottomColor:(AJRGradientColor *)color {
    if (_bottomColor != color) {
        [self willUpdate];
        _bottomColor = color;
        [self didUpdate];
    }
}

- (void)setBackgroundColor:(AJRGradientColor *)color {
    if (_backgroundColor != color) {
        [self willUpdate];
        _backgroundColor = color;
        [self didUpdate];
    }
}

#pragma mark - Border

- (BOOL)isOpaque {
    return _backgroundColor && ([[_backgroundColor color] alphaComponent] == 1.0);
}

- (NSRect)contentRectForRect:(NSRect)rect {
    NSRect      result = rect;
    
    if (_topColor || _inactiveTopColor) {
        result.size.height -= 1.0;
    }
    if (_bottomColor || _inactiveBottomColor) {
        result.origin.y += 1.0;
        result.size.height -= 1.0;
    }
    if (_leftColor || _inactiveLeftColor) {
        result.size.width -= 1.0;
        result.origin.x += 1.0;
    }
    if (_rightColor || _inactiveRightColor) {
        result.size.width -= 1.0;
    }
    
    return result;
}

- (AJRGradientColor *)colorForColor:(AJRGradientColor *)activeColor or:(AJRGradientColor *)inactiveColor for:(NSView *)controlView {
    return [self isControlViewActive:controlView] ? activeColor : (inactiveColor ? inactiveColor : activeColor);
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    [[self colorForColor:_backgroundColor or:_inactiveBackgroundColor for:controlView] drawInRect:[self contentRectForRect:rect]];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    NSRect work;

    if (_topColor || _inactiveTopColor) {
        work.origin.x = NSMinX(rect);
        work.size.width = rect.size.width;
        work.origin.y = NSMaxY(rect) - 1.0;
        work.size.height = 1.0;
        [[self colorForColor:_topColor or:_inactiveTopColor for:controlView] drawInRect:work];
    }
    if (_bottomColor || _inactiveBottomColor) {
        work.origin.x = NSMinX(rect);
        work.size.width = rect.size.width;
        work.origin.y = NSMinY(rect);
        work.size.height = 1.0;
        [[self colorForColor:_bottomColor or:_inactiveBottomColor for:controlView] drawInRect:work];
    }
    if (_leftColor || _inactiveLeftColor) {
        work.origin.x = NSMinX(rect);
        work.size.width = 1.0;
        work.origin.y = NSMinY(rect);
        work.size.height = rect.size.height;
        [[self colorForColor:_leftColor or:_inactiveLeftColor for:controlView] drawInRect:work];
    }
    if (_rightColor || _inactiveRightColor) {
        work.origin.x = NSMaxX(rect) - 1.0;
        work.size.width = 1.0;
        work.origin.y = NSMinY(rect);
        work.size.height = rect.size.height;
        [[self colorForColor:_rightColor or:_inactiveRightColor for:controlView] drawInRect:work];
    }
}

@end
