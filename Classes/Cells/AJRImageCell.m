
#import "AJRImageCell.h"

@implementation AJRImageCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSShadow *shadow = [[NSShadow alloc] init];
    NSImage *image = [self image];
    
    cellFrame.size.width -= 10.0;
    cellFrame.size.height -= 10.0;
    cellFrame.origin.x += 5.0;
    cellFrame.origin.y += 7.0;

    [NSGraphicsContext saveGraphicsState];
    [shadow setShadowColor:[[NSColor lightGrayColor] colorWithAlphaComponent:1.0]];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowOffset:(NSSize){0.0, -3.0}];
    [shadow set];
    [[NSColor whiteColor] set];
    NSRectFill(cellFrame);
    [NSGraphicsContext restoreGraphicsState];
    
    [[NSColor lightGrayColor] set];
    NSFrameRect(cellFrame);
    
    if (image) {
        CGFloat scale = 1.0;
        NSRect imageRect;
        NSSize imageSize = [image size];
        
        cellFrame.size.width -= 10.0;
        cellFrame.size.height -= 10.0;
        cellFrame.origin.x += 5.0;
        cellFrame.origin.y += 5.0;
        
        if (imageSize.height > cellFrame.size.height) {
            if (imageSize.height > imageSize.width) {
                scale = cellFrame.size.height / imageSize.height;
            } else {
                scale = cellFrame.size.height / imageSize.width;
            }
        }
        if (imageSize.width * scale > cellFrame.size.width) {
            if (imageSize.height > imageSize.width) {
                scale *= cellFrame.size.width / imageSize.height;
            } else {
                scale *= cellFrame.size.width / imageSize.width;
            }
        }
        
        imageRect = (NSRect){{cellFrame.origin.x, cellFrame.origin.y}, {round(imageSize.width * scale), round(imageSize.height * scale)}};
        if (imageRect.size.height < cellFrame.size.height) {
            imageRect.origin.y += round((cellFrame.size.height - imageRect.size.height) / 2.0);
        }
        if (imageRect.size.width < cellFrame.size.width) {
            imageRect.origin.x += round((cellFrame.size.width - imageRect.size.width) / 2.0);
        }
        [image drawInRect:imageRect fromRect:(NSRect){{0.0, 0.0}, imageSize} operation:NSCompositingOperationSourceOver fraction:1.0];
    }
}

@end
