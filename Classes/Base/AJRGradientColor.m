
#import "AJRGradientColor.h"

#import "NSBezierPath+Extensions.h"

@implementation AJRGradientColor {
	BOOL _linearGradient;
}
#pragma mark - Creation

+ (id)gradientColorWithColor:(NSColor *)color {
    return [[self alloc] initWithColor:color];
}

+ (id)gradientColorWithGradient:(NSGradient *)gradient angle:(CGFloat)angle {
    return [[self alloc] initWithGradient:gradient angle:angle];
}

+ (id)gradientColorWithGradient:(NSGradient *)gradient relativeCenterPosition:(NSPoint)relativeCenterPosition {
    return [[self alloc] initWithGradient:gradient relativeCenterPosition:relativeCenterPosition];
}

- (id)initWithColor:(NSColor *)color {
    if ((self = [super init])) {
        _color = color;
    }
    return self;
}

- (id)initWithGradient:(NSGradient *)gradient angle:(CGFloat)angle {
    if ((self = [super init])) {
        _gradient = gradient;
        _angle = angle;
        _linearGradient = YES;
    }
    return self;
}

- (id)initWithGradient:(NSGradient *)gradient relativeCenterPosition:(NSPoint)relativeCenterPosition {
    if ((self = [super init])) {
        _gradient = gradient;
        _relativeCenterPosition = relativeCenterPosition;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawBezierPath:(NSBezierPath *)path {
    if (_color) {
        [_color set];
        [path stroke];
    } else {
        if (_linearGradient) {
            [_gradient drawInBezierPath:[path bezierPathFromStrokedPath] angle:_angle];
        } else {
            [_gradient drawInBezierPath:[path bezierPathFromStrokedPath] relativeCenterPosition:_relativeCenterPosition];
        }
    }
}

- (void)drawInBezierPath:(NSBezierPath *)path {
    if (_color) {
        [_color set];
        [path fill];
    } else {
        if (_linearGradient) {
            [_gradient drawInBezierPath:path angle:_angle];
        } else {
            [_gradient drawInBezierPath:path relativeCenterPosition:_relativeCenterPosition];
        }
    }
}

- (void)drawInRect:(NSRect)rect {
    if (_color) {
        [_color set];
        NSRectFill(rect);
    } else {
        if (_linearGradient) {
            [_gradient drawInRect:rect angle:_angle];
        } else {
            [_gradient drawInRect:rect relativeCenterPosition:_relativeCenterPosition];
        }
    }
}

@end
