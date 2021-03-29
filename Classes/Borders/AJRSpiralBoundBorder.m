/*
AJRSpiralBoundBorder.m
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

#import "AJRSpiralBoundBorder.h"

#import "NSImage+Extensions.h"

@implementation AJRSpiralBoundBorder

static NSImage *left = nil;
static NSImage *right;
static NSImage *top;
static NSImage *bottom;

+ (void)load {
    [AJRBorder registerBorder:self];
}

+ (void)initialize {
    if (left == nil) {
        NSBundle        *bundle = [NSBundle bundleForClass:[self class]];
        NSString        *path;
        
        path = [bundle pathForResource:@"RingLeft" ofType:@"tiff"];
        if (path) left = [[NSImage alloc] initWithContentsOfFile:path];
        path = [bundle pathForResource:@"RingRight" ofType:@"tiff"];
        if (path) right = [[NSImage alloc] initWithContentsOfFile:path];
        path = [bundle pathForResource:@"RingTop" ofType:@"tiff"];
        if (path) top = [[NSImage alloc] initWithContentsOfFile:path];
        path = [bundle pathForResource:@"RingBottom" ofType:@"tiff"];
        if (path) bottom = [[NSImage alloc] initWithContentsOfFile:path];
    }
}

+ (NSString *)name {
    return @"Spiral Bound";
}

- (id)init {
    self = [super init];
    
    edge = NSViewMinXMargin;
    
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (void)setEdge:(NSUInteger)anEdge {
    if (edge != anEdge) {
        edge = anEdge;
        [self didUpdate];
    }
}

- (NSUInteger)edge {
    return edge;
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    NSInteger        x;
    NSInteger        count;
    float        offset;
    
    [super drawBorderForegroundInRect:rect clippedToRect:clippingRect controlView:controlView];
    
    if (edge & NSViewMinXMargin) {
        count = floor((rect.size.height - 40) / 10.0);
        offset = rect.origin.y + rect.size.height / 2.0 - (((float)count / 2) * 10.0);
        for (x = 0; x < count; x++) {
            [left ajr_drawAtPoint:(NSPoint){3.0, offset + (float)x * 10.0} operation:NSCompositingOperationSourceOver];
        }
    }
    if (edge & NSViewMaxXMargin) {
        count = floor((rect.size.height - 40) / 10.0);
        offset = rect.origin.y + rect.size.height / 2.0 - (((float)count / 2) * 10.0);
        for (x = 0; x < count; x++) {
            [right ajr_drawAtPoint:(NSPoint){rect.size.width - 22.0, offset + (float)x * 10.0} operation:NSCompositingOperationSourceOver];
        }
    }
    if (edge & NSViewMinYMargin) {
        count = floor((rect.size.width - 40) / 10.0);
        offset = rect.origin.x + rect.size.width / 2.0 - (((float)count / 2) * 10.0);
        for (x = 0; x < count; x++) {
            [bottom ajr_drawAtPoint:(NSPoint){offset + (float)x * 10.0, 7.0} operation:NSCompositingOperationSourceOver];
        }
    }
    if (edge & NSViewMaxYMargin) {
        count = floor((rect.size.width - 40) / 10.0);
        offset = rect.origin.x + rect.size.width / 2.0 - (((float)count / 2) * 10.0);
        for (x = 0; x < count; x++) {
            [top ajr_drawAtPoint:(NSPoint){offset + (float)x * 10.0, rect.size.height - 18.0} operation:NSCompositingOperationSourceOver];
        }
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"edge"]) {
        edge = [coder decodeIntForKey:@"edge"];
    } else {
        [coder decodeValueOfObjCType:@encode(NSUInteger) at:&edge];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeInteger:edge forKey:@"edge"];
    } else {
        [coder encodeValueOfObjCType:@encode(NSUInteger) at:&edge];
    }
}

@end
