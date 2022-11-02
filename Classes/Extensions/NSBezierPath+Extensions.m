/*
 NSBezierPath+Extensions.m
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

#import "NSBezierPath+Extensions.h"

#import <AJRInterfaceFoundation/AJRBezierPathP.h>
#import <AJRInterfaceFoundation/AJRPathEnumerator.h>
#import <AJRInterfaceFoundation/AJRXMLCoder+Extensions.h>

#import <AJRInterface/AJRInterface.h>

static inline CGLineCap AJRLineCapStyleToCGLineCap(NSLineCapStyle lineCapStyle) {
    switch (lineCapStyle) {
        case NSLineCapStyleButt:   return kCGLineCapButt;
        case NSLineCapStyleRound:  return kCGLineCapRound;
        case NSLineCapStyleSquare: return kCGLineCapSquare;
    }
}

static inline CGLineJoin AJRLineLineStyleToCGLineCap(NSLineJoinStyle lineJoinStyle) {
    switch (lineJoinStyle) {
        case NSLineJoinStyleBevel: return kCGLineJoinBevel;
        case NSLineJoinStyleMiter: return kCGLineJoinMiter;
        case NSLineJoinStyleRound: return kCGLineJoinRound;
    }
}

static NSTextView *_textView = nil;

@implementation NSBezierPath (AJRInterfaceExtensions)

- (void)appendBezierPathWithString:(NSString *)string font:(NSFont *)font {
    NSRange range;
    NSLayoutManager *lm;
    CGGlyph *glyphs;
    NSSize advancement;
    NSInteger x;
    NSPoint where = [self currentPoint];
    
    if (_textView == nil) {
        _textView = [[NSTextView alloc] init];
        [_textView setRichText:NO];
        [[_textView layoutManager] setBackgroundLayoutEnabled:NO];
    }
    
    [_textView setString:string];
    [_textView setFont:font];
    
    lm = [_textView layoutManager];
    range = [lm glyphRangeForCharacterRange:(NSRange){0, [string length]} actualCharacterRange:NULL];
    
    glyphs = (CGGlyph *)NSZoneMalloc(nil, sizeof(CGGlyph) * (range.length * 2));
    [lm getGlyphsInRange:range glyphs:glyphs properties:NULL characterIndexes:NULL bidiLevels:NULL];
    
    for (x = 0; x < range.length; x++) {
        [self appendBezierPathWithCGGlyph:glyphs[x] inFont:font];
        advancement = [font advancementForGlyph:glyphs[x]];
        where.x += advancement.width;
        where.y += advancement.height;
        [self moveToPoint:where];
    }
    
    NSZoneFree(nil, glyphs);
}

- (void)appendBezierPathWithAttributedString:(NSAttributedString *)string {
	NSLayoutManager *lm;
	
	if (_textView == nil) {
		_textView = [[NSTextView alloc] init];
		[_textView setRichText:NO];
		[[_textView layoutManager] setBackgroundLayoutEnabled:NO];
	}
	
	[[_textView textStorage] replaceCharactersInRange:(NSRange){0, 0} withAttributedString:string];
	
	lm = [_textView layoutManager];
	
	[[_textView textStorage] enumerateAttribute:NSFontAttributeName inRange:(NSRange){0, [string length]} options:0 usingBlock:^(NSFont *font, NSRange subrange, BOOL *stop) {
		NSRange range = [lm glyphRangeForCharacterRange:subrange actualCharacterRange:NULL];
		NSPoint where = [self currentPoint];
		NSSize advancement;
		
		CGGlyph *glyphs = (CGGlyph *)NSZoneMalloc(nil, sizeof(CGGlyph) * (range.length * 2));
		[lm getGlyphsInRange:range glyphs:glyphs properties:NULL characterIndexes:NULL bidiLevels:NULL];
		
		for (NSInteger x = 0; x < range.length; x++) {
			[self appendBezierPathWithCGGlyph:glyphs[x] inFont:font];
			advancement = [font advancementForGlyph:glyphs[x]];
			where.x += advancement.width;
			where.y += advancement.height;
			[self moveToPoint:where];
		}
		
		NSZoneFree(nil, glyphs);
	}];
}

+ (void)drawString:(NSString *)string font:(NSFont *)font at:(NSPoint)point {
    NSBezierPath    *path = [[NSBezierPath alloc] init];
    
    [path moveToPoint:point];
    [path appendBezierPathWithString:string font:font];
    [path fill];
}

+ (NSBezierPath *)bezierPathWithCrossedRect:(NSRect)rect {
    NSBezierPath    *path = [[NSBezierPath alloc] init];
    [path appendBezierPathWithCrossedRect:rect];
    return path;
}

- (void)appendBezierPathWithCrossedRect:(NSRect)rect {
    [self moveToPoint:rect.origin];
    [self relativeLineToPoint:(NSPoint){0.0, rect.size.height}];
    [self relativeLineToPoint:(NSPoint){rect.size.width, 0.0}];
    [self relativeLineToPoint:(NSPoint){0.0, -rect.size.height}];
    [self closePath];
    [self moveToPoint:rect.origin];
    [self relativeLineToPoint:(NSPoint){rect.size.width, rect.size.height}];
    [self moveToPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height}];
    [self relativeLineToPoint:(NSPoint){rect.size.width, -rect.size.height}];
}

- (void)appendBezierPathWithCrossCenteredAt:(NSPoint)center legSize:(NSSize)legSize andLegThickness:(NSSize)legThickness {
	[self moveToPoint:(NSPoint){center.x - legThickness.width, center.y - legThickness.height}];
	[self lineToPoint:(NSPoint){center.x - legSize.width, center.y - legThickness.height}];
	[self lineToPoint:(NSPoint){center.x - legSize.width, center.y + legThickness.height}];
	[self lineToPoint:(NSPoint){center.x - legThickness.width, center.y + legThickness.height}];
	[self lineToPoint:(NSPoint){center.x - legThickness.width, center.y + legSize.height}];
	[self lineToPoint:(NSPoint){center.x + legThickness.width, center.y + legSize.height}];
	[self lineToPoint:(NSPoint){center.x + legThickness.width, center.y + legThickness.height}];
	[self lineToPoint:(NSPoint){center.x + legSize.width, center.y + legThickness.height}];
	[self lineToPoint:(NSPoint){center.x + legSize.width, center.y - legThickness.height}];
	[self lineToPoint:(NSPoint){center.x + legThickness.width, center.y - legThickness.height}];
	[self lineToPoint:(NSPoint){center.x + legThickness.width, center.y - legSize.height}];
	[self lineToPoint:(NSPoint){center.x - legThickness.width, center.y - legSize.height}];
	[self closePath];
}

- (void)addPathToContext:(CGContextRef)context {
    NSInteger x, max = [self elementCount];
    NSPoint points[4];
    CGFloat phase, lengths[20];
    NSInteger count;
    
    CGContextBeginPath(context);
    for (x = 0; x < max; x++) {
        switch ([self elementAtIndex:x associatedPoints:points]) {
            case NSBezierPathElementMoveTo:
                CGContextMoveToPoint(context, points[0].x, points[0].y);
                break;
            case NSBezierPathElementLineTo:
                CGContextAddLineToPoint(context, points[0].x, points[0].y);
                break;
            case NSBezierPathElementCurveTo:
                CGContextAddCurveToPoint(context, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
                break;
            case NSBezierPathElementClosePath:
                CGContextClosePath(context);
                break;
        }
    }
    
    CGContextSetLineWidth(context, [self lineWidth]);
    CGContextSetLineCap(context, AJRLineCapStyleToCGLineCap([self lineCapStyle]));
    CGContextSetLineJoin(context, AJRLineLineStyleToCGLineCap([self lineJoinStyle]));
    [self getLineDash:lengths count:&count phase:&phase];
    CGContextSetLineDash(context, phase, lengths, count);
    CGContextSetMiterLimit(context, [self miterLimit]);
    CGContextSetFlatness(context, [self flatness]);
}

- (NSBezierPath *)bezierPathFromStrokedPath {
    CGContextRef context = AJRHitTestContext();
    CGPathRef strokedPath;
    NSBezierPath *newPath;
    
    [self addPathToContext:context];
    CGContextReplacePathWithStrokedPath(context);
    strokedPath = CGContextCopyPath(context);
    newPath = [[NSBezierPath alloc] init];
    CGPathApply(strokedPath, (__bridge void *)newPath, AJRPathToBezierIterator);
    CGPathRelease(strokedPath);
    
    return newPath;
}

#pragma mark - Enumeration

- (AJRPathEnumerator *)pathEnumerator {
	// Yes, a little bit hinky, but the enumerator is designed to only use API's that're public on NSBezierPath, so this is a safe cast.
    return [[AJRPathEnumerator allocWithZone:nil] initWithBezierPath:(AJRBezierPath *)self];
}

- (void)enumerateWithBlock:(void (^)(NSBezierPathElement element, CGPoint *points, BOOL *stop))enumerationBlock {
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    NSBezierPathElement *element;
    NSPoint points[4];
    BOOL stop = NO;
    
    while ((element = (NSBezierPathElement *)[enumerator nextElementWithPoints:points]) && !stop) {
        enumerationBlock(*element, points, &stop);
    }
}

- (void)enumerateFlattenedPathWithBlock:(void (^)(AJRLine lineSegment, BOOL *stop))enumerationBlock {
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    AJRLine *line;
    BOOL stop = NO;
    
    while ((line = [enumerator nextLineSegment]) && !stop) {
        enumerationBlock(*line, &stop);
    }
}

#pragma mark - AJRXMLCoding

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if (!self.isEmpty) {
        [self enumerateWithBlock:^(NSBezierPathElement element, NSPoint *points, BOOL *stop) {
            switch (element) {
                case NSBezierPathElementMoveTo: {
                    NSPoint point = points[0];
                    [coder encodePoint:point forKey:@"moveTo"];
                    break;
                }
                case NSBezierPathElementLineTo: {
                    NSPoint point = points[0];
                    [coder encodePoint:point forKey:@"lineTo"];
                    break;
                }
                case NSBezierPathElementClosePath:
                    [coder encodeGroupForKey:@"closePath" usingBlock:^{
                    }];
                    break;
                case NSBezierPathElementCurveTo: {
                    NSPoint point = points[0];
                    NSPoint pointC0 = points[1];
                    NSPoint pointC1 = points[2];
                    [coder encodeGroupForKey:@"curveTo" usingBlock:^{
                        [coder encodeKey:@"x" withCStringFormat:"%f", point.x];
                        [coder encodeKey:@"y" withCStringFormat:"%f", point.y];
                        [coder encodeKey:@"c0x" withCStringFormat:"%f", pointC0.x];
                        [coder encodeKey:@"c0y" withCStringFormat:"%f", pointC0.y];
                        [coder encodeKey:@"c1x" withCStringFormat:"%f", pointC1.x];
                        [coder encodeKey:@"c1y" withCStringFormat:"%f", pointC1.y];
                    }];
                    break;
                }
            }
        }];
    }
    
    [coder encodeInteger:[self windingRule] forKey:@"windingRule"];
    [coder encodeFloat:[self lineWidth] forKey:@"lineWidth"];
    [coder encodeFloat:[self miterLimit] forKey:@"miterLimit"];
    [coder encodeFloat:[self flatness] forKey:@"flatness"];
    [coder encodeInteger:[self lineCapStyle] forKey:@"lineCapStyle"];
    [coder encodeInteger:[self lineJoinStyle] forKey:@"lineJoinStyle"];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"nspath";
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeGroupForKey:@"elements" usingBlock:^{
        [coder decodePointForKey:@"moveTo" setter:^(CGPoint point) {
            [self moveToPoint:point];
        }];
        [coder decodePointForKey:@"lineTo" setter:^(CGPoint point) {
            [self lineToPoint:point];
        }];
        [coder decodeGroupForKey:@"close" usingBlock:^{
            // Do nothing.
        } setter:^{
            [self closePath];
        }];
        __block NSPoint end, c0, c1;
        [coder decodeGroupForKey:@"curveTo" usingBlock:^{
            [coder decodeFloatForKey:@"x" setter:^(float value) {
                end.x = value;
            }];
            [coder decodeFloatForKey:@"y" setter:^(float value) {
                end.y = value;
            }];
            [coder decodeFloatForKey:@"c0x" setter:^(float value) {
                c0.x = value;
            }];
            [coder decodeFloatForKey:@"c0y" setter:^(float value) {
                c0.y = value;
            }];
            [coder decodeFloatForKey:@"c1x" setter:^(float value) {
                c1.x = value;
            }];
            [coder decodeFloatForKey:@"c1y" setter:^(float value) {
                c1.y = value;
            }];
        } setter:^{
            [self curveToPoint:end controlPoint1:c0 controlPoint2:c1];
        }];
    } setter:^{
        // Do nothing?
    }];
    [coder decodeIntegerForKey:@"windingRule" setter:^(NSInteger value) {
        self.windingRule = value;
    }];
    [coder decodeFloatForKey:@"lineWidth" setter:^(float value) {
        self.lineWidth = value;
    }];
    [coder decodeFloatForKey:@"miterLimit" setter:^(float value) {
        self.miterLimit = value;
    }];
    [coder decodeFloatForKey:@"flatness" setter:^(float value) {
        self.flatness = value;
    }];
    [coder decodeIntegerForKey:@"lineCapStyle" setter:^(NSInteger value) {
        self.lineCapStyle = value;
    }];
    [coder decodeIntegerForKey:@"lineJoinStyle" setter:^(NSInteger value) {
        self.lineJoinStyle = value;
    }];
}


@end
