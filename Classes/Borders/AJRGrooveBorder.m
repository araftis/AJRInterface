/*
AJRGrooveBorder.m
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
