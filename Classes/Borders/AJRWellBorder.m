/*
 AJRWellBorder.m
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

#import "AJRWellBorder.h"

static NSColor *_cachedColors[9];

@implementation AJRWellBorder
{
	NSColor *_colors[9];
}

+ (void)load {
    [AJRBorder registerBorder:self];
}

+ (void)initialize {
    _cachedColors[0] = [NSColor colorWithCalibratedWhite:0.95 alpha:1.00];
    _cachedColors[1] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.03];
    _cachedColors[2] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.09];
    _cachedColors[3] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.18];
    _cachedColors[4] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.24];
    _cachedColors[5] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.11];
    _cachedColors[6] = [NSColor colorWithCalibratedWhite:0.00 alpha:0.30];
    _cachedColors[7] = [NSColor colorWithCalibratedWhite:0.90 alpha:1.00];
    _cachedColors[8] = [NSColor colorWithCalibratedWhite:1.00 alpha:1.00];
}

+ (NSString *)name {
    return @"Well";
}

- (id)init {
	if ((self = [super init])) {
        for (NSInteger x = 0; x < 9; x++) {
			_colors[x] = _cachedColors[x];
		}
	}
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (NSRect)contentRectForRect:(NSRect)rect {
    rect = [super contentRectForRect:rect];
    
    rect.origin.x += 3;
    rect.origin.y += 3;
    rect.size.width -= 6.0;
    rect.size.height -= 6.0;
    
    return rect;
}

- (void)buildOutlineIntoPath:(NSBezierPath *)aPath rect:(NSRect)rect radius:(float)radius {
    float l = rect.origin.x + 0.5;
    float r = rect.origin.x + rect.size.width - 1.0;
    float t = rect.origin.y + rect.size.height - 1.0;
    float b = rect.origin.y + 0.5;
    float lrm = (l + r) / 2.0;
    float tbm = (t + b) / 2.0;
    
    [aPath removeAllPoints];
    [aPath moveToPoint:(NSPoint){l, tbm}];
    [aPath appendBezierPathWithArcFromPoint:(NSPoint){l, t} toPoint:(NSPoint){lrm, t} radius:radius];
    [aPath appendBezierPathWithArcFromPoint:(NSPoint){r, t} toPoint:(NSPoint){r, tbm} radius:radius];
    [aPath appendBezierPathWithArcFromPoint:(NSPoint){r, b} toPoint:(NSPoint){lrm, b} radius:radius];
    [aPath appendBezierPathWithArcFromPoint:(NSPoint){l, b} toPoint:(NSPoint){l, tbm} radius:radius];
    [aPath closePath];
}

- (NSBezierPath *)clippingPathForRect:(NSRect)rect {
    NSBezierPath *path = [[NSBezierPath alloc] init];
    
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 1.5, rect.origin.y +  1.5}, {rect.size.width - 3.0, rect.size.height - 3.0}} radius:5.5];
    
    return path;
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    [_colors[0] set];
    [[self clippingPathForRect:rect] fill];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    NSBezierPath *path = [[NSBezierPath alloc] init];
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 5.0, rect.origin.y +  4.0}, {rect.size.width - 10.0, rect.size.height - 11.0}} radius:5];
    [_colors[1] set];
    [path stroke];
    
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 4.0, rect.origin.y +  3.0}, {rect.size.width - 8.0, rect.size.height - 9.0}} radius:5];
    [_colors[2] set];
    [path stroke];
    
    [context saveGraphicsState];
    NSRectClip((NSRect){{rect.origin.x, rect.origin.y + rect.size.height - 10.0}, {rect.size.width, 10.0}});
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 4.0, rect.origin.y +  2.0}, {rect.size.width - 8.0, rect.size.height - 7.0}} radius:5];
    [_colors[3] set];
    [path stroke];
    [context restoreGraphicsState];
    
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 3.0, rect.origin.y +  2.0}, {rect.size.width - 6.0, rect.size.height - 6.0}} radius:6];
    [_colors[4] set];
    [path stroke];
    
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 2.0, rect.origin.y +  0.0}, {rect.size.width - 4.0, rect.size.height - 4.0}} radius:6];
    [_colors[5] set];
    [path stroke];
    
    [_colors[6] set];
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 2.0, rect.origin.y +  1.0}, {rect.size.width - 4.0, rect.size.height - 4.0}} radius:6.5];
    [path stroke];
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 1.0, rect.origin.y +  1.0}, {rect.size.width - 2.0, rect.size.height - 4.0}} radius:6.5];
    [path stroke];
    
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 0.0, rect.origin.y +  0.0}, {rect.size.width - 0.0, rect.size.height - 0.0}} radius:6];
    [_colors[7] set];
    [path stroke];
    
    [path setLineWidth:2.0];
    [self buildOutlineIntoPath:path rect:(NSRect){{rect.origin.x + 1.5, rect.origin.y +  1.5}, {rect.size.width - 3.0, rect.size.height - 3.0}} radius:4.5];
    [_color set];
    [path stroke];
    

    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}

- (void)setColor:(NSColor *)aColor {
    if (_color != aColor) {
        CGFloat h, s, b, a;
        
        _color = aColor;
        
        [[_color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
        _colors[7] = [NSColor colorWithCalibratedHue:h saturation:s brightness:b * 0.9 alpha:a];
        
        [self didUpdate];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
		for (NSInteger x = 0; x < 9; x++) {
			_colors[x] = _cachedColors[x];
		}
		_color = [coder decodeObjectForKey:@"color"];
		if (!_color) {
			[self setColor:_cachedColors[8]];
		}
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_color forKey:@"color"];
}

@end
