/*
 AJRLineNumberView.m
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

#import "AJRLineNumberView.h"
#import "AJRLineNumberMarker.h"

#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/AJRLogging.h>
#import <AJRFoundation/NSObject+Extensions.h>

#import <objc/runtime.h>

#define DEFAULT_THICKNESS 22.0
#define DEFAULT_MARGIN 5.0

@interface AJRLineNumberView (Private)

- (NSMutableArray *)lineIndices;
- (void)invalidateLineIndices;
- (void)calculateLines;
- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index inText:(NSString *)text;
- (NSDictionary *)textAttributes;
- (NSDictionary *)markerTextAttributes;

@end

@implementation AJRLineNumberView {
    // Array of character indices for the beginning of each line
    NSMutableArray *_lineIndices;
    // Maps line numbers to markers
    NSMutableDictionary<NSNumber *, AJRLineNumberMarker *> *_linesToMarkers;
}

#pragma mark - Creation

- (instancetype)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation {
    if (orientation == NSHorizontalRuler) {
        AJRLogWarning(@"%C is only designed to work in a vertical orientation, but you've tried to create one in a horizontal orientation. The orientation will be set to NSVerticalRuler, but this may cause you unexpected results.", self);
    }
    // We do this, because we're only designed to work in the vertical orientation.
    return [self initWithScrollView:scrollView];
}

- (instancetype)initWithScrollView:(NSScrollView *)scrollView {
    if ((self = [super initWithScrollView:scrollView orientation:NSVerticalRuler]) != nil) {
        _linesToMarkers = [[NSMutableDictionary alloc] init];
        _leftMargin = DEFAULT_MARGIN;
        _rightMargin = DEFAULT_MARGIN;
        _showsLineNumbers = YES;
        [self setClientView:[scrollView documentView]];
        self.font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
        self.textColor = [NSColor blackColor];
        self.alternateTextColor = [NSColor darkGrayColor];
        self.backgroundColor = [NSColor controlColor];
        
        AJRLogDebug(@"%C: client: %@\n", self, [self clientView]);
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNibAwakening

- (void)awakeFromNib {
    _linesToMarkers = [[NSMutableDictionary alloc] init];
    [self setClientView:[[self scrollView] documentView]];
}

- (void)setClientView:(NSView *)aView {
    id oldClientView;
    
    oldClientView = [self clientView];
    
    if ((oldClientView != aView) && [oldClientView isKindOfClass:[NSTextView class]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:[(NSTextView *)oldClientView textStorage]];
    }
    [super setClientView:aView];
    if ((aView != nil) && [aView isKindOfClass:[NSTextView class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextStorageDidProcessEditingNotification object:[(NSTextView *)aView textStorage]];
        [[(NSTextView *)aView layoutManager] addObserver:self forKeyPath:@"textStorage" options:0 context:NULL];
        [self invalidateLineIndices];
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //AJRPrintf(@"%C: change: %@: %@\n", self, keyPath, object);
    if ([keyPath isEqualToString:@"textStorage"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextStorageDidProcessEditingNotification object:[(NSLayoutManager *)object textStorage]];
    }
}

#pragma mark - NSText Notifications

- (void)textDidChange:(NSNotification *)notification {
    // Invalidate the line indices. They will be recalculated and recached on demand.
    [self invalidateLineIndices];
    [self setNeedsDisplay:YES];
}

#pragma mark - Utilities

- (void)invalidateLineIndices {
    _lineIndices = nil;
}

- (NSUInteger)lineNumberForLocation:(CGFloat)location {
    NSTextView *view = AJRObjectIfKindOfClass(self.clientView, NSTextView);
    NSRect visibleRect = self.scrollView.contentView.bounds;
    NSMutableArray *lines = [self lineIndices];

    location += NSMinY(visibleRect);
    
    if ([view isKindOfClass:[NSTextView class]]) {
        NSRange nullRange = NSMakeRange(NSNotFound, 0);
        NSLayoutManager *layoutManager = [view layoutManager];
        NSTextContainer *container = [view textContainer];
        NSUInteger count = [lines count];
        
        for (NSUInteger line = 0; line < count; line++) {
            NSUInteger rectCount;
            NSInteger index = [[lines objectAtIndex:line] unsignedIntValue];
            
            NSRectArray rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(index, 0)
                                             withinSelectedCharacterRange:nullRange
                                                          inTextContainer:container
                                                                rectCount:&rectCount];
            
            for (NSInteger i = 0; i < rectCount; i++) {
                if ((location >= NSMinY(rects[i])) && (location < NSMaxY(rects[i]))) {
                    return line + 1;
                }
            }
        }    
    }
    return NSNotFound;
}

- (NSMutableArray *)lineIndices {
    if (_lineIndices == nil) {
        [self calculateLines];
    }
    return _lineIndices;
}

- (void)calculateLines {
    id view;

    view = [self clientView];
    
    if ([view isKindOfClass:[NSTextView class]]) {
        NSUInteger    index, numberOfLines, stringLength, lineEnd, contentEnd;
        NSString    *text;
        CGFloat        oldThickness, newThickness;
        
        text = [view string];
        stringLength = [text length];
        _lineIndices = [[NSMutableArray alloc] init];
        
        index = 0;
        numberOfLines = 0;
        
        do {
            [_lineIndices addObject:[NSNumber numberWithUnsignedInteger:index]];
            
            index = NSMaxRange([text lineRangeForRange:NSMakeRange(index, 0)]);
            numberOfLines++;
        }
        while (index < stringLength);

        // Check if text ends with a new line.
        [text getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineIndices lastObject] unsignedIntValue], 0)];
        if (contentEnd < lineEnd) {
            [_lineIndices addObject:[NSNumber numberWithUnsignedInteger:index]];
        }

        oldThickness = [self ruleThickness];
        newThickness = [self requiredThickness];
        if (fabs(oldThickness - newThickness) > 1) {
            NSInvocation *invocation;
            
            // Not a good idea to resize the view during calculations (which can happen during
            // display). Do a delayed perform (using NSInvocation since arg is a float).
            invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(setRuleThickness:)]];
            [invocation setSelector:@selector(setRuleThickness:)];
            [invocation setTarget:self];
            [invocation setArgument:&newThickness atIndex:2];
            
            [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.0];
        }
    }
}

- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index inText:(NSString *)text {
    NSUInteger left, right, mid, lineStart;
    NSMutableArray *lines;

    lines = [self lineIndices];
    
    // Binary search
    left = 0;
    right = [lines count];

    while ((right - left) > 1) {
        mid = (right + left) / 2;
        lineStart = [[lines objectAtIndex:mid] unsignedIntValue];
        
        if (index < lineStart) {
            right = mid;
        } else if (index > lineStart) {
            left = mid;
        } else {
            return mid;
        }
    }
    return left;
}

- (NSDictionary *)textAttributes {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self font], NSFontAttributeName, 
            [self textColor], NSForegroundColorAttributeName,
            nil];
}

- (NSDictionary *)markerTextAttributes {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self font], NSFontAttributeName, 
            [self alternateTextColor], NSForegroundColorAttributeName,
            nil];
}

- (CGFloat)requiredThickness {
    NSUInteger lineCount, digits, i;
    NSMutableString *sampleString;
    NSSize stringSize;
    
    if (_showsLineNumbers) {
        lineCount = [[self lineIndices] count];
        digits = (NSUInteger)log10(lineCount) + 1;
        sampleString = [NSMutableString string];
        for (i = 0; i < digits; i++) {
            // Use "8" since it is one of the fatter numbers. Anything but "1"
            // will probably be ok here. I could be pedantic and actually find the fattest
            // number for the current font but nah.
            [sampleString appendString:@"8"];
        }
        stringSize = [sampleString sizeWithAttributes:[self textAttributes]];
    } else {
        stringSize = NSZeroSize;
    }
    
    CGFloat maxMarkerThickness = 0;
    for (AJRLineNumberMarker *marker in [self markers]) {
        maxMarkerThickness = MAX(maxMarkerThickness, [marker thicknessRequiredInRuler]);
    }

    // Round up the value. There is a bug on 10.4 where the display gets all wonky when scrolling if you don't
    // return an integral value here.
    CGFloat thickness = ceilf(MAX(MAX(MAX(DEFAULT_THICKNESS, stringSize.width + _leftMargin + _rightMargin), _miniumWidth), maxMarkerThickness));
    return thickness;
}

- (void)setNeedsDisplay {
    [self setNeedsDisplay:YES];
}

- (AJRLineNumberMarker *)markerAtPoint:(NSPoint)point rect:(NSRectPointer)rect {
    __block AJRLineNumberMarker *marker = nil;
    
    NSArray<AJRLineNumberMarker *> *markers = (NSArray<AJRLineNumberMarker *> *)[self markers];
    [markers enumerateObjectsUsingBlock:^(AJRLineNumberMarker *possible, NSUInteger index, BOOL *stop) {
        if (NSPointInRect(point, [possible hitRect])) {
            if (rect) {
                *rect = [possible hitRect];
            }
            marker = possible;
            *stop = YES;
        }
    }];
    
    return marker;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect {
    NSRect bounds;

    if (aRect.size.height != [self bounds].size.height) {
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.01];
    }
    
    bounds = [self bounds];

    if (_backgroundColor != nil) {
        [_backgroundColor set];
        NSRectFill(bounds);
        
        [[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(bounds) - 0/5, NSMinY(bounds)) toPoint:NSMakePoint(NSMaxX(bounds) - 0.5, NSMaxY(bounds))];
    }
    
    NSTextView *view = AJRObjectIfKindOfClass(self.clientView, NSTextView);
    NSAssert(view != nil, @"We expected our client view to be an NSTextView, but we got a %@ instead", NSStringFromClass(self.clientView.class));
    
    if ([view isKindOfClass:[NSTextView class]]) {
        NSLayoutManager *layoutManager;
        NSTextContainer *container;
        NSRect visibleRect, markerRect;
        NSRange range, glyphRange, nullRange;
        NSString *text, *labelText;
        NSUInteger rectCount, index, line, count;
        NSRectArray rects;
        CGFloat ypos, yinset;
        NSDictionary *textAttributes, *currentTextAttributes;
        NSSize stringSize, markerSize;
        AJRLineNumberMarker *marker;
        NSImage *markerImage;
        NSMutableArray *lines;

        layoutManager = [view layoutManager];
        container = [view textContainer];
        text = [view string];
        nullRange = NSMakeRange(NSNotFound, 0);
        
        yinset = [view textContainerInset].height;        
        visibleRect = [[[self scrollView] contentView] bounds];

        textAttributes = [self textAttributes];
        
        lines = [self lineIndices];

        // Find the characters that are currently visible
        glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:container];
        range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        
        // Fudge the range a tad in case there is an extra new line at end.
        // It doesn't show up in the glyphs so would not be accounted for.
        range.length++;
        
        count = [lines count];
        index = 0;
        
        for (line = [self lineNumberForCharacterIndex:range.location inText:text]; line < count; line++) {
            index = [[lines objectAtIndex:line] unsignedIntValue];
            
            if (NSLocationInRange(index, range)) {
                rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(index, 0)
                                     withinSelectedCharacterRange:nullRange
                                                  inTextContainer:container
                                                        rectCount:&rectCount];
                
                if (rectCount > 0) {
                    // Note that the ruler view is only as tall as the visible
                    // portion. Need to compensate for the clipview's coordinates.
                    ypos = yinset + NSMinY(rects[0]) - NSMinY(visibleRect);
                    
                    marker = [_linesToMarkers objectForKey:@(line)];
                    
                    if (marker != nil) {
                        if ([marker overridesSelector:@selector(drawRect:)]) {
                            markerRect.origin.x = 0.0;
                            markerRect.size.width = NSWidth(bounds);
                            markerRect.origin.y = ypos;
                            markerRect.size.height = NSHeight(rects[0]);
                            [marker drawRect:markerRect];
                        } else {
                            markerImage = [marker image];
                            markerSize = [markerImage size];
                            markerRect = NSMakeRect(0.0, 0.0, markerSize.width, markerSize.height);
                            
                            // Marker is flush right and centered vertically within the line.
                            switch ([marker horizontalAlignment]) {
                                default:
                                case AJRMarkerLeftAlignment:
                                    markerRect.origin.x = 1.0;
                                    break;
                                case AJRMarkerCenterAlignment:
                                    markerRect.origin.x = rint((NSWidth(bounds)  + [markerImage size].width) / 2.0);
                                    break;
                                case AJRMarkerRightAlignment:
                                    markerRect.origin.x = NSWidth(bounds) - [markerImage size].width - 1.0;
                                    break;
                            }
                            switch ([marker verticalAlignment]) {
                                default:
                                case AJRMarkerTopAlignment:
                                    markerRect.origin.y = ypos + NSHeight(rects[0]) - markerSize.height;
                                    break;
                                case AJRMarkerCenterAlignment:
                                    markerRect.origin.y = ypos + (NSHeight(rects[0]) + markerSize.height) / 2.0;
                                    break;
                                case AJRMarkerBottomAlignment:
                                    markerRect.origin.x = ypos;
                                    break;
                            }
                            
                            markerRect.origin.x += [marker imageOrigin].x;
                            markerRect.origin.y += [marker imageOrigin].y;
                            
                            [markerImage drawInRect:markerRect fromRect:NSMakeRect(0, 0, markerSize.width, markerSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
                        }
                        marker.hitRect = markerRect;

                        if (_showsLineNumbers) {
                            // Line numbers are internally stored starting at 0
                            labelText = [NSString stringWithFormat:@"%lu", line + 1];
                            
                            stringSize = [labelText sizeWithAttributes:textAttributes];
                            
                            if (marker == nil) {
                                currentTextAttributes = textAttributes;
                            } else {
                                currentTextAttributes = [self markerTextAttributes];
                            }
                            
                            // Draw string flush right, centered vertically within the line
                            [labelText drawInRect:NSMakeRect(NSWidth(bounds) - stringSize.width - _rightMargin,
                                                             ypos + (NSHeight(rects[0]) - stringSize.height) / 2.0,
                                                             NSWidth(bounds) - (_leftMargin + _rightMargin) + 3.0, NSHeight(rects[0]))
                                   withAttributes:currentTextAttributes];
                        }
                    }
                }
            }
            if (index > NSMaxRange(range)) {
                break;
            }
        }
    }
}

#pragma mark - Markers

- (void)_moveMarkerFromLine:(NSUInteger)originLine toLine:(NSUInteger)destinationLine {
    AJRLineNumberMarker *marker = [_linesToMarkers objectForKey:@(originLine - 1)];
    if (marker) {
        //AJRPrintf(@"moving marker %ld to %ld\n", (long)originLine, (long)destinationLine);
        [_linesToMarkers removeObjectForKey:@(originLine - 1)];
        [_linesToMarkers setObject:marker forKey:@(destinationLine - 1)];
    }
}

- (AJRLineNumberMarker *)markerAtLine:(NSUInteger)line {
    return [_linesToMarkers objectForKey:@(line - 1)];
}

- (NSArray<AJRLineNumberMarker *> *)markers {
    return [_linesToMarkers allValues];
}

- (void)setMarkers:(NSArray<AJRLineNumberMarker *> *)markers {
    NSEnumerator *enumerator;
    NSRulerMarker *marker;
    
    [_linesToMarkers removeAllObjects];
    [super setMarkers:nil];

    enumerator = [markers objectEnumerator];
    while ((marker = [enumerator nextObject]) != nil) {
        [self addMarker:marker];
    }
}

- (void)addMarker:(AJRLineNumberMarker *)marker {
    if ([marker isKindOfClass:[AJRLineNumberMarker class]]) {
        [_linesToMarkers setObject:marker
                            forKey:@([(AJRLineNumberMarker *)marker lineNumber] - 1)];
    } else {
        [super addMarker:marker];
    }
}

- (void)removeMarker:(NSRulerMarker *)aMarker {
    if ([aMarker isKindOfClass:[AJRLineNumberMarker class]]) {
        [_linesToMarkers removeObjectForKey:@([(AJRLineNumberMarker *)aMarker lineNumber] - 1)];
    } else {
        [super removeMarker:aMarker];
    }
}

#pragma mark - Events

- (void)mouseDown:(NSEvent *)event {
    // We only track something if we hit a marker.
    NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil];
    NSRect markerFrame;
    AJRLineNumberMarker *marker = [self markerAtPoint:where rect:&markerFrame];

    if (marker) {
        [marker trackMouse:event adding:NO];
    }
}

#pragma mark - NSCoding

#define AJR_FONT_CODING_KEY                @"font"
#define AJR_TEXT_COLOR_CODING_KEY        @"textColor"
#define AJR_ALT_TEXT_COLOR_CODING_KEY    @"alternateTextColor"
#define AJR_BACKGROUND_COLOR_CODING_KEY    @"backgroundColor"
#define AJR_LEFT_MARGIN_KEY                @"leftMargin"
#define AJR_RIGHT_MARGIN_KEY                @"rightMargin"
#define AJR_SHOWS_LINE_NUMBERS            @"showsLineNumbers"
#define AJR_MINIMUM_WIDTH                @"minimumWidth"

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder]) != nil) {
        if ([decoder allowsKeyedCoding]) {
            _font = [decoder decodeObjectForKey:AJR_FONT_CODING_KEY];
            _textColor = [decoder decodeObjectForKey:AJR_TEXT_COLOR_CODING_KEY];
            _alternateTextColor = [decoder decodeObjectForKey:AJR_ALT_TEXT_COLOR_CODING_KEY];
            _backgroundColor = [decoder decodeObjectForKey:AJR_BACKGROUND_COLOR_CODING_KEY];
            _leftMargin = [decoder decodeFloatForKey:AJR_LEFT_MARGIN_KEY];
            _rightMargin = [decoder decodeFloatForKey:AJR_RIGHT_MARGIN_KEY];
            if ([decoder containsValueForKey:AJR_SHOWS_LINE_NUMBERS]) {
                _showsLineNumbers = [decoder decodeBoolForKey:AJR_SHOWS_LINE_NUMBERS];
            } else {
                _showsLineNumbers = YES;
            }
            _miniumWidth = [decoder decodeFloatForKey:AJR_MINIMUM_WIDTH];
        } else {
            _font = [decoder decodeObject];
            _textColor = [decoder decodeObject];
            _alternateTextColor = [decoder decodeObject];
            _backgroundColor = [decoder decodeObject];
            _leftMargin = DEFAULT_MARGIN;
            _rightMargin = DEFAULT_MARGIN;
            _showsLineNumbers = YES;
        }
        
        _linesToMarkers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    if ([encoder allowsKeyedCoding]) {
        [encoder encodeObject:_font forKey:AJR_FONT_CODING_KEY];
        [encoder encodeObject:_textColor forKey:AJR_TEXT_COLOR_CODING_KEY];
        [encoder encodeObject:_alternateTextColor forKey:AJR_ALT_TEXT_COLOR_CODING_KEY];
        [encoder encodeObject:_backgroundColor forKey:AJR_BACKGROUND_COLOR_CODING_KEY];
        [encoder encodeFloat:_leftMargin forKey:AJR_LEFT_MARGIN_KEY];
        [encoder encodeFloat:_rightMargin forKey:AJR_RIGHT_MARGIN_KEY];
        [encoder encodeBool:_showsLineNumbers forKey:AJR_SHOWS_LINE_NUMBERS];
        [encoder encodeFloat:_miniumWidth forKey:AJR_MINIMUM_WIDTH];
    } else {
        [encoder encodeObject:_font];
        [encoder encodeObject:_textColor];
        [encoder encodeObject:_alternateTextColor];
        [encoder encodeObject:_backgroundColor];
    }
}

//typedef void (*AJRVoidImp)(id self, SEL cmd);
//
//- (void)_scrollToMatchContentView {
//    if ([[NSGraphicsContext currentContext] CGContext] != nil) {
//        AJRLogInfo(@"graphics: %@", [[NSGraphicsContext currentContext] CGContext]);
//        AJRVoidImp superImp = (AJRVoidImp)[[[self class] superclass] instanceMethodForSelector:_cmd];
//        if (superImp) {
//            superImp(self, _cmd);
//        }
//    }
//}

@end
