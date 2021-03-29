/*
AJRScrollViewPrivate.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
