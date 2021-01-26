
#import "AJRBezelInBorder.h"

static NSColor    *color1 = nil;
static NSColor    *color2;
static NSColor    *color3;
static NSColor    *color4;

@implementation AJRBezelInBorder

+ (void)load
{
    [AJRBorder registerBorder:self];
}

+ (void)initialize
{
    if (color1 == nil) {
        color1 = [NSColor colorWithCalibratedWhite:124.0 / 255.0 alpha:0.5];
        color2 = [NSColor colorWithCalibratedWhite:195.0 / 255.0 alpha:0.5];
        color3 = [NSColor colorWithCalibratedWhite:240.0 / 255.0 alpha:0.5];
        color4 = [NSColor colorWithCalibratedWhite:221.0 / 255.0 alpha:0.5];
    }
}

+ (NSString *)name
{
    return @"Bezeled In";
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    rect = [super contentRectForRect:rect];
    
    rect.origin.x += 2;
    rect.origin.y += 1;
    rect.size.width -= 4.0;
    rect.size.height -= 4.0;
    
    return rect;
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    NSRect titleBaseRect = rect;
    rect = [super contentRectForRect:rect];
    
    [color1 set];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - 0.5} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.5}];
    
    [color2 set];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - 1.5} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 1.5}];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + 0.5, rect.origin.y} toPoint:(NSPoint){rect.origin.x + 0.5, rect.origin.y + rect.size.height - 1.0}];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + rect.size.width - 0.5, rect.origin.y} toPoint:(NSPoint){rect.origin.x + rect.size.width - 0.5, rect.origin.y + rect.size.height - 1.0}];
    
    [color3 set];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + 1.0, rect.origin.y + rect.size.height - 2.5} toPoint:(NSPoint){rect.origin.x + rect.size.width - 2.0, rect.origin.y + rect.size.height - 2.5}];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + 1.5, rect.origin.y + 1.0} toPoint:(NSPoint){rect.origin.x + 1.5, rect.origin.y + rect.size.height - 2.0}];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + rect.size.width - 1.5, rect.origin.y + 1.0} toPoint:(NSPoint){rect.origin.x + rect.size.width - 1.5, rect.origin.y + rect.size.height - 2.0}];
    
    [color4 set];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + 1.0, rect.origin.y + 0.5} toPoint:(NSPoint){rect.origin.x + rect.size.width - 2.0, rect.origin.y +  0.5}];

    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:titleBaseRect] inView:controlView];
    }
}

@end
