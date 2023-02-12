/*
 AJRBorder.m
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

#import "AJRBorder.h"

#import "AJRInterfaceFunctions.h"
#import "NSAffineTransform+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

static NSMutableDictionary *_borders = nil;
static NSMutableDictionary *_bordersByName = nil;
static NSMutableDictionary *_borderViews = nil;

NSString *AJRBorderDidUpdateNotification = @"AJRBorderDidUpdateNotification";
NSString *AJRBorderWillUpdateNotification = @"AJRBorderWillUpdateNotification";

@interface NSTabViewItem (Private)

- (void)_invalidLabelSize;

@end


@implementation AJRBorder

+ (void)initialize {
    if (_borders == nil) {
        _borders = [[NSMutableDictionary alloc] init];
        _bordersByName = [[NSMutableDictionary alloc] init];
        _borderViews = [[NSMutableDictionary alloc] init];
    }
    
    //[self setVersion:2];
}

+ (void)registerBorder:(Class)aClass {
    @autoreleasepool {
        [_borders setObject:aClass forKey:NSStringFromClass(aClass)];
        [_bordersByName setObject:aClass forKey:[aClass name]];
    }
}

+ (NSString *)name {
    return @"No Border";
}

- (void)willUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRBorderWillUpdateNotification object:self];
}

- (void)didUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRBorderDidUpdateNotification object:self];
}

+ (NSArray *)borderTypes {
    return [[_borders allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray *)borderNames {
    return [[_bordersByName allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (AJRBorder *)borderForType:(NSString *)type {
    Class aClass = [_borders objectForKey:type];
    
    if (aClass) return [[aClass alloc] init];
    
    return [[[self class] alloc] init];
}

+ (AJRBorder *)borderForName:(NSString *)type {
    Class aClass = [_bordersByName objectForKey:type];
    
    if (aClass) return [[aClass alloc] init];
    
    return [[[self class] alloc] init];
}

- (id)init {
    self = [super init];
    
    selectedTab = 0;
    tabType = NSTopTabsBezelBorder;
    
    return self;
}

- (void)dealloc {
    if (tabSizes != NULL) NSZoneFree(nil, tabSizes);
    
}

@synthesize titleCell = titleCell;

- (void)setTitleCell:(NSTextFieldCell *)cell {
    if (cell != titleCell) {
        [self willUpdate];
        titleCell = cell;
        [self didUpdate];
    }
}

@synthesize titlePosition = titlePosition;

- (void)setTitlePosition:(NSTitlePosition)position {
    if (titlePosition != position) {
        [self willUpdate];
        titlePosition = position;
        [self didUpdate];
    }
}

@synthesize titleAlignment = titleAlignment;

- (void)setTitleAlignment:(NSTextAlignment)alignment {
    if (titleAlignment != alignment) {
        [self willUpdate];
        titleAlignment = alignment;
        [self didUpdate];
    }
}

- (void)setTitle:(NSString *)title {
    [self willUpdate];
    [[self titleCell] setStringValue:title == nil ? @"" : title];
    [self didUpdate];
}

- (NSString *)title {
    return [[self titleCell] title];
}

- (NSSize)titleSize {
    if ([self titlePosition] == NSNoTitle) {
        return NSZeroSize;
    }
    
    return [titleCell cellSize];
}

- (NSRect)titleRectForRect:(NSRect)rect {
    NSSize size = [self titleSize];
    NSRect titleRect = {{0.0, 0.0}, size};
    NSUInteger position = [self titlePosition];
    NSUInteger alignment = [self titleAlignment];
    
    switch (position) {
        case NSNoTitle:
            return NSZeroRect;
        case NSAboveTop:
            titleRect.origin.y = rect.origin.y + rect.size.height - size.height;
            break;
        case NSAtTop:
            titleRect.origin.y = rect.origin.y + rect.size.height - size.height;
            break;
        case NSBelowTop:
            titleRect.origin.y = rect.origin.y + rect.size.height - size.height - 2.0;
            break;
        case NSAboveBottom:
            titleRect.origin.y = rect.origin.y + 2.0;
            break;
        case NSAtBottom:
            titleRect.origin.y = rect.origin.y;
            break;
        case NSBelowBottom:
            titleRect.origin.y = rect.origin.y;
            break;
    }
    
    switch (alignment) {
        case NSTextAlignmentLeft:
            break;
        case NSTextAlignmentCenter:
            titleRect.origin.x = rect.origin.x + (rect.size.width - size.width) / 2.0;
            break;
        case NSTextAlignmentRight:
            titleRect.origin.x = rect.origin.x + rect.size.width - size.width;
            break;
    }
    
    //AJRPrintf(@"%C: %d, %d, titleRect: %R\n", self, position, alignment, titleRect);
    
    return titleRect;
}

- (NSSize)sizeForTab:(NSUInteger)index {
    return [[tabs objectAtIndex:index] sizeOfLabel:tabsCanTruncate];
}

- (void)_updateTabSizes {
    NSInteger x;
    
    if (tabSizes != NULL) NSZoneFree(nil, tabSizes);
    if ([tabs count] == 0) {
        tabSizes = NULL;
    } else {
        tabSizes = (NSSize *)NSZoneMalloc(nil, sizeof(NSSize) * [tabs count]);
    }
    
    if ([tabs count] == 0) return;
    
    for (x = 0; x < (const NSInteger)[tabs count]; x++) {
        [[tabs objectAtIndex:x] _invalidLabelSize];
        tabSizes[x] = [self sizeForTab:x];
        //AJRPrintf(@"%d: %@\n", x, NSStringFromSize(tabSizes[x]));
    }
}

- (CGFloat)marginBetweenTabs:(NSInteger)index1 and:(NSInteger)index2 {
    if (index1 == -1) return 20.0;
    if (index2 == -1) return 20.0;
    return 10.0;
}

- (NSRect)rectForTab:(NSUInteger)index inRect:(NSRect)bounds {
    NSRect rect = NSZeroRect;
    AJRInset inset = [self shadowInset];
    NSInteger x;
    
    if (index >= [tabs count]) return NSZeroRect;
    
    switch (tabType) {
        case NSTopTabsBezelBorder:
            rect.origin.y = bounds.size.height - tabSizes[0].height - 2.0;
            rect.origin.x = [self marginBetweenTabs:-1 and:0];
            rect.size = tabSizes[index];
            rect.size.width += 10.0;
            rect.size.height += 2.0;
            for (x = 0; x < index; x++) {
                rect.origin.x += tabSizes[x].width + [self marginBetweenTabs:x and:x + 1];
            }
            rect.origin.y -= inset.top;
            rect.origin.x += inset.left;
            break;
        case NSBottomTabsBezelBorder:
            rect.origin.y = 0.0;
            rect.origin.x = [self marginBetweenTabs:-1 and:0];
            rect.size = tabSizes[index];
            rect.size.width += 10.0;
            rect.size.height += 2.0;
            for (x = 0; x < index; x++) {
                rect.origin.x += tabSizes[x].width + [self marginBetweenTabs:x and:x + 1];
            }
            rect.origin.y += inset.bottom;
            rect.origin.x += inset.left;
            break;
        case NSLeftTabsBezelBorder:
            rect.origin.x = 0.0;
            rect.origin.y = [self marginBetweenTabs:-1 and:0];
            rect.size.width = tabSizes[index].height + 2.0;
            rect.size.height = tabSizes[index].width + 10.0;
            for (x = 0; x < index; x++) {
                rect.origin.y += tabSizes[x].width + [self marginBetweenTabs:x and:x + 1];
            }
            rect.origin.x += inset.left;
            break;
        case NSRightTabsBezelBorder:
            rect.origin.x = bounds.size.width - tabSizes[0].height - 2.0;
            rect.origin.y = bounds.size.height - [self marginBetweenTabs:-1 and:0] - (tabSizes[0].width + 10.0);
            rect.size.width = tabSizes[index].height + 2.0;
            rect.size.height = tabSizes[index].width + 10.0;
            for (x = 0; x < index; x++) {
                rect.origin.y -= tabSizes[x].width + [self marginBetweenTabs:x and:x + 1];
            }
            rect.origin.x -= inset.right;
            break;
        default:
            break;
    }
    
    return NSIntegralRect(rect);
}

- (void)setTabs:(NSArray *)someTabs {
    if (tabs != someTabs) {
        tabs = someTabs;
        [self _updateTabSizes];
        [self didUpdate];
    }
}

- (NSArray *)tabs {
    return tabs;
}

- (void)setTabsCanTruncate:(BOOL)flag {
    if (tabsCanTruncate != flag) {
        tabsCanTruncate = flag;
        [self _updateTabSizes];
        [self didUpdate];
    }
}

- (BOOL)tabsCanTruncate {
    return tabsCanTruncate;
}

- (void)setTabViewType:(NSTabViewType)aType {
    if (tabType != aType) {
        tabType = aType;
        [self didUpdate];
    }
}

- (NSTabViewType)tabViewType {
    return tabType;
}

- (AJRBorderTabMask)availableTabEdges {
    return AJRBorderTabsNone;
}

- (void)setSelectedTabIndex:(NSUInteger)index {
    if (index != selectedTab) {
        selectedTab = index;
        [self didUpdate];
    }
}

- (BOOL)isOpaque {
    return YES;
}

- (NSRect)contentRectForRect:(NSRect)rect {
    NSSize titleSize = [self titleSize];
    
    switch ([self titlePosition]) {
        case NSNoTitle:
            break;
        case NSAboveTop:
            rect.size.height -= titleSize.height;
            break;
        case NSAtTop:
            rect.size.height -= rint(titleSize.height / 2.0);
            break;
        case NSBelowTop:
            break;
        case NSAboveBottom:
            rect.origin.y = rect.origin.y;
            break;
        case NSAtBottom:
            rect.origin.y += rint(titleSize.height / 2.0);
            rect.size.height -= rint(titleSize.height / 2.0);
            break;
        case NSBelowBottom:
            rect.origin.y += titleSize.height;
            rect.size.height -= titleSize.height;
            break;
    }
    
    return rect;
}

- (NSRect)unclippedContentRectForRect:(NSRect)rect {
    return [self contentRectForRect:rect];
}

- (NSRect)rectForContentRect:(NSRect)rect {
    NSRect work = {{0.0, 0.0}, {100.0, 100.0}};
    NSRect other = [self contentRectForRect:work];
    
    rect.origin.x += (work.origin.x - other.origin.x);
    rect.origin.y += (work.origin.y - other.origin.y);
    rect.size.width += (work.size.width - other.size.width);
    rect.size.height += (work.size.height - other.size.height);
    
    return rect;
}

- (NSBezierPath *)clippingPathForRect:(NSRect)rect {
    return [NSBezierPath bezierPathWithRect:[self contentRectForRect:rect]];
}

- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
}

- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
}

- (void)drawBorderInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView {
    [self drawBorderBackgroundInRect:rect clippedToRect:clippingRect controlView:controlView];
    [self drawBorderForegroundInRect:rect clippedToRect:clippingRect controlView:controlView];
}

- (void)drawBorderInRect:(NSRect)rect controlView:(NSView *)controlView {
    [self drawBorderInRect:rect clippedToRect:rect controlView:controlView];
}

- (void)drawTabTextInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect {
    NSRect tabRect, labelRect;
    NSSize tabSize;
    NSInteger x;
    NSDictionary *attributes = nil;
    
    for (x = 0; x < (const NSInteger)[tabs count]; x++) {
        
        if (attributes == nil) {
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:[[[tabs objectAtIndex:x] tabView] font], NSFontAttributeName, nil];
        }
        
        tabRect = [self rectForTab:x inRect:rect];
        //[[NSColor redColor] set]; NSFrameRect(tabRect);
        tabSize = [[tabs objectAtIndex:x] sizeOfLabel:tabsCanTruncate];
        if (tabType == NSLeftTabsBezelBorder || tabType == NSRightTabsBezelBorder) {
            CGFloat temp = tabSize.width;
            tabSize.width = tabSize.height;
            tabSize.height = temp;
        }
        labelRect = AJRComputeScaledRect(tabRect, tabSize, AJRContentNoScalingMask);
        //[[NSColor blueColor] set]; NSFrameRect(labelRect);
        if (tabType == NSLeftTabsBezelBorder) {
            CGFloat temp = labelRect.size.width;
            labelRect.size.width = labelRect.size.height;
            labelRect.size.height = temp;
            
            [NSGraphicsContext saveGraphicsState];
            [NSAffineTransform translateXBy:labelRect.origin.x yBy:labelRect.origin.y];
            labelRect.origin = (NSPoint){0.0, 0.0};
            [NSAffineTransform rotateByDegrees:90.0];
            [NSAffineTransform translateXBy:0.0 yBy:-labelRect.size.height];
            [[[tabs objectAtIndex:x] label] drawInRect:labelRect withAttributes:attributes];
            [NSGraphicsContext restoreGraphicsState];
        } else if  (tabType == NSRightTabsBezelBorder) {
            CGFloat        temp = labelRect.size.width;
            labelRect.size.width = labelRect.size.height;
            labelRect.size.height = temp;
            
            [NSGraphicsContext saveGraphicsState];
            [NSAffineTransform translateXBy:labelRect.origin.x yBy:labelRect.origin.y];
            labelRect.origin = (NSPoint){0.0, 0.0};
            [NSAffineTransform rotateByDegrees:-90.0];
            [NSAffineTransform translateXBy:-labelRect.size.width yBy:0.0];
            [[[tabs objectAtIndex:x] label] drawInRect:labelRect withAttributes:attributes];
            [NSGraphicsContext restoreGraphicsState];
        } else {
            [[[tabs objectAtIndex:x] label] drawInRect:labelRect withAttributes:attributes];
            //[[tabs objectAtIndex:x] drawLabel:tabsCanTruncate inRect:labelRect];
        }
    }
}

- (NSUInteger)tabForPoint:(NSPoint)point inRect:(NSRect)rect {
    NSInteger x;
    
    if ([tabs count] == 0) return NSNotFound;
    
    for (x = 0; x < (const NSInteger)[tabs count]; x++) {
        if (NSPointInRect(point, [self rectForTab:x inRect:rect])) return x;
    }
    
    return NSNotFound;
}

- (id)initWithCoder:(NSCoder *)coder {
    NSInteger version;
    NSInteger temp;
    BOOL tempBool;
    
    self = [super init];
    
    if ([coder allowsKeyedCoding]) {
        NSInteger            x;
        
        tabs = [coder decodeObjectForKey:@"tabs"];
        selectedTab = [coder decodeIntForKey:@"selectedTab"];
        tabType = [coder decodeIntForKey:@"tabType"];
        tabsCanTruncate = [coder decodeBoolForKey:@"tabsCanTruncate"];
        x = [coder decodeIntForKey:@"tabsCount"];
        tabSizes = (NSSize *)NSZoneMalloc(nil, sizeof(NSSize) * x);
        for (; x > 0; x--) {
            tabSizes[x - 1] = [coder decodeSizeForKey:AJRFormat(@"tab%d", x)];
        }
        if ([coder containsValueForKey:@"titleCell"]) {
            titleCell = [coder decodeObjectForKey:@"titleCell"];
            titlePosition = [coder decodeIntForKey:@"titlePosition"];
            titleAlignment = [coder decodeIntForKey:@"titleAlignment"];
        }
    } else {
        version = [coder versionForClassName:NSStringFromClass([AJRBorder class])];
        if (version == 2) {
            tabs = [coder decodeObject];
            [coder decodeValueOfObjCType:@encode(NSInteger) at:&selectedTab];
            [coder decodeValueOfObjCType:@encode(NSInteger) at:&temp];
            tabType = temp;
            [coder decodeValueOfObjCType:@encode(BOOL) at:&tempBool];
            tabsCanTruncate = tempBool;
            
            [coder decodeValueOfObjCType:@encode(NSInteger) at:&temp];
            tabSizes = (NSSize *)NSZoneMalloc(nil, sizeof(NSSize) * temp);
            for (temp = 0; temp < (const NSInteger)[tabs count]; temp++) {
                tabSizes[temp] = [coder decodeSize];
            }
            titleCell = [coder decodeObject];
            [coder decodeValueOfObjCType:@encode(NSInteger) at:&titlePosition];
            [coder decodeValueOfObjCType:@encode(NSInteger) at:&titleAlignment];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if ([coder allowsKeyedCoding]) {
        NSInteger x;
        
        [coder encodeObject:tabs forKey:@"tabs"];
        [coder encodeInteger:selectedTab forKey:@"selectedTab"];
        [coder encodeInteger:tabType forKey:@"tabType"];
        [coder encodeBool:tabsCanTruncate forKey:@"tabsCanTruncate"];
        [coder encodeInteger:[tabs count] forKey:@"tabsCount"];
        for (x = 0; x < (const NSInteger)[tabs count]; x++) {
            [coder encodeSize:tabSizes[x] forKey:AJRFormat(@"tab%d", x + 1)];
        }
        [coder encodeObject:titleCell forKey:@"titleCell"];
        [coder encodeInt:(int)titlePosition forKey:@"titlePosition"];
        [coder encodeInt:(int)titleAlignment forKey:@"titleAlignment"];
    } else {
        NSInteger temp;
        BOOL tempBool;
        
        [coder encodeObject:tabs];
        [coder encodeValueOfObjCType:@encode(NSInteger) at:&selectedTab];
        temp = tabType; [coder encodeValueOfObjCType:@encode(NSInteger) at:&temp];
        tempBool = tabsCanTruncate; [coder encodeValueOfObjCType:@encode(BOOL) at:&tempBool];
        temp = [tabs count];
        [coder encodeValueOfObjCType:@encode(NSInteger) at:&temp];
        for (temp = 0; temp < (const NSInteger)[tabs count]; temp++) {
            [coder encodeSize:tabSizes[temp]];
        }
        [coder encodeObject:titleCell];
        [coder encodeValueOfObjCType:@encode(NSInteger) at:&titlePosition];
        [coder encodeValueOfObjCType:@encode(NSInteger) at:&titleAlignment];
    }
}

- (AJRInset)shadowInset {
    return (AJRInset){0, 0, 0, 0};
}

- (BOOL)isControlViewActive:(NSView *)controlView {
    return [NSApp isActive] && [[controlView window] isKeyWindow];
}

- (BOOL)isControlViewFocused:(NSView *)controlView {
    return [self isControlViewFocused:controlView] && [[controlView window] firstResponder] == controlView;
}

@end
