/*
 AJRImageCell.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
