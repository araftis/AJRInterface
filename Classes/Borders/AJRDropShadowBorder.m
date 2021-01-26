
#import "AJRDropShadowBorder.h"

@implementation AJRDropShadowBorder

+ (void)load
{
    [AJRBorder registerBorder:self];
}

+ (NSString *)name
{
    return @"Drop Shadow";
}

- (id)init
{
    self = [super init];
    
    shallow = NO;
    clip = YES;
    [self setRadius:0.0];
    
    return self;
}

- (BOOL)isOpaque
{
    return NO;
}

- (NSRect)titleRectForRect:(NSRect)rect
{
    rect = [super titleRectForRect:rect];
    
    switch ([self titleAlignment]) {
        case NSTextAlignmentJustified:
        case NSTextAlignmentNatural:
        case NSTextAlignmentLeft:
            rect.origin.x += 5.0;
            break;
        case NSTextAlignmentCenter:
            break;
        case NSTextAlignmentRight:
            rect.origin.x -= 5.0;
            break;
    }
    
    return rect;
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    rect = [super contentRectForRect:rect];
    
    if (shallow) {
        rect.origin.x += 5.0;
        rect.origin.y += 10.0;
        rect.size.width -= 10.0;
        rect.size.height -= 10.0;
    } else {
        rect.origin.x += 10;
        rect.origin.y += 18.0;
        rect.size.width -= 20.0;
        rect.size.height -= 20.0;
    }
    
    return rect;
}

- (NSBezierPath *)pathForRect:(NSRect)rect
{
    NSBezierPath *path;
    path = [[NSBezierPath allocWithZone:nil] init];
    [path appendBezierPathWithRoundedRect:[self contentRectForRect:rect] xRadius:radius yRadius:radius];
    return path;
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    NSShadow        *shadow;
    NSColor            *color = [NSColor whiteColor];
    NSBezierPath    *clippingPath;
    NSBezierPath    *path;
    
    [NSGraphicsContext saveGraphicsState];

    shadow = [[NSShadow alloc] init];
    if (shallow) {
        [shadow setShadowOffset:NSMakeSize(0.0f, -3.0f)];
        [shadow setShadowBlurRadius:5.0f];
    } else {
        [shadow setShadowOffset:NSMakeSize(0.0f, -5.0f)];        
        [shadow setShadowBlurRadius:10.0f];
    }

    path = [self pathForRect:rect];

    clippingPath = [[NSBezierPath alloc] init];
    [clippingPath setWindingRule:NSEvenOddWindingRule];
    [clippingPath appendBezierPathWithRect:NSInsetRect(rect, -20.0, -20.0)];
    [clippingPath appendBezierPath:path];
    [clippingPath addClip];
    
    [color set];
    [shadow set];
    [path fill];

    [NSGraphicsContext restoreGraphicsState];
}


- (NSBezierPath *)clippingPathForRect:(NSRect)rect
{
    return [self pathForRect:rect];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}

- (void)setShallow:(BOOL)flag
{
    shallow = flag;
    [self didUpdate];
}

- (BOOL)isShallow
{
    return shallow;
}

- (void)setClip:(BOOL)flag
{
    clip = flag;
    [self didUpdate];
}

- (BOOL)doesClip
{
    return clip;
}

- (void)setRadius:(CGFloat)aRadius
{
    if (radius != aRadius) {
        [self willUpdate];
        radius = aRadius;
        [self didUpdate];
    }
}

- (CGFloat)radius
{
    return radius;
}

- (id)initWithCoder:(NSCoder *)coder
{
    BOOL        temp;
    
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"shallow"]) {
        shallow = [coder decodeBoolForKey:@"shallow"];
        clip = [coder decodeBoolForKey:@"clip"];
        radius = [coder decodeFloatForKey:@"radius"];
    } else {
        [coder decodeValueOfObjCType:@encode(BOOL) at:&temp]; shallow = temp;
        [coder decodeValueOfObjCType:@encode(BOOL) at:&temp]; clip = temp;
        [coder decodeValueOfObjCType:@encode(float) at:&temp]; radius = temp;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    BOOL        temp;
    
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeBool:shallow forKey:@"shallow"];
        [coder encodeBool:clip forKey:@"clip"];
        [coder encodeFloat:radius forKey:@"radius"];
    } else {
        temp = shallow;
        [coder encodeValueOfObjCType:@encode(BOOL) at:&temp];
        temp = clip;
        [coder encodeValueOfObjCType:@encode(BOOL) at:&temp];
        temp = radius;
        [coder encodeValueOfObjCType:@encode(float) at:&temp];
    }
}

@end
