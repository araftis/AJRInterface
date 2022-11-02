/*
 AJRSectionView.m
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

#import "AJRSectionView.h"

#import "AJRSectionViewItem.h"
#import <AJRInterfaceFoundation/AJRTrigonometry.h>
#import "NSBezierPath+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>
#import <QuartzCore/QuartzCore.h>

@implementation AJRSectionView

#pragma mark Initialization

- (void)_completeInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_checkActiveColor:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_checkActiveColor:) name:NSApplicationDidResignActiveNotification object:NSApp];    
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _sections = [[NSMutableArray alloc] init];
        _viewsToInsert = [[NSMutableArray alloc] init];
        _viewsToRemove = [[NSMutableArray alloc] init];
        _viewsToResize = [[NSMutableSet alloc] init];
        
        self.titleActiveBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                              [NSColor colorWithCalibratedRed:229.0/255.0 green:231.0/255.0 blue:240.0/255.0 alpha:1.0], 0.0,
                                              [NSColor colorWithCalibratedRed:229.0/255.0 green:231.0/255.0 blue:240.0/255.0 alpha:1.0], 0.5,
                                              [NSColor colorWithCalibratedRed:194.0/255.0 green:203.0/255.0 blue:219.0/255.0 alpha:1.0], 0.5,
                                              [NSColor colorWithCalibratedRed:217.0/255.0 green:222.0/255.0 blue:234.0/255.0 alpha:1.0], 1.0,
                                              nil];
        self.titleInactiveBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                                [NSColor colorWithCalibratedWhite:0.91 alpha:1.0], 0.0,
                                                [NSColor colorWithCalibratedWhite:0.91 alpha:1.0], 0.5,
                                                [NSColor colorWithCalibratedWhite:0.79 alpha:1.0], 0.5,
                                                [NSColor colorWithCalibratedWhite:0.87 alpha:1.0], 1.0,
                                                nil];
        self.titleHighlightBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                                 [NSColor colorWithCalibratedRed:195.0/255.0 green:199.0/255.0 blue:210.0/255.0 alpha:1.0], 0.0,
                                                 [NSColor colorWithCalibratedRed:195.0/255.0 green:199.0/255.0 blue:210.0/255.0 alpha:1.0], 0.5,
                                                 [NSColor colorWithCalibratedRed:157.0/255.0 green:170.0/255.0 blue:186.0/255.0 alpha:1.0], 0.5,
                                                 [NSColor colorWithCalibratedRed:184.0/255.0 green:192.0/255.0 blue:204.0/255.0 alpha:1.0], 1.0,
                                                 nil];
        
        self.titleAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor colorWithDeviceWhite:104.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                [NSFont boldSystemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName,
                                nil];
                
        // This starts at one, because it indicates we're at 100% of our desired position
        _arrowProgress = 1.0;
        
        [self _completeInit];
    }
    return self;
}

- (void)dealloc {
     _sections = nil;
     _viewsToInsert = nil;
     _viewsToRemove = nil;
     _viewsToResize = nil;
     _activeBackgroundColor = nil;
     _inactiveBackgroundColor = nil;
     _titleAttributes = nil;
     _titleActiveBackgroundGradient = nil;
     _titleInactiveBackgroundGradient = nil;
     _titleHighlightBackgroundGradient = nil;
     _titleActiveColor = nil;
     _titleInactiveColor = nil;
}

#pragma mark Properties

@synthesize suppressAnimation = _suppressAnimation;
@synthesize delegate = _delegate;
@synthesize activeBackgroundColor = _activeBackgroundColor;
@synthesize inactiveBackgroundColor = _inactiveBackgroundColor;
@synthesize titleAttributes = _titleAttributes;
@synthesize titleHeight = _titleHeight;
@synthesize titleActiveBackgroundGradient = _titleActiveBackgroundGradient;
@synthesize titleInactiveBackgroundGradient = _titleInactiveBackgroundGradient;
@synthesize titleHighlightBackgroundGradient = _titleHighlightBackgroundGradient;
@synthesize titleActiveColor = _titleActiveColor;
@synthesize titleInactiveColor = _titleInactiveColor;
@synthesize bordered = _bordered;

- (void)setBordered:(BOOL)flag {
    if ((flag && !_bordered) || (!flag && _bordered)) {
        _bordered = flag;
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat)arrowProgress {
    return _arrowProgress;
}

- (void)setArrowProgress:(CGFloat)progress {
    if (_arrowProgress != progress) {
        _arrowProgress = progress;
        [self setNeedsDisplay:YES];
    }
}

- (void)setActiveBackgroundColor:(NSColor *)color {
    if (color != _activeBackgroundColor) {
        _activeBackgroundColor = color;
        [self setNeedsDisplay:YES];
    }
}

- (void)setInactiveBackgroundColor:(NSColor *)color {
    if (color != _inactiveBackgroundColor) {
        _inactiveBackgroundColor = color;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleHeight:(CGFloat)height {
    if (height != _titleHeight) {
        _titleHeight = height;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleActiveBackgroundGradient:(NSGradient *)gradient {
    if (gradient != _titleActiveBackgroundGradient) {
        _titleActiveBackgroundGradient = gradient;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleInactiveBackgroundGradient:(NSGradient *)gradient {
    if (gradient != _titleInactiveBackgroundGradient) {
        _titleInactiveBackgroundGradient = gradient;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleHighlightBackgroundGradient:(NSGradient *)gradient {
    if (gradient != _titleHighlightBackgroundGradient) {
        _titleHighlightBackgroundGradient = gradient;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleActiveColor:(NSColor *)color {
    if (color != _titleActiveColor) {
        _titleActiveColor = color;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleInactiveColor:(NSColor *)color {
    if (color != _titleInactiveColor) {
        _titleInactiveColor = color;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleAttributes:(NSDictionary *)attributes {
    if (_titleAttributes != attributes) {
        NSFont        *font;
        
        _titleAttributes = [attributes copy];
        
        // Recompute the title height.
        font = [_titleAttributes objectForKey:NSFontAttributeName];
        if (font == nil) {
            font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
        }
        self.titleHeight = ceil([font capHeight] - [font descender] + (fabs([font descender] * 3.0)));
        
        // And mark ourself as dirty.
        [self setNeedsDisplay:YES];
    }
}

- (void)setDelegate:(id <AJRSectionViewDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateRespondsToShouldCollapse = [_delegate respondsToSelector:@selector(sectionView:shouldCollapseView:)];
        _delegateRespondsToWillCollapse = [_delegate respondsToSelector:@selector(sectionView:willCollapseView:)];
        _delegateRespondsToDidCollapse = [_delegate respondsToSelector:@selector(sectionView:didCollapseView:)];
        _delegateRespondsToShouldExpand = [_delegate respondsToSelector:@selector(sectionView:shouldExpandView:)];
        _delegateRespondsToWillExpand = [_delegate respondsToSelector:@selector(sectionView:willExpandView:)];
        _delegateRespondsToDidExpand = [_delegate respondsToSelector:@selector(sectionView:didExpandView:)];
    }
}

#pragma mark Managing Animation

- (void)suppressAnimation {
    _suppressAnimation = YES;
}

- (void)enableAnimation {
    _suppressAnimation = NO;
}


#pragma mark Layout

- (NSRect)rectForSection:(AJRSectionViewItem *)item {
    NSRect        bounds = [self bounds];
    
    for (NSInteger x = 0, max = [_sections count]; x < max; x++) {
        AJRSectionViewItem    *section = [_sections objectAtIndex:x];
        NSString            *title = [section title];
        
        bounds.size.height = [section desiredSize].height;

        if (title) bounds.origin.y += _titleHeight;

        if (section == item) return bounds;
        
        bounds.origin.y += bounds.size.height;
        if (title && ![section isExpanded]) bounds.origin.y -= 1.0;
    }
    
    return NSZeroRect;
}

- (NSRect)titleRectForSection:(AJRSectionViewItem *)section {
    if ([section title]) {
        NSRect    bounds = [[section view] frame];
        bounds.origin.y = bounds.origin.y - _titleHeight;
        bounds.size.height = _titleHeight;
        return bounds;
    }
    return NSZeroRect;
}

- (void)_basicTile {
    NSRect        frame = [self frame];
    NSRect        bounds = [self bounds];
    
    _isTiling = YES;
    
    // First, add any new subviews
    for (NSDictionary *container in _viewsToInsert) {
        NSView                    *subview = [container objectForKey:@"subview"];
        NSView                    *otherView = [container objectForKey:@"relativeTo"];
        NSWindowOrderingMode    place = [[container objectForKey:@"place"] integerValue];
        
        [super addSubview:subview positioned:place relativeTo:otherView];
    }
    [_viewsToInsert removeAllObjects];
    
    // Second, then remove any subviews
    for (NSDictionary *container in _viewsToRemove) {
        NSView                    *subview = [container objectForKey:@"subview"];
        
        [subview removeFromSuperview];
    }
    [_viewsToRemove removeAllObjects];
    
    // Will we want replacement views?
    
    // Finally, resize and place the views.
    for (NSInteger x = 0, max = [_sections count]; x < max; x++) {
        AJRSectionViewItem    *section = [_sections objectAtIndex:x];
        NSString            *title = [section title];
        
        bounds.size.height = [section desiredSize].height;
        if (title) bounds.origin.y += _titleHeight;
        [[section view] setFrame:bounds];
        bounds.origin.y += bounds.size.height;
        if (title && ![section isExpanded]) bounds.origin.y -= 1.0;
    }
    
    // And resize ourself, if we're in a scroll view.
    if ([[self superview] isKindOfClass:[NSClipView class]]) {
        frame.size.height = bounds.origin.y;
        if ([_delegate respondsToSelector:@selector(sectionView:willResizeTo:byAnimating:)]) {
            [_delegate sectionView:self willResizeTo:frame.size byAnimating:NO];
        }
        [self setFrame:frame];
    }
    
    _isTiling = NO;
    
    [self updateTrackingAreas];
}

- (void)_animatedTile {
    NSRect        frame = [self frame];
    NSRect        bounds = [self bounds];
    
    [NSAnimationContext beginGrouping];
    
    _isTiling = YES;
    
    // Clear out list of resizing views
    [_viewsToResize removeAllObjects];
    
    // First, add any new subviews
    for (NSDictionary *container in _viewsToInsert) {
        NSView                    *subview = [container objectForKey:@"subview"];
        NSView                    *otherView = [container objectForKey:@"relativeTo"];
        NSWindowOrderingMode    place = [[container objectForKey:@"place"] integerValue];
        
        [[self animator] addSubview:subview positioned:place relativeTo:otherView];
    }
    [_viewsToInsert removeAllObjects];
    
    // Second, then remove any subviews
    for (NSDictionary *container in _viewsToRemove) {
        NSView                    *subview = [container objectForKey:@"subview"];
        
        [[subview animator] removeFromSuperview];
    }
    [_viewsToRemove removeAllObjects];
    
    // Will we want replacement views?
    
    // Finally, resize and place the views.
    for (NSInteger x = 0, max = [_sections count]; x < max; x++) {
        AJRSectionViewItem    *section = [_sections objectAtIndex:x];
        NSString            *title = [section title];
        
        bounds.size.height = [section desiredSize].height;
        // Note if this frame is resizing or not
        if ([[section view] frame].size.height != bounds.size.height) {
            [_viewsToResize addObject:section];
        }
        if (title) bounds.origin.y += _titleHeight;
        [(NSView *)[[section view] animator] setFrame:bounds];
        bounds.origin.y += bounds.size.height;
        if (title && ![section isExpanded]) bounds.origin.y -= 1.0;
    }
    
    // And resize ourself, if we're in a scroll view.
    if ([[self superview] isKindOfClass:[NSClipView class]]) {
        frame.size.height = bounds.origin.y;
        if ([_delegate respondsToSelector:@selector(sectionView:willResizeTo:byAnimating:)]) {
            [_delegate sectionView:self willResizeTo:frame.size byAnimating:YES];
        }
        [(NSView *)[self animator] setFrame:frame];
    }
    
    // And we animate the arrowProgress property.
    _arrowProgress = 0.0;
    [[self animator] setArrowProgress:1.0];
     
    _isTiling = NO;    

    [self performSelector:@selector(updateTrackingAreas) withObject:nil afterDelay:[[NSAnimationContext currentContext] duration] + 0.1];

    [NSAnimationContext endGrouping];
    
}

- (void)_tile {
    if (_suppressAnimation) {
        [self _basicTile];
    } else {
        [self _animatedTile];
    }
     _sectionSnapshots = nil;
    [self setNeedsDisplay:YES];
}

- (void)prepareToTile {
    if (!_suppressAnimation) {
        [self tile];
    }
}

- (void)tile {
    if (_suppressAnimation) {
        [self _tile];
    } else {
        if (_sectionSnapshots == nil) {
            NSRect        rect = [self bounds];

            rect.size.height = 0.0;
            _sectionSnapshots = [[NSMutableArray alloc] init];
            
            for (AJRSectionViewItem *section in _sections) {
                NSDictionary    *snapshot;

                rect.size.height = [section desiredSize].height;
                snapshot = [[NSDictionary alloc] initWithObjectsAndKeys:
                            section, @"section",
                            [NSValue valueWithRect:rect], @"rect",
                            nil];
                rect.origin.y += rect.size.height;
            }
            
            // Push the actual tile to the end of the current runloop. This allows a caller to change
            // multiple things about our layout, which we can then animate as a single unit.
            [self performSelector:@selector(_tile) withObject:nil afterDelay:0.0];
        }
    }
}

#pragma mark Drawing

- (void)drawSectionTitle:(AJRSectionViewItem *)section inRect:(NSRect)rect {
    NSString    *title = [section title];
    BOOL        first = [_sections count] && [_sections objectAtIndex:0] == section;
    
    if (title) {
//        NSRect            bounds = [[section view] frame];
        NSPoint            center;
        NSBezierPath    *path;
        CGFloat            radius;
        CGFloat            startAngle, angleOffset = 0.0;
        
        // Compute our title boudns.
//        bounds.origin.y = bounds.origin.y - _titleHeight;
//        bounds.size.height = _titleHeight;
        
        // And see if we need to draw it
        if ([NSApp isActive]) {
            if ([self isSectionHighlighted:section]) {
                [_titleHighlightBackgroundGradient drawInRect:rect angle:90.0];
            } else {
                [_titleActiveBackgroundGradient drawInRect:rect angle:90.0];
            }
        } else {
            [_titleInactiveBackgroundGradient drawInRect:rect angle:90.0];
        }
        
        [[NSColor colorWithDeviceWhite:142.0 / 255.0 alpha:1.0] set];
        if (!first || _bordered) {
            [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x, rect.origin.y + 0.5} toPoint:(NSPoint){rect.origin.y + rect.size.width, rect.origin.y + 0.5}];
        }
        [NSBezierPath strokeLineFromPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - 0.5} toPoint:(NSPoint){rect.origin.y + rect.size.width, rect.origin.y + rect.size.height - 0.5}];
        
        center.x = round(_titleHeight / 2.0) + 0.0;
        center.y = round(NSMidY(rect)) - 1.0;
        radius = ceil([[_titleAttributes objectForKey:NSFontAttributeName] capHeight] / 2.0) + 0.5;
        path = [[NSBezierPath alloc] init];
        startAngle = [section isExpanded] ? 90.0 : 0.0;
        if ([_viewsToResize containsObject:section]) {
            if ([section isExpanded]) {
                angleOffset = (1.0 - _arrowProgress) * -90.0;
            } else {
                angleOffset = (1.0 - _arrowProgress) * 90.0;
            }
        } else {
            angleOffset = 0.0;
        }
        for (CGFloat angle = startAngle; angle < 360.0; angle += 120.0) {
            NSPoint    where;
            
            where.x = AJRCos(angle + angleOffset) * radius + center.x;
            where.y = AJRSin(angle + angleOffset) * radius + center.y;
            
            if (angle == startAngle) {
                [path moveToPoint:where];
            } else {
                [path lineToPoint:where];
            }
        }
        [path closePath];
        [path fill];

        rect.origin.x += center.x + radius + 5.0; rect.size.width -= center.x + radius + 5.0;
        [title drawInRect:rect withAttributes:_titleAttributes];
    }
}

#pragma mark NSView

- (BOOL)isOpaque {
    return NO;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    if (!_isTiling) {
        [self _basicTile];
    }
}

- (void)addSubview:(NSView *)subview {
    if (_isTiling) {
        [super addSubview:subview];
    } else {
        [self addSubview:subview positioned:NSWindowAbove relativeTo:nil expanded:YES];
    }
}

- (void)addSubview:(NSView *)subview expanded:(BOOL)expanded {
    [self addSubview:subview positioned:NSWindowAbove relativeTo:nil expanded:expanded];
}

- (void)addSubview:(NSView *)subview withTitle:(NSString *)title expanded:(BOOL)expanded; {
    [self addSubview:subview withTitle:title positioned:NSWindowAbove relativeTo:nil expanded:expanded];
}

- (void)addSubview:(NSView *)aView positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView; {
    if (_isTiling) {
        [super addSubview:aView positioned:place relativeTo:otherView];
    } else {
        [self addSubview:aView positioned:place relativeTo:otherView expanded:YES];
    }
}

- (void)addSubview:(NSView *)subview positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView expanded:(BOOL)expanded {
    [self addSubview:subview withTitle:nil positioned:place relativeTo:otherView expanded:expanded];
}

- (void)addSubview:(NSView *)subview withTitle:(NSString *)title positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView expanded:(BOOL)expanded {
    AJRSectionViewItem    *section;
    NSUInteger            index;
    
    NSAssert(_isTiling == NO, @"You cannot add a subview while tiling.");

    // We do this first, because it allows us to detect view additions.
    [self prepareToTile];
    
    // Create one of our sections, which we use to track the subview's state.
    section = [[AJRSectionViewItem alloc] initWithView:subview sectionView:self];
    [section setTitle:title];
    if (otherView != nil && (index = [self indexOfSection:[self sectionForView:otherView]]) != NSNotFound) {
        [_sections insertObject:section atIndex:place == NSWindowAbove ? index + 1 : index];
    } else {
        if (place == NSWindowAbove) {
            [_sections addObject:section];
        } else {
            [_sections insertObject:section atIndex:0];
        }
    }
    [section setExpanded:expanded];
    
    // And also add the subview to ourself.
    [_viewsToInsert addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               subview, @"subview",
                               [NSNumber numberWithInteger:place], @"place",
                               otherView, @"relativeTo",
                               nil]];
    [subview setAutoresizingMask:0]; // Our subviews may not resize themselves.
    
    // Finally, tile ourself. If we're animating, this tiles and adds teh subviews immediately.
    [self tile];
}

- (void)drawRect:(NSRect)rect {
    NSColor        *backgroundColor = nil;
    
    if ([NSApp isActive] && _activeBackgroundColor) {
        backgroundColor = _activeBackgroundColor;
    } else if (_inactiveBackgroundColor) {
        backgroundColor = _inactiveBackgroundColor;
    }
    
    if (backgroundColor) {
        [backgroundColor set];
        NSRectFill(rect);
    }
    
    for (AJRSectionViewItem *section in _sections) {
        NSRect    bounds = [self titleRectForSection:section];
        if (NSIntersectsRect(bounds, rect)) {
            [self drawSectionTitle:section inRect:bounds];
        }
    }
}

#pragma mark NSView - Tracking Areas

- (void)updateTrackingAreas {
    for (NSTrackingArea *area in [[self trackingAreas] copy]) {
        [self removeTrackingArea:area];
    }
    
    for (AJRSectionViewItem *item in _sections) {
        NSRect    titleRect = [self titleRectForSection:item];
        
        if (titleRect.size.height > 0.0) {
            //AJRPrintf(@"%C: Tracking area: %@ %R\n", self, [item title], titleRect);
            [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:titleRect options:NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited owner:self userInfo:nil]];
        }
    }
}

#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)mouse {
    //NSPoint                where = [self convertPoint:[mouse locationInWindow] fromView:nil];
    //AJRSectionViewItem    *section = [self sectionForPoint:where];
    
    //AJRPrintf(@"%C: down section: %@\n", self, [section title]);
}

- (void)mouseDragged:(NSEvent *)mouse {
    //NSPoint                where = [self convertPoint:[mouse locationInWindow] fromView:nil];
    //AJRSectionViewItem    *section = [self sectionForPoint:where];
    
    //AJRPrintf(@"%C: dragged section: %@\n", self, [section title]);
}

- (void)mouseUp:(NSEvent *)mouse {
    NSPoint                where = [self convertPoint:[mouse locationInWindow] fromView:nil];
    AJRSectionViewItem    *section = [self sectionForPoint:where];
    
    //AJRPrintf(@"%C: up section: %@\n", self, [section title]);
    
    if (section) {
        if ([section isExpanded]) {
            if (!_delegateRespondsToShouldCollapse || (_delegateRespondsToShouldCollapse && [_delegate sectionView:self shouldCollapseView:[section view]])) {
                [self collapseView:[section view]];
            }
        } else {
            if (!_delegateRespondsToShouldExpand || (_delegateRespondsToShouldExpand && [_delegate sectionView:self shouldExpandView:[section view]])) {
                [self expandView:[section view]];
            }
        }
    }
}

- (void)mouseEntered:(NSEvent *)event {
    NSPoint                where = [self convertPoint:[event locationInWindow] fromView:nil];
    AJRSectionViewItem    *section = [self sectionForPoint:where];
    
    if (_highlightedSection) {
        [self setNeedsDisplayInRect:[self titleRectForSection:_highlightedSection]];
         _highlightedSection = nil;
    }
    if (section && [section title]) {
        _highlightedSection = section;
        [self setNeedsDisplayInRect:[self titleRectForSection:section]];
    }
    
    //AJRPrintf(@"%C: %s section: %@\n", self, __PRETTY_FUNCTION__, [section title]);
}

- (void)mouseExited:(NSEvent *)event {
    NSPoint                where = [self convertPoint:[event locationInWindow] fromView:nil];
    AJRSectionViewItem    *section = [self sectionForPoint:where];

    //AJRPrintf(@"%C: %s section: %@\n", self, __PRETTY_FUNCTION__, [_highlightedSection title]);
    
    if (_highlightedSection) {
        NSRect    updateRect = [self titleRectForSection:_highlightedSection];
         _highlightedSection = nil;
        [self setNeedsDisplayInRect:updateRect];
    }
    if (section && [section title]) {
        _highlightedSection = section;
        [self setNeedsDisplayInRect:[self titleRectForSection:section]];
    }
}

#pragma mark Sections

- (AJRSectionViewItem *)sectionForPoint:(NSPoint)point {
    for (AJRSectionViewItem *section in _sections) {
        NSString    *title = [section title];
        
        if (title) {
            NSRect            bounds = [[section view] frame];
            
            bounds.origin.y = bounds.origin.y - _titleHeight;
            bounds.size.height = _titleHeight;
            
            if (NSPointInRect(point, bounds)) return section;
        }
    }
    return nil;
}

- (AJRSectionViewItem *)sectionForView:(NSView *)view {
    for (AJRSectionViewItem *section in _sections) {
        if ([section view] == view) {
            return section;
        }
    }
    return nil;
}

- (NSUInteger)indexOfSection:(AJRSectionViewItem *)section {
    if (section == nil) return NSNotFound;
    return [_sections indexOfObjectIdenticalTo:section];
}

- (BOOL)isSectionHighlighted:(AJRSectionViewItem *)section {
    return section == _highlightedSection;
}

#pragma mark Managing Section Size

- (BOOL)isViewExpanded:(NSView *)view {
    return [[self sectionForView:view] isExpanded];
}

- (void)expandView:(NSView *)view {
    if (![self isViewExpanded:view]) {
        AJRSectionViewItem    *item = [self sectionForView:view];
        [self prepareToTile];
        if (_delegateRespondsToWillExpand) [_delegate sectionView:self willExpandView:[item view]];
        [item setExpanded:YES];
        [self tile];
        if (_delegateRespondsToDidExpand) [_delegate sectionView:self didExpandView:[item view]];
    }
}

- (void)collapseView:(NSView *)view {
    if ([self isViewExpanded:view]) {
        AJRSectionViewItem    *item = [self sectionForView:view];
        [self prepareToTile];
        if (_delegateRespondsToWillCollapse) [_delegate sectionView:self willCollapseView:[item view]];
        [item setExpanded:NO];
        [self tile];
        if (_delegateRespondsToDidCollapse) [_delegate sectionView:self didCollapseView:[item view]];
    }
}

- (void)setHeight:(CGFloat)height ofView:(NSView *)view; {
    [self prepareToTile];
    [[self sectionForView:view] setHeight:height];
    [self tile];
}

#pragma mark Notification Handling

- (void)_checkActiveColor:(NSNotification *)notification {
    if (_activeBackgroundColor || _inactiveBackgroundColor) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark NSAnimatablePropertyContainer

+ (id)defaultAnimationForKey:(NSString *)key  {
    if ([key isEqualToString:@"arrowProgress"]) {
        return [CABasicAnimation animation];
    } else {
        return [super defaultAnimationForKey:key];
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        _sections = [[coder decodeObjectForKey:@"sections"] mutableCopy];
        
        self.activeBackgroundColor = [coder decodeObjectForKey:@"activeBackgroundColor"];
        self.inactiveBackgroundColor = [coder decodeObjectForKey:@"inactiveBackgroundColor"];
        self.titleAttributes = [coder decodeObjectForKey:@"titleAttributes"];
        self.titleHeight = [coder decodeFloatForKey:@"titleHeight"];
        self.titleActiveBackgroundGradient = [coder decodeObjectForKey:@"titleActiveBackgroundGradient"];;
        self.titleInactiveBackgroundGradient = [coder decodeObjectForKey:@"titleInactiveBackgroundGradient"];
        self.titleHighlightBackgroundGradient = [coder decodeObjectForKey:@"titleHighlightBackgroundGradient"];
        self.titleActiveColor = [coder decodeObjectForKey:@"titleActiveColor"];
        self.titleInactiveColor = [coder decodeObjectForKey:@"titleInactiveColor"];
        self.delegate = [coder decodeObjectForKey:@"delegate"];
        self.bordered = [coder decodeBoolForKey:@"bordered"];

        [self _completeInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    [coder encodeObject:_activeBackgroundColor forKey:@"activeBackgroundColor"];
    [coder encodeObject:_inactiveBackgroundColor forKey:@"inactiveBackgroundColor"];
    [coder encodeObject:_titleAttributes forKey:@"titleAttributes"];
    [coder encodeFloat:_titleHeight forKey:@"titleHeight"];
    [coder encodeObject:_titleActiveBackgroundGradient forKey:@"titleActiveBackgroundGradient"];;
    [coder encodeObject:_titleInactiveBackgroundGradient forKey:@"titleInactiveBackgroundGradient"];
    [coder encodeObject:_titleHighlightBackgroundGradient forKey:@"titleHighlightBackgroundGradient"];
    [coder encodeObject:_titleActiveColor forKey:@"titleActiveColor"];
    [coder encodeObject:_titleInactiveColor forKey:@"titleInactiveColor"];
    [coder encodeObject:_delegate forKey:@"delegate"];
    [coder encodeBool:_bordered forKey:@"bordered"];
}

@end
