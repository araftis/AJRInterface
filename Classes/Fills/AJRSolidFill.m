/*
 AJRSolidFill.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import "AJRSolidFill.h"

@implementation AJRSolidFill

+ (void)load
{
    [AJRFill registerFill:self];
}

+ (NSString *)name
{
    return @"Solid Fill";
}

- (id)init
{
    self = [super init];
    
    _color = [NSColor whiteColor];
    
    return self;
}


@synthesize color = _color;
@synthesize unfocusedColor = _unfocusedColor;

- (void)setColor:(NSColor *)color
{
    if (_color != color) {
        [self willUpdate];
        _color = color;
        [self didUpdate];
    }
}

- (void)setUnfocusedColor:(NSColor *)color
{
    if (_unfocusedColor != color) {
        [self willUpdate];
        _unfocusedColor = color;
        [self didUpdate];
    }
}

- (BOOL)isViewFocused:(NSView *)view
{
    if ([[view window] firstResponder] == view) return YES;
    if ([view superview]) return [self isViewFocused:[view superview]];
    return NO;
}

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView
{
    if (_unfocusedColor) {
        if ([self isViewFocused:controlView]) {
            [_color set];
        } else {
            [_unfocusedColor set];
        }
    } else {
        [_color set];
    }
    [path fill];
}

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView
{
    if (_unfocusedColor) {
        if ([self isViewFocused:controlView] && [[controlView window] isKeyWindow] && [NSApp isActive]) {
            [_color set];
        } else {
            [_unfocusedColor set];
        }
    } else {
        [_color set];
    }
    NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
}

- (BOOL)isOpaque
{
    return [_color alphaComponent] == 1.0;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"color"]) {
        _color = [coder decodeObjectForKey:@"color"];
        if ([coder containsValueForKey:@"unfocusedColor"]) {
            _unfocusedColor = [coder decodeObjectForKey:@"unfocusedColor"];
        }
    } else {
        _color = [coder decodeObject];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_color forKey:@"color"];
        [coder encodeObject:_unfocusedColor forKey:@"unfocusedColor"];
    } else {
        [coder encodeObject:_color];
    }
}

@end
