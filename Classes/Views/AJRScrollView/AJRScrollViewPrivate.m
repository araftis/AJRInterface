
#import "AJRScrollViewPrivate.h"

#import "NSImage+Extensions.h"

@implementation _AJRSVPopUpButton

+ (Class)cellClass
{
    return [_AJRSVPopUpButtonCell class];
}

@end

@implementation _AJRSVPopUpButtonCell

+ (NSImage *)backgroundImage
{
    static NSImage        *image = nil;
    
    if (!image) {
        NSString     *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Scroll View Pop Up" ofType:@"tiff"];
        if (path) {
            image = [[NSImage alloc] initWithContentsOfFile:path];
        }
    }
    
    return image;
}

+ (NSImage *)backgroundImageD
{
    static NSImage        *image = nil;
    
    if (!image) {
        NSString     *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Scroll View Pop Up D" ofType:@"tiff"];
        if (path) {
            image = [[NSImage alloc] initWithContentsOfFile:path];
        }
    }
    
    return image;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSDictionary    *attributes;
    
    [super drawWithFrame:cellFrame inView:controlView];
    if ([NSApp isActive] && [NSApp keyWindow] == [controlView window]) {
        [[[self class] backgroundImage] ajr_drawAtPoint:(NSPoint){cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height} operation:NSCompositingOperationCopy];
    } else {
        [[[self class] backgroundImageD] ajr_drawAtPoint:(NSPoint){cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height} operation:NSCompositingOperationCopy];
    }
    
    attributes = @{NSFontAttributeName: [self font],
                   NSForegroundColorAttributeName: [NSColor blackColor],
                   };
    cellFrame.origin.x += 8.0;
    cellFrame.size.width -= 23.0;
    cellFrame.origin.y += 1.0;
    cellFrame.size.height -= 1.0;
    [[self title] drawInRect:cellFrame withAttributes:attributes];
}

@end
