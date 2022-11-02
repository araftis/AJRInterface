/*
 AJRPagedView.m
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

#import "AJRPagedView.h"

#import "AJRBorder.h"
#import "AJRDropShadowBorder.h"
#import "AJRPageLayout.h"
#import "AJRVerticalPageLayout.h"
#import "NSGraphicsContext+Extensions.h"
#import "NSPrintInfo+Extensions.h"
#import "NSView+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>
#import <AJRInterfaceFoundation/AJRBezierPath.h>

const NSInteger AJRPageIndexMasterSingle = -3;
const NSInteger AJRPageIndexMasterEven   = -2;
const NSInteger AJRPageIndexMasterOdd    = -1;
const NSInteger AJRPageIndexFirst        = 0;

@interface AJRPagedView ()

@end

@implementation AJRPagedView {
    NSUInteger _printingPage;

    NSMutableSet<NSView *> *_subviewIndex;

    BOOL _pageDataSourceRespondsToColorForPage;
}

#pragma mark - Properties

- (void)_commonInit {
    _verticalGap = 10.0;
    _horizontalGap = 10.0;
    
    _backgroundColor = nil; //NSColor.underPageBackgroundColor;
    _pageBorder = [AJRBorder borderForName:[AJRDropShadowBorder name]];
    _pageLayout = [AJRPageLayout pageLayoutForView:self withIdentifier:@"vertical"];
    _scale = 1.0;
    _subviewIndex = [[NSMutableSet alloc] init];

    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self removeConstraints:[self constraints]];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self _commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _commonInit];
    }
    
    return self;
}

#pragma mark - NSView

- (void)setNeedsDisplay:(BOOL)needsDisplay {
    for (NSView *subview in [self subviews]) {
        [subview setNeedsDisplay:YES];
    }
    [super setNeedsDisplay:needsDisplay];
}

#pragma mark - Properties

- (void)setPageDataSource:(id <AJRPagedViewDataSource>)pageDataSource {
    if (_pageDataSource != pageDataSource) {
        _pageDataSource = pageDataSource;
        
        _pageDataSourceRespondsToColorForPage = [_pageDataSource respondsToSelector:@selector(pagedView:colorForPage:)];
        
        [self reloadPages];
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setPageBorder:(AJRBorder *)pageBorder {
    if (_pageBorder != pageBorder) {
        _pageBorder = pageBorder;
        [self setNeedsDisplay:YES];
    }
}

- (void)setMasterPageDisplay:(AJRMasterPageDisplay)masterPageDisplay {
    if (_masterPageDisplay != masterPageDisplay) {
        _masterPageDisplay = masterPageDisplay;
        [self reloadPages];
        [self setNeedsDisplay:YES];
    }
}

- (void)setPageLayout:(AJRPageLayout *)pageLayout {
    if (_pageLayout != pageLayout) {
        _pageLayout = pageLayout;
        [self setNeedsUpdateConstraints:YES];
    }
}

- (void)setPageLayoutIdentifier:(NSString *)pageLayoutIdentifier {
    AJRPageLayout *layout = [AJRPageLayout pageLayoutForView:self withIdentifier:pageLayoutIdentifier];
    if (layout) {
        [self setPageLayout:layout];
    }
}

- (NSString *)pageLayoutIdentifier {
    return [[self pageLayout] identifier];
}

- (void)setScale:(CGFloat)scale {
    if (_scale != scale) {
        _scale = scale;
        [self setNeedsUpdateConstraints:YES];
    }
}

#pragma mark - Pages

- (NSRect)adjustScroll:(NSRect)proposedRect {
    NSRect result;
    
    [self willChangeValueForKey:@"visiblePageIndexes"];
    result = [super adjustScroll:proposedRect];
    [self didChangeValueForKey:@"visiblePageIndexes"];

    return result;
}

- (void)layout {
    [self willChangeValueForKey:@"visiblePageIndexes"];
    [super layout];
    if (_pageDataSource) {
        NSView *view;
        NSUInteger pageCount = [_pageDataSource pageCountForPagedView:self];
        
        if (_masterPageDisplay == AJRMasterPageDisplaySingle) {
            view = [_pageDataSource pagedView:self viewForPage:AJRPageIndexMasterSingle];
            [view setBoundsSize:[_pageDataSource pagedView:self sizeForPage:AJRPageIndexMasterSingle]];
        }
        if (_masterPageDisplay == AJRMasterPageDisplayDouble) {
            view = [_pageDataSource pagedView:self viewForPage:AJRPageIndexMasterEven];
            [view setBoundsSize:[_pageDataSource pagedView:self sizeForPage:AJRPageIndexMasterEven]];
            view = [_pageDataSource pagedView:self viewForPage:AJRPageIndexMasterOdd];
            [view setBoundsSize:[_pageDataSource pagedView:self sizeForPage:AJRPageIndexMasterOdd]];
        }
        
        for (NSInteger pageNumber = 0; pageNumber < pageCount; pageNumber++) {
            view = [_pageDataSource pagedView:self viewForPage:pageNumber];
            [view setBoundsSize:[_pageDataSource pagedView:self sizeForPage:pageNumber]];
        }
    }
    [self didChangeValueForKey:@"visiblePageIndexes"];
}

- (NSView *)viewForPageNumber:(NSInteger)pageNumber {
    return [_pageDataSource pagedView:self viewForPage:pageNumber];
}

- (void)addSubview:(NSView *)aView {
    if (![_subviewIndex containsObject:aView]) {
        [aView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_subviewIndex addObject:aView];
        [super addSubview:aView];
    }
}

- (void)willRemoveSubview:(NSView *)subview {
    [_subviewIndex removeObject:subview];
}

#pragma mark - NSView

+ (BOOL)requiresConstraintBasedLayout {
    // We're always going to layout with constraints
    return YES;
}

- (BOOL)isFlipped {
    // This makes us play well in scroll views.
    return YES;
}

- (void)updateConstraints {
    [self willChangeValueForKey:@"visiblePageIndexes"];
    
    [super updateConstraints];

    [self removeConstraints:[self constraints]];
    
    [_pageLayout updateConstraints];
    [self setNeedsDisplay:YES];
    [[[self enclosingScrollView] verticalRulerView] setNeedsDisplay:YES];
    [[[self enclosingScrollView] horizontalRulerView] setNeedsDisplay:YES];

    [self didChangeValueForKey:@"visiblePageIndexes"];
}

- (void)_drawPageViewForPageIndex:(NSInteger)pageIndex inRect:(NSRect)dirtyRect {
    NSView *pageView = [_pageDataSource pagedView:self viewForPage:pageIndex];
    
    if (pageView) {
        NSRect subviewFrame = [pageView frame];

        if (NSIntersectsRect(subviewFrame, dirtyRect)) {
            NSRect subviewDrawFrame = NSInsetRect(subviewFrame, -_horizontalGap, -_verticalGap);

            if ([self needsToDrawRect:subviewDrawFrame]) {
                NSColor *pageColor = _pageDataSourceRespondsToColorForPage ? [_pageDataSource pagedView:self colorForPage:pageIndex] : [NSColor whiteColor];

                if (!self.isPrinting) {
                    [_pageBorder drawBorderInRect:[_pageBorder rectForContentRect:subviewFrame] controlView:self];
                }

                [pageColor set];
                NSRectFill(subviewFrame);
            }
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    if ([NSGraphicsContext currentContextDrawingToScreen]) {
        // Don't draw the background and ornaments, like drop shadows, when printing.
        NSUInteger pageCount = [_pageDataSource pageCountForPagedView:self];

        if (_backgroundColor != nil) {
            [_backgroundColor set];
            NSRectFill(dirtyRect);
        }

        if (_masterPageDisplay == AJRMasterPageDisplaySingle) {
            [self _drawPageViewForPageIndex:AJRPageIndexMasterSingle inRect:dirtyRect];
        }
        if (_masterPageDisplay == AJRMasterPageDisplayDouble) {
            [self _drawPageViewForPageIndex:AJRPageIndexMasterEven inRect:dirtyRect];
            [self _drawPageViewForPageIndex:AJRPageIndexMasterOdd inRect:dirtyRect];
        }

        for (NSInteger pageNumber = 0; pageNumber < pageCount; pageNumber++) {
            [self _drawPageViewForPageIndex:pageNumber inRect:dirtyRect];
        }
    }
}

- (void)viewDidMoveToSuperview {
    [[self superview] addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self superview] attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [[self superview] addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self superview] attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
}

#pragma mark - Page Data Source

- (void)reloadPages {
    NSMutableSet *subviewsToRemove = [_subviewIndex mutableCopy];
    
    if (_pageDataSource) {
        NSView *view;
        NSUInteger pageCount = [_pageDataSource pageCountForPagedView:self];
        
        if (_masterPageDisplay == AJRMasterPageDisplaySingle) {
            view = [_pageDataSource pagedView:self viewForPage:AJRPageIndexMasterSingle];
            [self addSubview:view];
            [view setNeedsDisplay:YES];
            [subviewsToRemove removeObject:view];
        }
        if (_masterPageDisplay == AJRMasterPageDisplayDouble) {
            view = [_pageDataSource pagedView:self viewForPage:AJRPageIndexMasterEven];
            [self addSubview:view];
            [subviewsToRemove removeObject:view];
            view = [_pageDataSource pagedView:self viewForPage:AJRPageIndexMasterOdd];
            [self addSubview:view];
            [view setNeedsDisplay:YES];
            [subviewsToRemove removeObject:view];
        }
        
        for (NSInteger pageNumber = 0; pageNumber < pageCount; pageNumber++) {
            view = [_pageDataSource pagedView:self viewForPage:pageNumber];
            [self addSubview:view];
            [view setNeedsDisplay:YES];
            [subviewsToRemove removeObject:view];
        }
    }
    
    for (NSView *view in subviewsToRemove) {
        [view removeFromSuperview];
    }

    [self setNeedsDisplay:YES];
    [self setNeedsUpdateConstraints:YES];
}

#pragma mark - Scrolling

- (void)scrollPageToVisible:(NSInteger)pageIndex {
    [self scrollPagesToVisible:[NSIndexSet indexSetWithIndex:pageIndex]];
}

- (void)scrollPagesToVisible:(NSIndexSet *)pageIndex {
    if ([pageIndex count]) {
        __block NSRect pagesRect;
        
        pagesRect = [[_pageDataSource pagedView:self viewForPage:[pageIndex firstIndex]] frame];
        
        [pageIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            pagesRect = NSUnionRect(pagesRect, [[self->_pageDataSource pagedView:self viewForPage:idx] frame]);
        }];
        
        [self scrollRectToVisible:pagesRect];
    }
}

- (void)_addPage:(NSInteger)pageIndex toIndexSet:(NSMutableIndexSet *)visibleIndexes ifInVisibleRect:(NSRect)visibleRect {
    NSView *view = [_pageDataSource pagedView:self viewForPage:pageIndex];

    if (view) {
        if (NSIntersectsRect([view frame], visibleRect)) {
            [visibleIndexes addIndex:pageIndex];
        }
    }
}

- (NSIndexSet *)visiblePageIndexes {
    NSMutableIndexSet *visibleIndexes = [NSMutableIndexSet indexSet];
    NSRect visibleRect = [self visibleRect];
    NSInteger pageCount = [_pageDataSource pageCountForPagedView:self];
    
//    if (_masterPageDisplay == AJRMasterPageDisplaySingle) {
//        [self _addPage:AJRPageIndexMasterSingle toIndexSet:visibleIndexes ifInVisibleRect:visibleRect];
//    }
//    if (_masterPageDisplay == AJRMasterPageDisplayDouble) {
//        [self _addPage:AJRPageIndexMasterOdd toIndexSet:visibleIndexes ifInVisibleRect:visibleRect];
//        [self _addPage:AJRPageIndexMasterEven toIndexSet:visibleIndexes ifInVisibleRect:visibleRect];
//    }
    
    for (NSInteger x = 0; x < pageCount; x++) {
        [self _addPage:x toIndexSet:visibleIndexes ifInVisibleRect:visibleRect];
    }
    
    return visibleIndexes;
}

+ (NSSet *)keyPathsForValuesAffectingVisiblePageString {
    return [NSSet setWithObjects:@"visiblePageIndexes", nil];
}

- (NSString *)visiblePageString {
    NSMutableString *string = [NSMutableString string];
    
    [[self visiblePageIndexes] enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        if ([string length]) {
            [string appendString:@", "];
        }
        if (range.length == 1) {
            [string appendFormat:@"%lu", range.location + 1];
        } else {
            [string appendFormat:@"%lu-%lu", range.location + 1, range.location + range.length];
        }
    }];
    
    return string;
}

#pragma mark - Printing

- (BOOL)knowsPageRange:(NSRangePointer)range {
    range->location = 0;
    range->length = [_pageDataSource pageCountForPagedView:self] + 1;
    return YES;
}

- (NSRect)rectForPage:(NSInteger)page {
    _printingPage = page;
    NSRect rect = NSIntegralRect([[_pageDataSource pagedView:self viewForPage:_printingPage - 1] frame]);
    return rect;
}

- (NSPoint)locationOfPrintRect:(NSRect)rect {
    return NSZeroPoint;
}

- (void)beginDocument {
    NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
    info.isPrinting = YES;
    info.scalingFactor = 1.0 / self.scale;
}

- (void)endDocument {
    NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
    info.isPrinting = NO;
}

- (void)beginPageInRect:(NSRect)rect atPlacement:(NSPoint)location {
    [super beginPageInRect:rect atPlacement:location];
}

- (BOOL)isPrinting {
    return [NSPrintInfo.sharedPrintInfo.dictionary[@"AJRIsPrinting"] boolValue];
}

- (IBAction)print:(id)sender {
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    [printInfo setPaperSize:[[_pageDataSource pagedView:self viewForPage:0] frame].size];
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:self printInfo:printInfo];

    [printOperation runOperationModalForWindow:[self window] delegate:nil didRunSelector:NULL contextInfo:NULL];
}

- (BOOL)prepareViewForPrinting:(NSView *)view {
    if (self.isPrinting) {
        CGFloat scale = 1.0 / self.scale;
        NSRect bounds = view.bounds;
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0.0 yBy:bounds.size.height - (bounds.size.height * scale)];
        [transform scaleBy:scale];
        [transform concat];
        objc_setAssociatedObject(view, @selector(prepareViewForPrinting:), transform, OBJC_ASSOCIATION_RETAIN);
        return YES;
    }
    return NO;
}

- (void)concludePrintingInView:(NSView *)view {
    NSAffineTransform *transform = objc_getAssociatedObject(view, @selector(prepareViewForPrinting:));
    if (transform) {
        [transform invert];
        [transform concat];
    }
}

#pragma mark - Ruler Support

- (NSArray<NSView *> *)horizontalViews {
    return [[self pageLayout] horizontalViews];
}

- (NSArray<NSView *> *)verticalViews {
    return [[self pageLayout] verticalViews];
}

@end

@implementation NSView (AJRPagedViewExtensions)

- (AJRPagedView *)enclosingPagedView {
    return AJRObjectIfKindOfClass([self enclosingViewOfType:AJRPagedView.class], AJRPagedView);
}

@end
