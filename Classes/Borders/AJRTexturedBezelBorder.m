
#import "AJRTexturedBezelBorder.h"

#import "AJREmbossRenderer.h"

@implementation AJRTexturedBezelBorder

+ (void)load
{
    [AJRBorder registerBorder:self];
}

+ (NSString *)name
{
    return @"Textured Bezel";
}

- (id)init
{
    self = [super init];
    
    renderer = [[AJREmbossRenderer alloc] init];
    [renderer setError:0.1];
    radius = 10;
    width = 3.0;
    
    return self;
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)setRadius:(float)aRadius
{
    if (radius != aRadius) {
        radius = aRadius;
        [self didUpdate];
    }
}

- (float)radius
{
    return radius;
}

- (void)setWidth:(float)aWidth
{
    if (width != aWidth) {
        width = aWidth;
        [self didUpdate];
    }
}

- (float)width
{
    return width;
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    rect = [super contentRectForRect:rect];
    
    rect.origin.x += width;
    rect.origin.y += width;
    rect.size.width -= (width * 2.0);
    rect.size.height -= (width * 2.0);
    
    return rect;
}

- (NSBezierPath *)pathForRadius:(float)aRadius inRect:(NSRect)rect
{
    NSBezierPath    *path;
    
    path = [[NSBezierPath allocWithZone:nil] init];
    if (aRadius == 0.0) {
        [path appendBezierPathWithRect:(NSRect){{rect.origin.x + width / 2.0, rect.origin.y + width / 2.0}, {rect.size.width - width, rect.size.height - width}}];
    } else {
        [path moveToPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height / 2.0 - width / 2.0}];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0} radius:aRadius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + rect.size.height - width / 2.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0} radius:aRadius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + rect.size.width - width / 2.0, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} radius:aRadius];
        [path appendBezierPathWithArcFromPoint:(NSPoint){rect.origin.x + width / 2.0, rect.origin.y + width / 2.0} toPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - width / 2.0} radius:aRadius];
        [path closePath];
    }
    
    return path;
}

- (NSBezierPath *)clippingPathForRect:(NSRect)rect
{
    return [self pathForRadius:radius inRect:rect];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    NSInteger            x;
    
    for (x = 1; x <= (const NSInteger)rint(width); x++) {
        float    map;
        float    color;
        
        map = (M_PI / width);
        color = sin(((float)x - 1.0) * map / 2.0) * 0.25;
        
        [renderer setAngle:180.0];
        [renderer setColor:[NSColor colorWithCalibratedWhite:0.666666 - color alpha:1.0]];
        [renderer setHighlightColor:[NSColor colorWithCalibratedWhite:0.75 + color alpha:1.0]];
        [renderer setShadowColor:[NSColor colorWithCalibratedWhite:0.333 - color alpha:1.0]];
        [renderer renderPath:[self pathForRadius:radius - (float)x inRect:rect]];
        if (x > 1) rect = NSInsetRect(rect, 1.0, 1.0);
    }

    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    renderer = [[AJREmbossRenderer alloc] init];
    [renderer setError:0.1];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"width"]) {
        width = [coder decodeFloatForKey:@"width"];
        radius = [coder decodeFloatForKey:@"radius"];
    } else {
        [coder decodeValueOfObjCType:@encode(float) at:&width];
        [coder decodeValueOfObjCType:@encode(float) at:&radius];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeFloat:width forKey:@"width"];
        [coder encodeFloat:radius forKey:@"radius"];
    } else {
        [coder encodeValueOfObjCType:@encode(float) at:&width];
        [coder encodeValueOfObjCType:@encode(float) at:&radius];
    }
}

@end
