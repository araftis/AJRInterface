/*
 AJRRulerView.m
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

#import "AJRRulerView.h"

#import "AJRPagedView.h"
#import "NSAffineTransform+Extensions.h"
#import "NSGraphicsContext+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>
#import <QuartzCore/QuartzCore.h>

@interface NSRulerView ()

+ (NSDictionary *)_registrationDictionaryForUnitNamed:(NSString *)name;

@end

#define RULE_THICKNESS 0.0
#define MARKER_THICKNESS 16.0

@implementation AJRRulerView {
    NSDictionary *_unitAttributes;
    NSImage *_hashMarksAndLabelCache;
    NSMutableDictionary<NSNumber *, CALayer *> *_sublayerCache;
}

#pragma mark - Creation

- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation {
    if ((self = [super initWithScrollView:scrollView orientation:orientation])) {
        self.backgroundColor = [NSColor windowBackgroundColor];
        self.rulerBackgroundColor = [NSColor whiteColor];
        self.rulerMarginBackgroundColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
        self.tickColor = [NSColor colorWithCalibratedWhite:0.47 alpha:1.0];
        self.unitColor = [NSColor colorWithCalibratedWhite:0.1 alpha:1.0];

        _unitAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeMini]], NSFontAttributeName,
                           _unitColor, NSForegroundColorAttributeName, nil];
        _sublayerCache = [NSMutableDictionary dictionary];

        [self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    }
    return self;
}

#pragma mark - Properties

- (NSString *)rulerUnitAbbreviation {
    return [[NSRulerView _registrationDictionaryForUnitNamed:[self measurementUnits]] objectForKey:@"NSRulerUnitAbbreviation"];
}

- (CGFloat)rulerUnitConversionFactor {
    return [[[NSRulerView _registrationDictionaryForUnitNamed:[self measurementUnits]] objectForKey:@"NSRulerUnitConversionFactor"] floatValue];
}

#pragma mark - Utilities

- (NSRulerMarker *)markerAtPoint:(NSPoint)point {
    for (NSRulerMarker *marker in [self markers]) {
        if ([self mouse:point inRect:[marker imageRectInRuler]]) {
            return marker;
        }
    }

    return nil;
}

#pragma mark - NSRulerView

//- (void)drawHorizontalRulerInRect:(NSRect)rect {
//	NSRect rulerBounds = [self bounds];
//	AJRPagedView *page = AJRObjectIfKindOfClass([self clientView], AJRPagedView);
//	NSDictionary *ticks = [NSRulerView _registrationDictionaryForUnitNamed:[self measurementUnits]];
//	CGFloat tickConversionFactor = [[ticks objectForKey:@"NSRulerUnitConversionFactor"] floatValue];
//	NSArray *stepDownCycle = [ticks objectForKey:@"NSRulerUnitStepDownCycle"];
//
//	[_backgroundColor set];
//	NSRectFill(rect);
//
//	if (page) {
//		NSArray *views = @[page];
//		if ([page respondsToSelector:@selector(horizontalViews)]) {
//			views = [(id <AJRRulerViewClient>)page horizontalViews];
//		}
//
//		for (NSView *page in views) {
//			NSRect frame = [self convertRect:[page bounds] fromView:page];
//			NSRect pageBounds = [page bounds];
//			CGFloat pageScale = [page frame].size.width / [page bounds].size.width;
//
//			if (!NSIntersectsRect((NSRect){{frame.origin.x, 0.0}, {frame.size.width, 10.0}}, (NSRect){{rect.origin.x, 0.0}, {rect.size.width, 10.0}})) continue;
//
//			[_rulerBackgroundColor set];
//			NSRectFill((NSRect){{frame.origin.x, 0.0}, {frame.size.width, pageBounds.size.height}});
//			[_tickColor set];
//			NSRectFill((NSRect){{frame.origin.x, 0.0}, {1.0, pageBounds.size.height}});
//			NSRectFill((NSRect){{frame.origin.x + frame.size.width, 0.0}, {1.0, pageBounds.size.height}});
//
//			[[NSGraphicsContext currentContext] drawWithSavedGraphicsState:^(NSGraphicsContext *context) {
//				NSInteger sdcCount = [stepDownCycle count];
//				NSInteger sdcIndex = NSNotFound;
//				CGFloat sdcValue = 1.0;
//				CGFloat tickHeight = rulerBounds.size.height;
//				CGFloat tickStep = tickConversionFactor;
//
//				[self->_rulerMarginBackgroundColor set];
//				if ([page respondsToSelector:@selector(horizontalMarginRanges)]) {
//					for (NSValue *rangeValue in [(id <AJRRulerViewClient>)page horizontalMarginRanges]) {
//						NSRange range = [rangeValue rangeValue];
//						NSRect frame = [page frame];
//						frame.origin.x = range.location;
//						frame.size.width = range.length;
//						frame = [self convertRect:frame fromView:page];
//						NSRectFill((NSRect){{frame.origin.x, 0.0}, {frame.size.width, pageBounds.size.height}});
//					}
//				}
//
//				do {
//					for (CGFloat x = pageBounds.origin.x; x <= pageBounds.origin.x + pageBounds.size.width; x += tickStep) {
//						NSRect tickRect = (NSRect){{x, pageBounds.origin.y}, {1.0, pageBounds.origin.y + tickHeight}};
//						NSString *unit;
//						NSPoint unitPoint;
//
//						[self->_tickColor set];
//
//						tickRect = [self convertRect:tickRect fromView:page];
//						tickRect.origin.y = rulerBounds.origin.y + rulerBounds.size.height - tickHeight;
//						tickRect.size.width = 1.0;
//						tickRect.size.height = tickHeight;
//						NSFrameRect([self centerScanRect:tickRect]);
//
//						if (sdcIndex == NSNotFound) { // For now, only label the top most unit.
//							unit = [NSString stringWithFormat:@"%.0f", x / 72.0];
//							unitPoint.x = tickRect.origin.x + 3.0;
//							unitPoint.y = tickRect.origin.y - 2.0;
//							[unit drawAtPoint:unitPoint withAttributes:self->_unitAttributes];
//						}
//					}
//
//					if (sdcIndex == NSNotFound) {
//						tickHeight /= 2.0;
//					} else {
//						tickHeight -= 2.0;
//						if (tickHeight < 2.0) {
//							tickHeight = 2.0;
//						}
//					}
//
//					sdcIndex = sdcIndex == NSNotFound ? 0 : sdcIndex + 1;
//					if (sdcIndex >= sdcCount) sdcIndex = sdcCount - 1;
//					sdcValue = [[stepDownCycle objectAtIndex:sdcIndex] floatValue];
//
//					tickStep *= sdcValue;
//				} while (tickStep >= 5.0 / pageScale);
//			}];
//		}
//	}
//
//	[_tickColor set];
//	[NSBezierPath strokeLineFromPoint:(NSPoint){rulerBounds.origin.x, rulerBounds.origin.y + rulerBounds.size.height - 0.5} toPoint:(NSPoint){rulerBounds.origin.x + rulerBounds.size.width, rulerBounds.origin.y + rulerBounds.size.height - 0.5}];
//}

- (void)drawHorizontalRulerInRect:(NSRect)rect pageScale:(CGFloat)pageScale {
    NSDictionary *ticks = [NSRulerView _registrationDictionaryForUnitNamed:[self measurementUnits]];
    CGFloat tickConversionFactor = [[ticks objectForKey:@"NSRulerUnitConversionFactor"] floatValue];
    NSArray *stepDownCycle = [ticks objectForKey:@"NSRulerUnitStepDownCycle"];

    [_tickColor set];
    NSRectFill((NSRect){{rect.origin.x, 0.0}, {1.0, rect.size.height}});
    NSRectFill((NSRect){{rect.origin.x + rect.size.width, 0.0}, {1.0, rect.size.height}});

    [[NSGraphicsContext currentContext] drawWithSavedGraphicsState:^(NSGraphicsContext *context) {
        NSInteger sdcCount = [stepDownCycle count];
        NSInteger sdcIndex = NSNotFound;
        CGFloat sdcValue = 1.0;
        CGFloat tickHeight = rect.size.height;
        CGFloat tickStep = tickConversionFactor;

        do {
            for (CGFloat x = rect.origin.x; x <= rect.origin.x + rect.size.width; x += tickStep) {
                NSRect tickRect = (NSRect){{x, rect.origin.y}, {1.0, rect.origin.y + tickHeight}};
                NSString *unit;
                NSPoint unitPoint;

                [self->_tickColor set];

                tickRect.origin.y = rect.origin.y + rect.size.height - tickHeight;
                tickRect.size.width = 1.0;
                tickRect.size.height = tickHeight;
                NSFrameRect([self centerScanRect:tickRect]);

                if (sdcIndex == NSNotFound) { // For now, only label the top most unit.
                    unit = [NSString stringWithFormat:@"%.0f", x / 72.0];
                    unitPoint.x = tickRect.origin.x + 3.0;
                    unitPoint.y = tickRect.origin.y - 2.0;
                    [unit drawAtPoint:unitPoint withAttributes:self->_unitAttributes];
                }
            }

            if (sdcIndex == NSNotFound) {
                tickHeight /= 2.0;
            } else {
                tickHeight -= 2.0;
                if (tickHeight < 2.0) {
                    tickHeight = 2.0;
                }
            }

            sdcIndex = sdcIndex == NSNotFound ? 0 : sdcIndex + 1;
            if (sdcIndex >= sdcCount) sdcIndex = sdcCount - 1;
            sdcValue = [[stepDownCycle objectAtIndex:sdcIndex] floatValue];

            tickStep *= sdcValue;
        } while (tickStep >= 5.0 / pageScale);
    }];

    [_tickColor set];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - 0.5} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.5}];
}

- (void)drawVerticalRulerInRect:(NSRect)rect pageScale:(CGFloat)pageScale {
    NSDictionary *ticks = [NSRulerView _registrationDictionaryForUnitNamed:[self measurementUnits]];
    CGFloat tickConversionFactor = [[ticks objectForKey:@"NSRulerUnitConversionFactor"] floatValue];
    NSArray *stepDownCycle = [ticks objectForKey:@"NSRulerUnitStepDownCycle"];

    [[NSGraphicsContext currentContext] drawWithSavedGraphicsState:^(NSGraphicsContext *context) {
        CGFloat tickHeight = rect.size.width;
        CGFloat tickStep = tickConversionFactor;
        NSInteger sdcCount = [stepDownCycle count];
        NSInteger sdcIndex = NSNotFound;
        CGFloat sdcValue = 1.0;

        [[NSBezierPath bezierPathWithRect:(NSRect){{0.0, rect.origin.y - 1.0}, {rect.size.width, rect.size.height + 1.0}}] addClip];

        do {
            for (CGFloat y = rect.origin.y; y <= rect.origin.y + rect.size.height; y += tickStep) {
                NSRect		tickRect = (NSRect){{0.0, y}, {1.0, 1.0}};
                NSString	*unit;
                NSPoint		unitPoint;

                [self->_tickColor set];

                tickRect.origin.x = rect.origin.x + rect.size.width - tickHeight;
                tickRect.size.width = tickHeight;
                tickRect.size.height = 1.0;
                NSFrameRect([self centerScanRect:tickRect]);

                if (sdcIndex == NSNotFound) { // For now, only label the top most unit.
                    [NSGraphicsContext saveGraphicsState];
                    unit = [NSString stringWithFormat:@"%.0f", y / 72.0];
                    unitPoint.x = tickRect.origin.x + 3.0;
                    unitPoint.y = tickRect.origin.y - 2.0;
                    [NSAffineTransform translateXBy:unitPoint.x yBy:unitPoint.y];
                    [NSAffineTransform rotateByDegrees:-90.0];
                    [NSAffineTransform translateXBy:0.0 yBy:-4.0];
                    [unit drawAtPoint:NSZeroPoint withAttributes:self->_unitAttributes];
                    [NSGraphicsContext restoreGraphicsState];
                }
            }

            if (sdcIndex == NSNotFound) {
                tickHeight /= 2.0;
            } else {
                tickHeight -= 2.0;
                if (tickHeight < 2.0) {
                    tickHeight = 2.0;
                }
            }

            sdcIndex = sdcIndex == NSNotFound ? 0 : sdcIndex + 1;
            if (sdcIndex >= sdcCount) sdcIndex = sdcCount - 1;
            sdcValue = [[stepDownCycle objectAtIndex:sdcIndex] floatValue];

            tickStep *= sdcValue;
        } while (tickStep >= 5.0 / pageScale);
    }];

    [_tickColor set];
    [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y - 0.5} toPoint:(NSPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.5}];
}
- (NSImage *)hashMarkAndLabelImageForSize:(NSSize)size pageScale:(CGFloat)pageScale {
    if (_hashMarksAndLabelCache == nil || !NSEqualSizes(size, [_hashMarksAndLabelCache size])) {
        _hashMarksAndLabelCache = [[NSImage alloc] initWithSize:size];
        [_hashMarksAndLabelCache lockFocusFlipped:YES];
        if ([self orientation] == NSHorizontalRuler) {
            [self drawHorizontalRulerInRect:(NSRect){NSZeroPoint, size} pageScale:1.0];
        } else {
            [self drawVerticalRulerInRect:(NSRect){NSZeroPoint, size} pageScale:1.0];
        }
        [_hashMarksAndLabelCache unlockFocus];
    }
    return _hashMarksAndLabelCache;
}

- (void)updateSublayers {
    AJRPagedView *page = AJRObjectIfKindOfClass([self clientView], AJRPagedView);
    CALayer *layer = [self layer];

    if (page) {
        NSRect rulerBounds = [self bounds];
        NSArray *views = @[page];

        if ([self orientation] == NSHorizontalRuler) {
            if ([page respondsToSelector:@selector(horizontalViews)]) {
                views = [(id <AJRRulerViewClient>)page horizontalViews];
            }
        } else {
            if ([page respondsToSelector:@selector(verticalViews)]) {
                views = [(id <AJRRulerViewClient>)page verticalViews];
            }
        }

        [CATransaction begin];
        [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
        for (NSInteger x = 0, max = [views count]; x < max; x++) {
            CALayer *rulerLayer = [_sublayerCache objectForKey:@(x)];
            NSView *page = views[x];
            NSRect frame = [self convertRect:[page bounds] fromView:page];

            if ([self orientation] == NSHorizontalRuler) {
                frame.origin.y = 0;
                frame.size.height = rulerBounds.size.height;
            } else {
                frame.origin.x = 0;
                frame.size.width = rulerBounds.size.width;
            }

            if (rulerLayer == nil) {
                rulerLayer = [[CALayer alloc] init];
                [_sublayerCache setObject:rulerLayer forKey:@(x)];
                [rulerLayer setBackgroundColor:[[self rulerBackgroundColor] CGColor]];
                [layer addSublayer:rulerLayer];
            }

            if ([rulerLayer contents] == nil || !NSEqualRects(frame, rulerLayer.frame)) {
                [rulerLayer setContents:[self hashMarkAndLabelImageForSize:frame.size pageScale:1.0]];
                [rulerLayer setFrame:frame];
            }
        }
        [CATransaction commit];
    }
}

//- (void)drawVerticalRulerInRect:(NSRect)rect {
//	NSRect rulerBounds = [self bounds];
//	NSView<AJRRulerViewClient> *page = (NSView<AJRRulerViewClient> *)[self clientView];
//	NSDictionary *ticks = [NSRulerView _registrationDictionaryForUnitNamed:[self measurementUnits]];
//	CGFloat tickConversionFactor = [[ticks objectForKey:@"NSRulerUnitConversionFactor"] floatValue];
//	NSArray *stepDownCycle = [ticks objectForKey:@"NSRulerUnitStepDownCycle"];
//
//	[_backgroundColor set];
//	NSRectFill(rect);
//
//	if (page) {
//		NSArray *views = @[page];
//		if ([page respondsToSelector:@selector(verticalViews)]) {
//			views = [(id <AJRRulerViewClient>)page verticalViews];
//		}
//
//		for (NSView *page in views) {
//			NSRect frame = [self convertRect:[page bounds] fromView:page];
//			NSRect pageBounds = [page bounds];
//			CGFloat pageScale = [page frame].size.width / [page bounds].size.width;
//
//			if (!NSIntersectsRect((NSRect){{0.0, frame.origin.x}, {10.0, frame.size.height}}, (NSRect){{0.0, rect.origin.y}, {10.0, rect.size.height}})) continue;
//
//			[_rulerBackgroundColor set];
//			NSRectFill((NSRect){{0.0, frame.origin.y}, {pageBounds.size.width, frame.size.height}});
//
//			[[NSGraphicsContext currentContext] drawWithSavedGraphicsState:^(NSGraphicsContext *context) {
//				CGFloat tickHeight = rulerBounds.size.width;
//				CGFloat tickStep = tickConversionFactor;
//				NSInteger sdcCount = [stepDownCycle count];
//				NSInteger sdcIndex = NSNotFound;
//				CGFloat sdcValue = 1.0;
//
//				[[NSBezierPath bezierPathWithRect:(NSRect){{0.0, frame.origin.y - 1.0}, {pageBounds.size.width, frame.size.height + 1.0}}] addClip];
//
//				[self->_rulerMarginBackgroundColor set];
//				if ([page respondsToSelector:@selector(verticalMarginRanges)]) {
//					for (NSValue *rangeValue in [(id <AJRRulerViewClient>)page verticalMarginRanges]) {
//						NSRange range = [rangeValue rangeValue];
//						NSRect frame = [page frame];
//						frame.origin.y = range.location;
//						frame.size.height = range.length;
//						frame = [self convertRect:frame fromView:page];
//						NSRectFill((NSRect){{0.0, frame.origin.y}, {pageBounds.size.width, frame.size.height}});
//					}
//				}
//
//				do {
//					for (CGFloat y = pageBounds.origin.y; y <= pageBounds.origin.y + pageBounds.size.height; y += tickStep) {
//						NSRect		tickRect = (NSRect){{0.0, y}, {1.0, 1.0}};
//						NSString	*unit;
//						NSPoint		unitPoint;
//
//						[self->_tickColor set];
//
//						tickRect = [self convertRect:tickRect fromView:page];
//						//tickRect.origin.y += 1.0;
//						tickRect.origin.x = rulerBounds.origin.x + rulerBounds.size.width - tickHeight;
//						tickRect.size.width = tickHeight;
//						tickRect.size.height = 1.0;
//						NSFrameRect([self centerScanRect:tickRect]);
//
//						if (sdcIndex == NSNotFound) { // For now, only label the top most unit.
//							[NSGraphicsContext saveGraphicsState];
//							unit = [NSString stringWithFormat:@"%.0f", y / 72.0];
//							unitPoint.x = tickRect.origin.x + 3.0;
//							unitPoint.y = tickRect.origin.y - 2.0;
//							[NSAffineTransform translateXBy:unitPoint.x yBy:unitPoint.y];
//							[NSAffineTransform rotateByDegrees:-90.0];
//							[NSAffineTransform translateXBy:0.0 yBy:-4.0];
//							[unit drawAtPoint:NSZeroPoint withAttributes:self->_unitAttributes];
//							[NSGraphicsContext restoreGraphicsState];
//						}
//					}
//
//					if (sdcIndex == NSNotFound) {
//						tickHeight /= 2.0;
//					} else {
//						tickHeight -= 2.0;
//						if (tickHeight < 2.0) {
//							tickHeight = 2.0;
//						}
//					}
//
//					sdcIndex = sdcIndex == NSNotFound ? 0 : sdcIndex + 1;
//					if (sdcIndex >= sdcCount) sdcIndex = sdcCount - 1;
//					sdcValue = [[stepDownCycle objectAtIndex:sdcIndex] floatValue];
//
//					tickStep *= sdcValue;
//				} while (tickStep >= 5.0 / pageScale);
//			}];
//		}
//	}
//
//	[_tickColor set];
//	[NSBezierPath strokeLineFromPoint:(NSPoint){rulerBounds.origin.x + rulerBounds.size.width, rulerBounds.origin.y - 0.5} toPoint:(NSPoint){rulerBounds.origin.x + rulerBounds.size.width, rulerBounds.origin.y + rulerBounds.size.height - 0.5}];
//}

- (BOOL)wantsLayer {
    return YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (BOOL)canDrawSubviewsIntoLayer {
    return NO;
}

- (void)updateLayer {
    CALayer *layer = [self layer];
    layer.backgroundColor = [[self backgroundColor] CGColor];
    [self updateSublayers];
}

- (CGFloat)baselineLocation {
    NSRect	bounds = [self bounds];

    if ([self orientation] == NSHorizontalRuler) {
        return bounds.origin.y + bounds.size.height;
    } else {
        return bounds.origin.x + bounds.size.width;
    }
}

- (void)setRuleThickness:(CGFloat)thickness {
    [super setRuleThickness:RULE_THICKNESS];
}

- (CGFloat)ruleThickness {
    return RULE_THICKNESS;
}

- (CGFloat)requiredThickness {
    return RULE_THICKNESS + MARKER_THICKNESS;
}

- (void)setReservedThicknessForMarkers:(CGFloat)thickness {
    [super setReservedThicknessForMarkers:MARKER_THICKNESS];
}

- (CGFloat)reservedThicknessForMarkers {
    return MARKER_THICKNESS;
}

- (void)setReservedThicknessForAccessoryView:(CGFloat)thickness {
    [super setReservedThicknessForAccessoryView:0.0];
}

- (CGFloat)reservedThicknessForAccessoryView {
    return 0.0;
}

- (void)setClientView:(NSView *)client {
    [super setClientView:client];

    if ([[self clientView] respondsToSelector:@selector(rulerViewDidSetClientView:)]) {
        [(id <AJRRulerViewClient>)[self clientView] rulerViewDidSetClientView:self];
    }
}

#pragma mark - NSResponder

- (void)mouseDown:(NSEvent *)event {
    NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil];
    NSRulerMarker *marker = [self markerAtPoint:where];

    if (marker) {
        [marker trackMouse:event adding:NO];
    } else {
        if ([[self clientView] respondsToSelector:@selector(rulerView:handleMouseDown:)]) {
            [[self clientView] rulerView:self handleMouseDown:event];
        }
    }
}

@end
