/*
 AJRDropShadowBorder.m
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

#import "AJRDropShadowBorder.h"

@implementation AJRDropShadowBorder

+ (void)load {
    [AJRBorder registerBorder:self];
}

+ (NSString *)name {
    return @"Drop Shadow";
}

- (id)init {
    if ((self = [super init])) {
        _shallow = NO;
        _clip = YES;
        [self setRadius:0.0];
    }
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (NSRect)titleRectForRect:(NSRect)rect {
    rect = [super titleRectForRect:rect];
    
    switch ([self titleAlignment]) {
        case NSTextAlignmentJustified:
        case NSTextAlignmentNatural:
        case NSTextAlignmentLeft:
            rect.origin.x += 5.0;
            break;
        case NSTextAlignmentCenter:
            break;
        case NSTextAlignmentRight:
            rect.origin.x -= 5.0;
            break;
    }
    
    return rect;
}

- (NSRect)contentRectForRect:(NSRect)rect {
    rect = [super contentRectForRect:rect];
    
    if (_shallow) {
        rect.origin.x += 5.0;
        rect.origin.y += 10.0;
        rect.size.width -= 10.0;
        rect.size.height -= 10.0;
    } else {
        rect.origin.x += 10;
        rect.origin.y += 18.0;
        rect.size.width -= 20.0;
        rect.size.height -= 20.0;
    }
    
    return rect;
}

- (NSBezierPath *)pathForRect:(NSRect)rect {
    NSBezierPath *path;
    path = [[NSBezierPath allocWithZone:nil] init];
    [path appendBezierPathWithRoundedRect:[self contentRectForRect:rect] xRadius:_radius yRadius:_radius];
    return path;
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    NSShadow        *shadow;
    NSColor            *color = [NSColor whiteColor];
    NSBezierPath    *clippingPath;
    NSBezierPath    *path;
    
    [NSGraphicsContext saveGraphicsState];

    shadow = [[NSShadow alloc] init];
    if (_shallow) {
        [shadow setShadowOffset:NSMakeSize(0.0f, -3.0f)];
        [shadow setShadowBlurRadius:5.0f];
    } else {
        [shadow setShadowOffset:NSMakeSize(0.0f, -5.0f)];        
        [shadow setShadowBlurRadius:10.0f];
    }

    path = [self pathForRect:rect];

    clippingPath = [[NSBezierPath alloc] init];
    [clippingPath setWindingRule:NSWindingRuleEvenOdd];
    [clippingPath appendBezierPathWithRect:NSInsetRect(rect, -20.0, -20.0)];
    [clippingPath appendBezierPath:path];
    [clippingPath addClip];
    
    [color set];
    [shadow set];
    [path fill];

    [NSGraphicsContext restoreGraphicsState];
}


- (NSBezierPath *)clippingPathForRect:(NSRect)rect {
    return [self pathForRect:rect];
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    if ([self titlePosition] != NSNoTitle) {
        //[[NSColor redColor] set];
        //NSFrameRect([self titleRectForRect:rect]);
        [[self titleCell] drawInteriorWithFrame:[self titleRectForRect:rect] inView:controlView];
    }
}

- (void)setRadius:(CGFloat)aRadius {
    if (_radius != aRadius) {
        [self willUpdate];
        _radius = aRadius;
        [self didUpdate];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"shallow"]) {
            _shallow = [coder decodeBoolForKey:@"shallow"];
            _clip = [coder decodeBoolForKey:@"clip"];
            _radius = [coder decodeFloatForKey:@"radius"];
        } else {
            [coder decodeValueOfObjCType:@encode(BOOL) at:&_shallow];
            [coder decodeValueOfObjCType:@encode(BOOL) at:&_clip];
            [coder decodeValueOfObjCType:@encode(CGFloat) at:&_radius];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeBool:_shallow forKey:@"shallow"];
        [coder encodeBool:_clip forKey:@"clip"];
        [coder encodeFloat:_radius forKey:@"radius"];
    } else {
        [coder encodeValueOfObjCType:@encode(BOOL) at:&_shallow];
        [coder encodeValueOfObjCType:@encode(BOOL) at:&_clip];
        [coder encodeValueOfObjCType:@encode(CGFloat) at:&_radius];
    }
}

@end
