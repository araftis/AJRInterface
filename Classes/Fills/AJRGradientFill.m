
#import "AJRGradientFill.h"

#import <AJRInterfaceFoundation/AJRTrigonometry.h>

@implementation AJRGradientFill

+ (void)load {
    [AJRFill registerFill:self];
}

+ (NSString *)name {
    return @"Gradient Fill";
}

- (id)init {
	if ((self = [super init])) {
        _gradient = [[NSGradient alloc] initWithStartingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.25] endingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.75]];
		_angle = 335.0;
	}
    return self;
}


- (void)setGradient:(NSGradient *)gradient {
    if (_gradient != gradient) {
        [self willUpdate];
        _gradient = gradient;
        [self didUpdate];
    }
}

- (void)setAngle:(CGFloat)angle {
    if (_angle != angle) {
        [self willUpdate];
        _angle = angle;
        [self didUpdate];
    }
}

- (void)setColor:(NSColor *)aColor {
    NSGradient *old = _gradient;
    NSColor *endingColor;
    
    [old getColor:&endingColor location:NULL atIndex:[old numberOfColorStops] - 1];
    
    [self willUpdate];
    
    _gradient = [[NSGradient alloc] initWithStartingColor:aColor endingColor:endingColor];
    
    [self didUpdate];
}

- (NSColor *)color {
    NSColor *color = nil;
    
    [_gradient getColor:&color location:NULL atIndex:0];
    
    return color;
}

- (void)setSecondaryColor:(NSColor *)aColor {
    NSGradient *old = _gradient;
    NSColor *startingColor;
    
    [old getColor:&startingColor location:NULL atIndex:0];
    
    [self willUpdate];
    
    _gradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:aColor];

    [self didUpdate];
}

- (NSColor *)secondaryColor {
    NSColor *color = nil;
    
    [_gradient getColor:&color location:NULL atIndex:[_gradient numberOfColorStops] - 1];
    
    return color;
}

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView {
    [_gradient drawInBezierPath:path angle:_angle];
}

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView {
    [_gradient drawInRect:rect angle:_angle];
}

- (BOOL)isOpaque {
    return [[self color] alphaComponent] == 1.0 || [[self secondaryColor] alphaComponent] == 1.0;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding]) {
			_gradient = [coder decodeObjectForKey:@"gradient"];
			_angle = [coder decodeFloatForKey:@"angle"];
		} else {
			_gradient = [coder decodeObject];
			[coder decodeValueOfObjCType:@encode(CGFloat) at:&_angle];
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_gradient forKey:@"gradient"];
        [coder encodeFloat:_angle forKey:@"angle"];
    } else {
        [coder encodeObject:_gradient];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&_angle];
    }
}

@end
