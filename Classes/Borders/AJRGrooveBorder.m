
#import "AJRGrooveBorder.h"

@implementation AJRGrooveBorder

+ (void)load
{
    [AJRBorder registerBorder:self];
}

+ (NSString *)name
{
    return @"Groove";
}

- (NSRect)contentRectForRect:(NSRect)rect
{
    rect = [super contentRectForRect:rect];
    
    rect.origin.x += 2;
    rect.origin.y += 2;
    rect.size.width -= 4;
    rect.size.height -= 4;
    
    return rect;
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView
{
    NSBezierPath    *path;
    NSRect            titleBaseRect = rect;

    rect = [super contentRectForRect:rect];
    
    [[NSColor darkGrayColor] set];
    path = [[NSBezierPath alloc] init];
    [path moveToPoint:rect.origin];
    [path relativeLineToPoint:(NSPoint){0.0, rect.size.height}];
    [path relativeLineToPoint:(NSPoint){rect.size.width, 0.0}];
    [path moveToPoint:(NSPoint){rect.origin.x + 1.0, rect.origin.y + 1.0}];
    [path relativeLineToPoint:(NSPoint){rect.size.width - 2.0, 0.0}];
    [path relativeLineToPoint:(NSPoint){0.0, rect.size.height - 2.0}];
    [path stroke];
    
    [[NSColor whiteColor] set];
    NSFrameRect((NSRect){{rect.origin.x + 1.0, rect.origin.y}, {rect.size.width - 1.0, rect.size.height - 1.0}});
    
    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:titleBaseRect] inView:controlView];
    }
}

@end
