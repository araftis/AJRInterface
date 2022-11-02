/*
 AJRExpansionView.m
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

#import "AJRExpansionView.h"

#import "AJRExpansionViewItem.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRExpansionView {
    NSMutableArray *_items;
    NSDictionary *_headerAttributes;
    BOOL *_expanded;
    BOOL _isTiling;
}

- (void)updateHeaderAttributes {
    NSShadow *shadow;
    
    shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor whiteColor]];
    [shadow setShadowOffset:(NSSize){0, -1}];
    [shadow setShadowBlurRadius:1.0];
    
    _headerAttributes = @{
        NSFontAttributeName:_font,
        NSShadowAttributeName:shadow,
        NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:45.0 / 255.0 alpha:1.0],
    };
}

- (void)setup {
    _headerHeight = 19;
    _font = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
    [self updateHeaderAttributes];
    _highlightFocusedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:93.0 / 255.0 green:148.0 / 255.0 blue:214.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithDeviceRed:25.0 / 255.0 green:86.0 / 255.0 blue:173.0 / 255.0 alpha:1.0]];
    //_highlightGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:248.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:169.0 / 255.0 alpha:1.0]];
    _highlightGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:224.0 / 255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:145.0 / 255.0 alpha:1.0]];
    _expanded = NSZoneCalloc(nil, 100, sizeof(BOOL)); // This is "bad", in that the value should be dynamic.
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    if (_expanded != NULL) NSZoneFree(nil, _expanded);
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setFrameSize:(NSSize)aSize {
    // May seem a bit off, but we don't want to invoke the behavior of our superclass, we
    // want to call NSView's implementation instead.
    Method method = class_getInstanceMethod([NSView class], _cmd);
    NSSize oldSize = [self frame].size;
    void (*original)(id, SEL, NSSize) = (void (*)(id, SEL, NSSize))method_getImplementation(method);

    original(self, @selector(setFrameSize:), aSize);
    
    if (!NSEqualSizes(oldSize, aSize)) {
        [self tileWithAnimation:NO];
    }
}

- (BOOL)isFlipped {
    return YES;
}

- (void)_unbindItemsFromTitileKey {
    for (AJRExpansionViewItem *item in _items) {
        [item unbind:@"title"];
    }
}

- (void)_bindItemsToTitleKey {
    [self _unbindItemsFromTitileKey];
    for (AJRExpansionViewItem *item in _items) {
        if (_titleBindingKey != nil) {
            [item bind:@"title" toObject:item withKeyPath:_titleBindingKey options:nil];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)updateRepresentedObjects {
    NSArray *content = [self content];
    NSInteger x, max = [content count];
    
    if ([_items count] != max) {
        [self createExpansionViewItems];
    } else {
        for (x = 0; x < max; x++) {
            AJRExpansionViewItem *item = [_items objectAtIndex:x];
            [item setRepresentedObject:[content objectAtIndex:x]];
        }
        [self _bindItemsToTitleKey];
    }
}

- (NSRect)titleFrameForRect:(NSRect)rect {
    NSRect frame = rect;
    
    frame.origin.x += 20.0;
    frame.size.width -= 20.0;
    
    return frame;
}

- (NSRect)disclosureFrameForRect:(NSRect)rect {
    NSRect frame = rect;
    
    frame.origin.x += 8.0;
    frame.origin.y = round(frame.origin.y + (rect.size.height / 2.0) - (9.0 / 2.0));
    frame.size.width = 9.0;
    frame.size.height = 9.0;
    
    return frame;
}

- (void)drawDisclosureTriangleInRect:(NSRect)frame angle:(CGFloat)angle {
    NSBezierPath *path;

    if (angle == 0.0) {
        path = [[NSBezierPath alloc] init];
        [path moveToPoint:frame.origin];
        [path lineToPoint:(NSPoint){frame.origin.x + 7.0, frame.origin.y + 4.5}];
        [path lineToPoint:(NSPoint){frame.origin.x, frame.origin.y + 9.0}];
        [path fill];
    } else {
        path = [[NSBezierPath alloc] init];
        [path moveToPoint:(NSPoint){frame.origin.x, frame.origin.y}];
        [path lineToPoint:(NSPoint){frame.origin.x + 9.0, frame.origin.y}];
        [path lineToPoint:(NSPoint){frame.origin.x + 4.5, frame.origin.y + 7.0}];
        [path fill];
    }
}

- (void)drawRect:(NSRect)rect {
    NSInteger x, max = [_items count];
    
    for (x = 0; x < max; x++) {
        NSRect                frame;// = [self headerFrameForSection:x];
        AJRExpansionViewItem    *item = [self itemForSection:x];
        
        frame = [[item view] frame];
        frame.size.height = [item title] ? _headerHeight : 1.0;
        frame.origin.y -= frame.size.height;

        if ([item title]) {
            [[NSColor blackColor] set];
            [_highlightGradient drawInRect:frame angle:90.0];
            [[[_items objectAtIndex:x] title] drawInRect:[self titleFrameForRect:frame] withAttributes:_headerAttributes];
            [[_highlightGradient interpolatedColorAtLocation:1.0/3.0] set];
            NSRectFill((NSRect){frame.origin, {frame.size.width, 1.0}});
            
            [[NSColor colorWithCalibratedRed:98.0 / 255.0 green:110.0 / 255.0 blue:128.0 / 255.0 alpha:1.0] set];
            [self drawDisclosureTriangleInRect:[self disclosureFrameForRect:frame] angle:[self isSectionExpanded:x] ? 90.0 : 0.0];
        } else if (x > 0) {
            [[_highlightGradient interpolatedColorAtLocation:2.0/3.0] set];
            NSRectFill((NSRect){frame.origin, {frame.size.width, 1.0}});
        }
    }
}

- (void)removeAllSubviews {
    NSMutableArray *subviews = [[self subviews] copy];
    @try {
        for (NSView *subview in subviews) {
            [subview removeFromSuperview];
        }
    } @finally {
        subviews = nil;
    }
}

- (void)createExpansionViewItems {
    [self removeAllSubviews];

    if (_items == nil) {
        _items = [[NSMutableArray alloc] init];
    } else {
        [_items removeAllObjects];
    }
    
    //AJRPrintf(@"%C: content = %@\n", self, [self content]);
    for (NSInteger x = 0; x < [[self content] count]; x++) {
#warning This is probably wrong. We need to know what the identifier should be.
        AJRExpansionViewItem *newItem = (AJRExpansionViewItem *)[self makeItemWithIdentifier:@"" forIndexPath:[NSIndexPath indexPathWithIndex:x]];
        if (newItem) {
            [self addSubview:[newItem view]];
            [[newItem view] setPostsFrameChangedNotifications:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewDidUpdateFrame:) name:NSViewFrameDidChangeNotification object:[newItem view]];
            [_items addObject:newItem];
        } else {
            //AJRPrintf(@"%@: Failed to create item for %@, itemPrototype %@\n", self, object, [self itemPrototype]);
        }
    }
    
    [self _bindItemsToTitleKey];
    [self tileWithAnimation:NO];
}

- (NSRect)frameForSection:(NSUInteger)section {
    NSRect bounds = [self bounds];
    NSRect frame;
    NSInteger x;
    CGFloat workHeaderHeight = [self headerHeight];
    
    if (![[self itemForSection:0] title]) {
        workHeaderHeight = 1.0;
    }
    
    frame.origin.x = 0.0;
    frame.origin.y = workHeaderHeight;
    frame.size.width = bounds.size.width;
    
    for (x = 0; x <= section; x++) {
        CGFloat height = [[[_items objectAtIndex:x] view] bounds].size.height;
        if (x == section) {
            frame.size.height = height;
        } else {
            if ([self isSectionExpanded:x]) {
                frame.origin.y += (height + workHeaderHeight);
            } else {
                frame.origin.y += workHeaderHeight;
            }
        }
    }
    
    return frame;
}

- (NSRect)headerFrameForSection:(NSUInteger)section {
    NSRect frame = [self frameForSection:section];
    frame.size.height = [self headerHeight];
    frame.origin.y -= frame.size.height;
    return frame;
}

- (NSInteger)sectionForPoint:(NSPoint)aPoint {
    NSInteger x, max = [_items count];
    
    for (x = 0; x < max; x++) {
        if (NSPointInRect(aPoint, [self headerFrameForSection:x])) {
            return x;
        }
    }
    
    return NSNotFound;
}

- (void)tileWithAnimation:(BOOL)animate {
    if (_isTiling) {
        return;
    } else {
        NSArray *subviews = [self subviews];
        NSInteger x, max = [subviews count];
        NSMutableArray *animations = nil;
        NSRect frame = (NSRect){NSZeroPoint, {[self frame].size.width, 0.0}};
        
        _isTiling = YES;
        
        animate = NO;
        
        if (animate) {
            animations = [[NSMutableArray alloc] init];
        }
        
        for (x = 0; x < max; x++) {
            NSView *subview = [subviews objectAtIndex:x];
            
            frame = [self frameForSection:x];
            
            if (animate) {
                // Create the attributes dictionary for the first view.
                NSRect startingFrame = [subview frame];
                
                if (!NSEqualRects(startingFrame, frame)) {
                    NSMutableDictionary        *dictionary = [[NSMutableDictionary alloc] init];
                    // Specify which view to modify.
                    [dictionary setObject:subview forKey:NSViewAnimationTargetKey];
                    // Specify the starting position of the view.
                    [dictionary setObject:[NSValue valueWithRect:startingFrame] forKey:NSViewAnimationStartFrameKey];
                    // Change the ending position of the view.
                    [dictionary setObject:[NSValue valueWithRect:frame] forKey:NSViewAnimationEndFrameKey];
                    [animations addObject:dictionary];
                }
            } else {
                //AJRPrintf(@"%C: %@: subview %d (%@) frame: %R\n", self, [[self itemForSection:x] title], x, subview, frame);
                [subview setFrame:frame];
            }
            [subview setHidden:![self isSectionExpanded:x]];
        }
        
//    if (max == 0) {
//        AJRPrintf(@"%C: break here: %s:%d\n", self, __PRETTY_FUNCTION__, __LINE__);
//    }
        
        NSRect startingFrame = [self frame];
        NSRect myFrame = startingFrame;
        
        myFrame.size.height = frame.origin.y + frame.size.height;
        
        if (animate) {
            // Create the attributes dictionary for the first view.
            
            if (!NSEqualRects(startingFrame, myFrame)) {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                // Specify which view to modify.
                [dictionary setObject:self forKey:NSViewAnimationTargetKey];
                // Specify the starting position of the view.
                [dictionary setObject:[NSValue valueWithRect:startingFrame] forKey:NSViewAnimationStartFrameKey];
                // Change the ending position of the view.
                [dictionary setObject:[NSValue valueWithRect:myFrame] forKey:NSViewAnimationEndFrameKey];
                [animations addObject:dictionary];
            }
        } else {
            [self setFrame:myFrame];
            //AJRPrintf(@"%C: tiled frame: %R\n", self, myFrame);
        }
        
        if ([animations count]) {
            NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
            [animation setDuration:0.0625];
            [animation setAnimationCurve:NSAnimationLinear];
            [animation startAnimation];
        } else {
            [self setNeedsDisplay:YES];
        }
        _isTiling = NO;
    }
}

- (void)_contentChanged:(BOOL)changedFlag regenerate:(BOOL)regenerateFlag {
    //AJRPrintf(@"%C: _contentChanged:%B regenerate:%B\n", self, changedFlag, regenerateFlag);
    if (regenerateFlag) {
        [self createExpansionViewItems];
    }
    if (changedFlag) {
        [self updateRepresentedObjects];
    }
}

- (void)setFont:(NSFont *)aFont {
    if (_font != aFont) {
        _font = aFont;
        [self setNeedsDisplay:YES];
    }
}

- (void)setHeaderHeight:(CGFloat)aHeight {
    if (_headerHeight != aHeight) {
        _headerHeight = aHeight;
        [self setNeedsDisplay:YES];
    }
}

- (void)setHighlightFocusedGradient:(NSGradient *)aGradient {
    if (_highlightFocusedGradient != aGradient) {
        _highlightFocusedGradient = aGradient;
        [self setNeedsDisplay:YES];
    }
}

- (void)setHighlightGradient:(NSGradient *)aGradient {
    if (_highlightGradient != aGradient) {
        _highlightGradient = aGradient;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitleBindingKey:(NSString *)aKey {
    if (_titleBindingKey != aKey) {
        _titleBindingKey = aKey;
        
        [self _bindItemsToTitleKey];
    }
}

- (IBAction)expandAll:(id)sender {
    NSInteger x, max = [_items count];
    for (x = 0; x < max; x++) {
        [self setSection:x expanded:YES];
    }
}

- (IBAction)contractAll:(id)sender {
    NSInteger x, max = [_items count];
    for (x = 0; x < max; x++) {
        [self setSection:x expanded:NO];
    }
}

- (BOOL)isSectionExpanded:(NSUInteger)index {
    AJRExpansionViewItem *item = [self itemForSection:index];
    if ([item title] == nil) return YES;
    return _expanded[index];
}

- (void)setSection:(NSUInteger)index expanded:(BOOL)flag {
    _expanded[index] = flag;
    [self tileWithAnimation:YES];
}

- (AJRExpansionViewItem *)itemForSection:(NSInteger)section {
    return [_items objectAtIndex:section];
}

- (NSInteger)sectionForItem:(AJRExpansionViewItem *)item {
    return [_items indexOfObject:item];
}

- (void)mouseUp:(NSEvent *)event {
    NSInteger section;
    NSPoint where;
    
    where = [self convertPoint:[event locationInWindow] fromView:nil];
    
    section = [self sectionForPoint:where];
    if (section != NSNotFound) {
        NSRect headerFrame = [self headerFrameForSection:section];
        NSRect disclosureRect = [self disclosureFrameForRect:headerFrame];
        
        //AJRPrintf(@"%C: %P, %R, %b\n", self, where, disclosureRect, [self mouse:where inRect:disclosureRect]);
        if ([self mouse:where inRect:disclosureRect]) {
            [self setSection:section expanded:![self isSectionExpanded:section]];
        } else if ([event clickCount] == 2) {
            [self setSection:section expanded:![self isSectionExpanded:section]];
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    NSInteger section;
    NSPoint where;
    
    where = [self convertPoint:[event locationInWindow] fromView:nil];
    
    section = [self sectionForPoint:where];
    if (section != NSNotFound) {
        [[self window] makeFirstResponder:self];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_items forKey:@"items"];
        [coder encodeFloat:_headerHeight forKey:@"headerHeight"];
        [coder encodeObject:_font forKey:@"font"];
        [coder encodeObject:_headerAttributes forKey:@"headerAttributes"];
        [coder encodeObject:_highlightFocusedGradient forKey:@"highlightFocusedGradient"];
        [coder encodeObject:_highlightGradient forKey:@"highlightGradient"];
        [coder encodeObject:_titleBindingKey forKey:@"titleBindingKey"];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"AJRExpansionView only supports keyed coding" userInfo:nil];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        _items = [coder decodeObjectForKey:@"items"];
        _headerHeight = [coder decodeFloatForKey:@"headerHeight"];
        _font = [coder decodeObjectForKey:@"font"];
        _headerAttributes = [coder decodeObjectForKey:@"headerAttributes"];
        _highlightFocusedGradient = [coder decodeObjectForKey:@"highlightFocusedGradient"];
        _highlightGradient = [coder decodeObjectForKey:@"highlightGradient"];
        _titleBindingKey = [coder decodeObjectForKey:@"titleBindingKey"];
        [self setup];
    }
    return self;
}

- (void)subviewDidUpdateFrame:(NSNotification *)notification {
    [self tileWithAnimation:YES];
}

- (BOOL)autoresizesSubviews {
    return NO;
}

@end
