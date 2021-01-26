
#import "AJRSolidFill.h"

@implementation AJRSolidFill

+ (void)load
{
    [AJRFill registerFill:self];
}

+ (NSString *)name
{
    return @"Solid Fill";
}

- (id)init
{
    self = [super init];
    
    _color = [NSColor whiteColor];
    
    return self;
}


@synthesize color = _color;
@synthesize unfocusedColor = _unfocusedColor;

- (void)setColor:(NSColor *)color
{
    if (_color != color) {
        [self willUpdate];
        _color = color;
        [self didUpdate];
    }
}

- (void)setUnfocusedColor:(NSColor *)color
{
    if (_unfocusedColor != color) {
        [self willUpdate];
        _unfocusedColor = color;
        [self didUpdate];
    }
}

- (BOOL)isViewFocused:(NSView *)view
{
    if ([[view window] firstResponder] == view) return YES;
    if ([view superview]) return [self isViewFocused:[view superview]];
    return NO;
}

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView
{
    if (_unfocusedColor) {
        if ([self isViewFocused:controlView]) {
            [_color set];
        } else {
            [_unfocusedColor set];
        }
    } else {
        [_color set];
    }
    [path fill];
}

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView
{
    if (_unfocusedColor) {
        if ([self isViewFocused:controlView] && [[controlView window] isKeyWindow] && [NSApp isActive]) {
            [_color set];
        } else {
            [_unfocusedColor set];
        }
    } else {
        [_color set];
    }
    NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (BOOL)isOpaque
{
    return [_color alphaComponent] == 1.0;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"color"]) {
        _color = [coder decodeObjectForKey:@"color"];
        if ([coder containsValueForKey:@"unfocusedColor"]) {
            _unfocusedColor = [coder decodeObjectForKey:@"unfocusedColor"];
        }
    } else {
        _color = [coder decodeObject];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_color forKey:@"color"];
        [coder encodeObject:_unfocusedColor forKey:@"unfocusedColor"];
    } else {
        [coder encodeObject:_color];
    }
}

@end
