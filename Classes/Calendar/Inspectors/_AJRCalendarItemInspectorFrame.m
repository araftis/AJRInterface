/*
 _AJRCalendarItemInspectorFrame.m
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

#import "_AJRCalendarItemInspectorFrame.h"

#import "AJRBox.h"
#import "AJRCalendarItemInspector.h"
#import "AJRCalendarItemInspectorWindow.h"
#import "AJRCalendarScroller.h"
#import "AJRDropShadowBorder.h"
#import "AJRSolidFill.h"
#import "NSAttributedString+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>

@implementation _AJRCalendarItemInspectorFrame

#pragma mark View Setup

- (NSMutableDictionary *)titleAttributes {
    if (_titleAttributes == nil) {
        NSMutableParagraphStyle    *style;
        
        style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentLeft];
        [style setHyphenationFactor:0.0];
        [style setMaximumLineHeight:19.0];
        
        _titleAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                            [NSFont boldSystemFontOfSize:16.0], NSFontAttributeName,
                            [NSColor colorWithDeviceRed:0.039 green:0.157 blue:0.353 alpha:1.0], NSForegroundColorAttributeName,
                            style, NSParagraphStyleAttributeName,
                            nil];
    }
    return _titleAttributes;
}

- (NSScrollView *)createScrollView {
    NSScrollView *scrollView;
    AJRCalendarScroller *scroller;
    
    scroller = [[AJRCalendarScroller alloc] initWithFrame:NSZeroRect];
    
    scrollView = [[NSScrollView alloc] initWithFrame:[self contentViewFrame]];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setHasVerticalScroller:NO];
    [scrollView setAutohidesScrollers:NO];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setDrawsBackground:NO];
    [scrollView setVerticalScroller:scroller];
    [[scrollView verticalScroller] setControlSize:-1];
    
    return scrollView;
}

- (NSTextField *)titleFieldWithString:(NSString *)value y:(CGFloat)y {
    NSTextField *field;
    NSRect frame;
    NSDictionary *attributes = [self titleAttributes];
    NSAttributedString *string;
    
    string = [[NSAttributedString alloc] initWithString:value attributes:attributes];
    
    frame = [self titleFrame];
    field = [[NSTextField alloc] initWithFrame:frame];
    [field setFont:[attributes objectForKey:NSFontAttributeName]];
    [field setTextColor:[attributes objectForKey:NSForegroundColorAttributeName]];
    [field setAttributedStringValue:string];
    [field setBordered:NO];
    [field setDrawsBackground:NO];
    [field setEditable:NO];
    [field setSelectable:YES];
    [field setFrame:frame];
    [field setDelegate:self];
    [field setFocusRingType:NSFocusRingTypeNone];
    [field setDelegate:self];
    
    return field;
}

- (NSButton *)buttonWithTitle:(NSString *)title forButton:(AJRButtonLocation)location {
    NSButton *button;
    NSRect frame = [self buttonFrameForLocation:location];
    
    button = [[NSButton alloc] initWithFrame:frame];
    [button setButtonType:NSButtonTypeMomentaryLight];
    [button setBezelStyle:NSBezelStyleTexturedRounded];
    [button setTitle:title];
    [button setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [[button cell] setControlSize:NSControlSizeSmall];
    
    return button;
}

#pragma mark Initialization

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        NSColor *color1 = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
        NSColor *color2;
        NSColor *color3;
        CGFloat h,s,b,a;

        _pointerDirection = _AJRPointLeft;

        [[color1 colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
        color2 = [NSColor colorWithDeviceHue:h saturation:s *= 0.95 brightness:b * 0.9 alpha:a];
        color3 = [NSColor colorWithDeviceHue:h saturation:s *= 0.975 brightness:b * 0.95 alpha:a];
        
        _backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:color1, 0.0, 
                               color2, 2.0 / 3.0,
                               color3, 1.0,
                               nil];
        
        _titleField = [self titleFieldWithString:@"This is a Title" y:frame.size.height - 30.0];
        [self addSubview:_titleField];
        
        _scrollView = [self createScrollView];
        [self addSubview:_scrollView];
        
        _rightButton = [self buttonWithTitle:@"Button 1" forButton:AJRButtonRight];
        [self addSubview:_rightButton];
        [_rightButton setTarget:self];
        [_rightButton setAction:@selector(dismiss:)];

        _middleButton = [self buttonWithTitle:@"Button 2" forButton:AJRButtonMiddle];
        [self addSubview:_middleButton];

        _leftButton = [self buttonWithTitle:@"Button 3" forButton:AJRButtonLeft];
        [self addSubview:_leftButton];
        
        _dropShadow = [[AJRDropShadowBorder alloc] init];
        [_dropShadow setShallow:YES];
        
        [self setAutoresizesSubviews:NO];
        
        extraFrame = NSZeroRect;
    }
    return self;
}

- (void)dealloc {
    [_scrollView removeFromSuperview];
    [_titleField removeFromSuperview];
    [_rightButton removeFromSuperview];
    [_middleButton removeFromSuperview];
    [_leftButton removeFromSuperview];

}

#pragma mark Properties

@synthesize scrollView = _scrollView;
@synthesize titleField = _titleField;
@synthesize rightButton = _rightButton;
@synthesize middleButton = _middleButton;
@synthesize leftButton = _leftButton;
@synthesize titleAttributes = _titleAttributes;
@synthesize pointerDirection = _pointerDirection;

- (AJRCalendarItemInspector *)inspector {
    return [(AJRCalendarItemInspectorWindow *)[self window] inspector];
}

- (NSView *)contentView {
    return _contentView;
}

- (void)setContentView:(NSView *)contentView {
    if (_contentView != contentView) {
        _contentView = contentView;

        //AJRPrintf(@"%C: prior: viewFrame: %R\n", self, [_contentView frame]);
        [_scrollView setDocumentView:_contentView];
        //AJRPrintf(@"%C: median: viewFrame: %R\n", self, [_contentView frame]);
        [self tile];
        //AJRPrintf(@"%C: anterior: viewFrame: %R\n", self, [_contentView frame]);
    }
}

- (void)setTitle:(NSString *)title {
    NSAttributedString *string;
    
    string = [[NSAttributedString alloc] initWithString:title ? title : @"" attributes:[self titleAttributes]];
    [_titleField setAttributedStringValue:string];
    [self tile];
}

- (NSTextField *)titleField {
    return _titleField;
}

- (void)setButtonTitle:(NSString *)title 
         keyEquivalent:(NSString *)keyEquivalent
               enabled:(BOOL)enabled
                target:(id)target
                action:(SEL)action
           forLocation:(AJRButtonLocation)location {
    NSButton    *button = [self buttonForLocation:location];
    
    [button setTitle:title ? title : @""];
    [button setEnabled:enabled];
    [button setTarget:target];
    [button setAction:action];
    [button setKeyEquivalent:keyEquivalent ? keyEquivalent : @""];
    
    [self tile];
}

- (void)setPointerDirection:(_AJRPointerDirection)pointerDirection {
    if (_pointerDirection != pointerDirection) {
        _pointerDirection = pointerDirection;
        [self tile];
    }
}

#pragma mark Utilities

- (CGFloat)leftMargin {
    if (_pointerDirection == _AJRPointLeft) {
        return 15.0 + 15.0; // 15.0 is for the left pointer off the edge of the window.
    }
    return 15.0;
}

- (CGFloat)rightMargin {
    if (_pointerDirection == _AJRPointRight) {
        return 7.0 + 15.0;
    }
    return 7.0;
}

- (CGFloat)topMargin {
    if (_pointerDirection == _AJRPointUp) {
        return 15.0 + 15.0;
    }
    return 15.0;
}

- (CGFloat)bottomMargin {
    if (_pointerDirection == _AJRPointDown) {
        return 8.0 + 15.0;
    }
    return 8.0;
}

- (CGFloat)buttonHeight {
    return 25.0;
}

- (CGFloat)buttonGap {
    return 12.0;
}

- (CGFloat)titleGap {
    return 14.0;
}

- (NSButton *)buttonForLocation:(AJRButtonLocation)location {
    switch (location) {
        case AJRButtonRight:
            return _rightButton;
        case AJRButtonMiddle:
            return _middleButton;
        case AJRButtonLeft:
            return _leftButton;
    }
    return nil;
}

- (CGFloat)buttonWidthForLocation:(AJRButtonLocation)location {
    NSButton            *button = [self buttonForLocation:location];
    NSAttributedString    *title;
    
    title = [button attributedTitle];
    if ([title length] != 0) {
        return [title size].width + 40.0;
    }
    
    return 0.0;
}

- (BOOL)isButtonHiddenForLocation:(AJRButtonLocation)location {
    return [[[self buttonForLocation:location] title] length] == 0;
}

- (NSRect)desiredBounds {
    if (_desiredBounds.size.height == 0.0) {
        return [self bounds];
    }
    return _desiredBounds;
}

- (CGFloat)desiredHeight {
    return [self desiredHeightForHeight:[[self contentView] frame].size.height];
}

- (CGFloat)desiredHeightForHeight:(CGFloat)inputHeight {
    CGFloat height;
    NSSize maxSize = [[self window] maxSize];
    
    height = [self topMargin] + [self bottomMargin];
    height += [self titleHeight];
    height += [self titleGap];
    height += (inputHeight + 1); // The +1 is to avoid flicker while animating.
    height += [self buttonGap];
    height += [self buttonHeight];
    
    if (height > maxSize.height) {
        height = maxSize.height;
    }
    
    return height;
}

- (CGFloat)titleHeight {
    NSRect frame = [self desiredBounds];
    CGFloat width = frame.size.width - ([self leftMargin] + [self rightMargin]);
    NSAttributedString *title = [_titleField attributedStringValue];
    
    return [title ajr_sizeConstrainedToWidth:width - 4.0].height + 4.0;
}

- (NSRect)titleFrame {
    NSRect frame = [self desiredBounds];
    CGFloat height = [self titleHeight];
    
    switch (_pointerDirection) {
        case _AJRPointLeft:
            frame.origin.x = [self leftMargin];
            frame.origin.y = frame.size.height - [self topMargin] - height;
            frame.size.width = frame.size.width - ([self leftMargin] + [self rightMargin] * 2.0);
            frame.size.height = height;
            break;
        case _AJRPointRight:
            frame.origin.x = [self leftMargin];
            frame.origin.y = frame.size.height - [self topMargin] - height;
            frame.size.width = frame.size.width - ([self leftMargin] + [self rightMargin]);
            frame.size.height = height;
            break;
        case _AJRPointUp:
            break;
        case _AJRPointDown:
            break;
    }
    
    return frame;
}

- (NSRect)buttonFrameForLocation:(AJRButtonLocation)location {
    NSRect frame = [self desiredBounds];
    CGFloat rightWidth = [self buttonWidthForLocation:AJRButtonRight];
    CGFloat middleWidth = [self buttonWidthForLocation:AJRButtonMiddle];
    CGFloat leftWidth = [self buttonWidthForLocation:AJRButtonLeft];
    CGFloat height = [self buttonHeight];
    
    frame.origin.y = [self bottomMargin];
    frame.size.height = height;
    
    switch (location) {
        case AJRButtonRight:
            frame.origin.x = frame.size.width - [self rightMargin] - 5.0 - rightWidth;
            frame.size.width = rightWidth;
            break;
        case AJRButtonMiddle:
            frame.origin.x = frame.size.width - [self rightMargin] - 5.0 - rightWidth - 10.0 - middleWidth;
            frame.size.width = middleWidth;
            break;
        case AJRButtonLeft:
            frame.origin.x = frame.size.width - [self rightMargin] - 5.0 - rightWidth - 10.0 - middleWidth - 10.0 - leftWidth;
            frame.size.width = leftWidth;
            break;
    }
    
    return frame;
}

- (NSRect)contentViewFrame {
    NSRect    frame = [self desiredBounds];
    NSRect    titleFrame = [self titleFrame];
    
    frame.origin.x = titleFrame.origin.x;
    frame.origin.y = [self bottomMargin] + [self buttonHeight] + [self buttonGap];
    frame.size.width = titleFrame.size.width;
    frame.size.height = titleFrame.origin.y - [self titleGap] - frame.origin.y;
    
    return frame;
}

- (void)tileButtonForLocation:(AJRButtonLocation)location animate:(BOOL)animate {
    NSButton    *button = [self buttonForLocation:location];
    
    //AJRPrintf(@"%C: tiling \"%@\", frame: %R, hidden: %B\n", self, [button title], [self buttonFrameForLocation:location], [self isButtonHiddenForLocation:location]);
    if (animate) {
        [(NSView *)[button animator] setFrame:[self buttonFrameForLocation:location]];
        [[button animator] setHidden:[self isButtonHiddenForLocation:location]];
    } else {
        [button setFrame:[self buttonFrameForLocation:location]];
        [button setHidden:[self isButtonHiddenForLocation:location]];
    }
}

- (void)tile {
    [self tileToContainHeight:[_contentView bounds].size.height withAnimation:NO];
}

- (void)tileToContainHeight:(CGFloat)height withAnimation:(BOOL)animate {
    if (!_isTiling) {
        NSRect titleRect;
        NSRect viewRect;
        NSRect documentVisibleRect;
        NSRect contentViewRect;
        NSRect frame;
        CGFloat desiredHeight, deltaY;
        
        _isTiling = YES;
        if (animate) {
            _desiredBounds = [self bounds];
            _desiredBounds.size.height = [self desiredHeightForHeight:height];
            [NSAnimationContext beginGrouping];
        }
        
        frame = [[self window] frame];
        desiredHeight = [self desiredHeightForHeight:height];
        deltaY = frame.size.height - desiredHeight;
        frame.size.height = desiredHeight;
        frame.origin.y += round(((2.0 / 3.0) * deltaY));
        if (animate) {
            [[[self window] animator] setFrame:frame display:YES];
        } else {
            [[self window] setFrame:frame display:YES];
        }
        
        titleRect = [self titleFrame];
        viewRect = [self contentViewFrame];

        if (animate) {
//            [[_titleField animator] setFrame:titleRect];
//            [[_scrollView animator] setFrame:viewRect];
//            [self tileButtonForLocation:AJRButtonRight animate:YES];
//            [self tileButtonForLocation:AJRButtonMiddle animate:YES];
//            [self tileButtonForLocation:AJRButtonLeft animate:YES];
        } else {
            [_titleField setFrame:titleRect];
            [_scrollView setFrame:viewRect];
            [self tileButtonForLocation:AJRButtonRight animate:NO];
            [self tileButtonForLocation:AJRButtonMiddle animate:NO];
            [self tileButtonForLocation:AJRButtonLeft animate:NO];
        }
        
        contentViewRect = [(NSView *)[_scrollView documentView] frame];
        documentVisibleRect = [_scrollView documentVisibleRect];
        _isScrolling = contentViewRect.size.height > documentVisibleRect.size.height;
        [_scrollView setHasVerticalScroller:_isScrolling];
        
        if (animate) {
            _desiredBounds = NSZeroRect;
            [self performSelector:@selector(_updateIsScrolling) withObject:nil afterDelay:[[NSAnimationContext currentContext] duration] + 0.1];
            [NSAnimationContext endGrouping];
        }
        
        _isTiling = NO;
    }
}

- (void)_updateIsScrolling {
    NSRect contentViewRect = [(NSView *)[_scrollView documentView] frame];
    NSRect documentVisibleRect = [_scrollView documentVisibleRect];
    _isScrolling = contentViewRect.size.height > documentVisibleRect.size.height;
    [_scrollView setHasVerticalScroller:_isScrolling];
    [self tile];
    [self setNeedsDisplay:YES];
    [[self window] invalidateShadow];
}

#pragma mark NSView

//- (void)setBounds:(NSRect)aRect
//{
//    AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
//    [super setFrame:aRect];
//}

- (void)setFrame:(NSRect)frame {
//    AJRPrintf(@"%C: %s\n", self, __PRETTY_FUNCTION__);
    [super setFrame:frame];
    _lastSize = frame.size;
    [self tile];
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    NSBezierPath *path = [[NSBezierPath alloc] init];
    CGFloat arrowY = floor(bounds.size.height * (2.0 / 3.0)) + 0.5;
    NSRect highlightFrame;
    NSView *firstResponder;
    
    if (!NSEqualSizes(_lastSize, bounds.size)) {
        //AJRPrintf(@"%C: %s: %R/%R: %B\n", self, __PRETTY_FUNCTION__, rect, bounds, [self inLiveResize]);
        _lastSize = bounds.size;
        // This is potentially dangerous, let's see if it works.
        [self tile];
    }

    arrowY -= [(AJRCalendarItemInspectorWindow *)[self window] arrowShift];
    
    [NSBezierPath setDefaultLineWidth:1.0];
    
    [[NSColor clearColor] set];
    NSRectFill(bounds);
    
    [[NSColor windowBackgroundColor] set];
    switch (_pointerDirection) {
        default:
        case _AJRPointLeft:
            [path moveToPoint:(NSPoint){bounds.origin.x, bounds.origin.y + arrowY}];
            [path lineToPoint:(NSPoint){bounds.origin.x + 15.0, bounds.origin.y + arrowY + 10.0}];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y + bounds.size.height)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y + bounds.size.height)
                                           toPoint:NSMakePoint(bounds.origin.x + 20.0, bounds.origin.y + bounds.size.height)
                                            radius:5.0];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)
                                           toPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height - 5.0)
                                            radius:5.0];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y)
                                           toPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 5.0, bounds.origin.y)
                                            radius:5.0];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y)
                                           toPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y + 5.0)
                                            radius:5.0];
            [path lineToPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y + arrowY - 10.0)];
            [path closePath];
            break;
        case _AJRPointRight:
            [path moveToPoint:(NSPoint){bounds.origin.x + bounds.size.width, bounds.origin.y + arrowY}];
            [path lineToPoint:(NSPoint){bounds.origin.x + bounds.size.width - 15.0, bounds.origin.y + arrowY + 10.0}];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y + bounds.size.height)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 15.0, bounds.origin.y)
                                           toPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 20.0, bounds.origin.y)
                                            radius:5.0];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x, bounds.origin.y)
                                           toPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + 5.0)
                                            radius:5.0];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + bounds.size.height)
                                           toPoint:NSMakePoint(bounds.origin.x + 5.0, bounds.origin.y + bounds.size.height)
                                            radius:5.0];
            //[path lineToPoint:NSMakePoint(bounds.origin.x + 15.0, bounds.origin.y)];
            [path appendBezierPathWithArcFromPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 15.0, bounds.origin.y + bounds.size.height)
                                           toPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 15.0, bounds.origin.y + bounds.size.height + 5.0)
                                            radius:5.0];
            [path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width - 15.0, bounds.origin.y + arrowY - 10.0)];
            [path closePath];
            break;
    }
    
//    [path fill];
    [_backgroundGradient drawInBezierPath:path angle:90.0];
    
//    [[NSColor lightGrayColor] set];
//    [path stroke];
    
    if (_isScrolling) {
        NSRect        titleRect = [self titleFrame];
        NSRect        contentRect = [self contentViewFrame];
        
        [[[NSColor blackColor] colorWithAlphaComponent:1.0/3.0] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(contentRect.origin.x, titleRect.origin.y - 5.5) 
                                  toPoint:NSMakePoint(contentRect.origin.x + contentRect.size.width, titleRect.origin.y - 5.5)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(contentRect.origin.x, 37.5) 
                                  toPoint:NSMakePoint(contentRect.origin.x + contentRect.size.width, 37.5)];
        [[[NSColor whiteColor] colorWithAlphaComponent:1.0/3.0] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(contentRect.origin.x, titleRect.origin.y - 6.5) 
                                  toPoint:NSMakePoint(contentRect.origin.x + contentRect.size.width, titleRect.origin.y - 6.5)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(contentRect.origin.x, 36.5) 
                                  toPoint:NSMakePoint(contentRect.origin.x + contentRect.size.width, 36.5)];
    }
    
    if (extraFrame.size.width != 0.0) {
        [[NSColor redColor] set];
        NSFrameRect(extraFrame);
    }
    
    
    NSRect contentViewFrame = [self contentViewFrame];
    if (NSEqualRects(rect, contentViewFrame)) {
        [self setNeedsDisplayInRect:(NSRect){{contentViewFrame.origin.x, contentViewFrame.origin.y - 5.0}, {contentViewFrame.size.width, 5.0}}];
    }
    
    firstResponder = (NSView *)[[self window] firstResponder];
    // Finally, draw the drop shadow around the focues control.
    highlightFrame = [self frameForDropShadowForFirstResponder:firstResponder];
    if (!NSEqualRects(highlightFrame, NSZeroRect)) {
        if ([firstResponder isDescendantOf:_scrollView]) {
            highlightFrame = NSIntersectionRect([self convertRect:[_scrollView frame] fromView:[_scrollView superview]], highlightFrame);
        }
        NSRect    shadowFrame = [_dropShadow rectForContentRect:highlightFrame];
        [_dropShadow drawBorderInRect:shadowFrame controlView:self];
        [[NSColor whiteColor] set];
        NSRectFill(highlightFrame);
    }
}

- (BOOL)isOpaque {
    return NO;
}

#pragma mark Actions

- (IBAction)dismiss:(id)sender {
    [(AJRCalendarItemInspectorWindow *)[self window] dismiss:sender];
}

- (NSRect)frameForDropShadowForFirstResponder:(NSResponder *)responder {
    if ([responder isKindOfClass:[NSTextField class]] && [(NSTextField *)responder isEditable]) {
        NSRect frame = [(NSTextField *)responder frame];
        frame.size.height += 1.0;
        return [(NSTextField *)responder convertRect:frame toView:self];
    } else if ([responder isKindOfClass:[NSDatePicker class]] && [(NSDatePicker *)responder isEnabled]) {
        NSRect frame = [(NSDatePicker *)responder frame];
        frame.size.height -= 10.0;
        frame.origin.y += 9.0;
        //frame.origin.x -= frame.size.width;
        return [self convertRect:frame fromView:[(NSDatePicker *)responder superview]];
    } else if ([responder isKindOfClass:[NSTextView class]] && [(NSTextView *)responder isEditable] && [(NSTextView *)responder enclosingScrollView] != nil) {
        NSScrollView    *scrollView = [(NSTextField *)responder enclosingScrollView];
        NSRect frame = [scrollView frame];
        frame.size.height += 2.0;
        frame.origin.y -= 1.0;
        return [[scrollView superview] convertRect:frame toView:self];
    } else if ([responder isKindOfClass:[NSTextView class]] && [(NSTextView *)responder isEditable]) {
        //NSRect frame = [[(NSTextField *)responder enclosingScrollView] frame];
        NSRect frame = [(NSTextField *)responder frame];
        frame.size.height += 2.0;
        frame.origin.y -= 1.0;
        return [(NSTextView *)responder convertRect:frame toView:self];
    }
    return NSZeroRect;
}

#pragma mark NSTextFieldDelegate

- (void)textDidChange:(NSNotification *)notification {
    [self controlTextDidChange:notification];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self tile];
    if ([notification object] == _titleField) {
        [(AJRCalendarItemInspectorWindow *)[self window] _setTitle:[_titleField stringValue]];
        [[self inspector] titleDidChange:[_titleField stringValue]];
    }
    [self setNeedsDisplay:YES];
}

#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)event {
    // If we receive the mouse down, then remove the first responder.
    [[self window] makeFirstResponder:nil];
}

@end

