/*
 _AJRCalendarPrintView.m
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

#import "_AJRCalendarPrintView.h"

#import "AJRCalendarRenderer.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>

@implementation _AJRCalendarPrintView

- (id)initWithRenderer:(AJRCalendarRenderer *)renderer
{
    if ((self = [super initWithFrame:NSZeroRect])) {
        _renderer = renderer;
    }
    return self;
}


#pragma mark Properties

- (void)setRenderer:(AJRCalendarRenderer *)renderer
{
    if (_renderer != renderer) {
        _renderer = renderer;
    }
}

#pragma mark NSView

- (void)drawRect:(NSRect)rect
{
    NSRect        headerRect = [_renderer rectForHeaderInRect:[self bounds]];
    
    if (headerRect.size.height != 0.0) {
        CGFloat            scale = 0.75;
        NSRect            rect = [self rectForPage:1];
        CGContextRef    context = [[NSGraphicsContext currentContext] CGContext];
        NSRect            bounds;
        NSRect            bodyRect;
        
        bounds = (NSRect){NSZeroPoint, {rect.size.width * (1.0/scale), rect.size.height * (1.0/scale)}};
        
        //AJRPrintf(@"%C: Printing, rect: %R, bounds: %R\n", self, rect, bounds);
        
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
        CGContextScaleCTM(context, scale, scale);
        
        headerRect = [_renderer rectForHeaderInRect:bounds];
        bodyRect = bounds;
        bodyRect.size.height = headerRect.origin.y - bounds.origin.y - 3.0;

        [_renderer drawHeaderInRect:rect bounds:headerRect];
        [_renderer drawBodyInRect:rect bounds:bodyRect];
        
        headerRect.origin.y -= 4.0;
        headerRect.size.height = 4.0;
        [[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] set];
        //[[NSColor redColor] set];
        NSFrameRect(headerRect);
        
        headerRect.origin.y += 1.0;
        headerRect.size.height = 1.0;
        //[[NSColor blueColor] set];
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
        NSFrameRect(headerRect);
        
        headerRect.origin.y += 1.0;
        //[[NSColor greenColor] set];
        [[NSColor colorWithCalibratedWhite:0.91 alpha:1.0] set];
        NSFrameRect(headerRect);        
    }
    if (![_renderer bodyShouldScroll]) {
        CGFloat            scale = 0.75, rscale = 1.0 / scale;
        NSRect            rect = [self rectForPage:1];
        NSRect            bounds = (NSRect){NSZeroPoint, {rect.size.width * rscale, rect.size.height * rscale}};
        CGContextRef    context = [[NSGraphicsContext currentContext] CGContext];
        
        //AJRPrintf(@"%C: Printing, rect: %R, bounds: %R\n", self, rect, bounds);
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
        CGContextScaleCTM(context, scale, scale);
        
        // Calendars don't normally have border, so we inset by one when printing, so that the 
        // calendar can draw a border if it desires.
        bounds = NSInsetRect(bounds, 1, 1);
        [_renderer drawBodyInRect:bounds bounds:bounds];
    }
}

#pragma mark NSView - Printing

- (BOOL)knowsPageRange:(NSRangePointer)range 
{
    range->location = 1;
    range->length = 1;
    
    return YES;
}

- (NSRect)rectForPage:(NSInteger)page 
{
    NSPrintOperation    *operation = [NSPrintOperation currentOperation];
    NSPrintInfo            *printInfo = [operation printInfo];
    NSSize                pageSize = [printInfo paperSize];
    NSRect                rect;
    
    rect.origin.x = [printInfo leftMargin];
    rect.origin.y = [printInfo bottomMargin];
    rect.size.width = pageSize.width - ([printInfo leftMargin] + [printInfo rightMargin]);
    rect.size.height = pageSize.height - ([printInfo topMargin] + [printInfo bottomMargin]);
    
    // And make sure we, and our view is of the correct size
    [[self window] setFrame:(NSRect){NSZeroPoint, rect.size} display:YES];
    
    return rect;
}

- (void)printOperationComplete
{
    [self window];
}

@end
