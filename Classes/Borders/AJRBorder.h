/*
 AJRBorder.h
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

#import <AppKit/AppKit.h>

#import <AJRInterfaceFoundation/AJRInset.h>

@class AJRBorderInspector;

extern NSString *AJRBorderWillUpdateNotification;
extern NSString *AJRBorderDidUpdateNotification;

typedef enum _ajrBorderTabMask {
    AJRBorderTabsNone = 0,
    AJRBorderTabsOnTop = 1,
    AJRBorderTabsOnBottom = 2,
    AJRBorderTabsOnLeft = 4,
    AJRBorderTabsOnRight = 8,
    AJRBorderTabsAll = AJRBorderTabsOnTop | AJRBorderTabsOnBottom | AJRBorderTabsOnLeft | AJRBorderTabsOnRight
} AJRBorderTabMask;

@interface AJRBorder : NSObject <NSCoding>
{
    NSArray                *tabs;
    NSSize                *tabSizes;
    NSInteger            selectedTab;
    NSTextFieldCell        *titleCell;

    NSTitlePosition        titlePosition;
    NSTextAlignment        titleAlignment;
    NSTabViewType        tabType:3;
    BOOL                tabsCanTruncate:1;
}

+ (void)registerBorder:(Class)aClass;

+ (NSArray *)borderTypes;
+ (NSArray *)borderNames;
+ (AJRBorder *)borderForType:(NSString *)type;
+ (AJRBorder *)borderForName:(NSString *)type;

+ (NSString *)name;

#pragma mark - Title

@property (nonatomic,strong) NSTextFieldCell *titleCell;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSTitlePosition titlePosition;
@property (nonatomic,assign) NSTextAlignment titleAlignment;

- (NSSize)titleSize;
- (NSRect)titleRectForRect:(NSRect)rect;

- (void)setTabs:(NSArray *)tabs;
- (NSArray *)tabs;
- (void)setTabsCanTruncate:(BOOL)flag;
- (BOOL)tabsCanTruncate;
- (void)setSelectedTabIndex:(NSUInteger)index;
- (void)setTabViewType:(NSTabViewType)aType;
- (NSTabViewType)tabViewType;
- (AJRBorderTabMask)availableTabEdges;

- (void)willUpdate;
- (void)didUpdate;

- (BOOL)isOpaque;
- (NSRect)contentRectForRect:(NSRect)rect;
- (NSRect)unclippedContentRectForRect:(NSRect)rect;
- (NSRect)rectForContentRect:(NSRect)rect;
- (NSBezierPath *)clippingPathForRect:(NSRect)rect;
- (void)drawBorderBackgroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView;
- (void)drawBorderForegroundInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView;
- (void)drawBorderInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect controlView:(NSView *)controlView;
- (void)drawBorderInRect:(NSRect)rect controlView:(NSView *)controlView;

- (NSSize)sizeForTab:(NSUInteger)index;
- (CGFloat)marginBetweenTabs:(NSInteger)index1 and:(NSInteger)index2;
- (NSRect)rectForTab:(NSUInteger)index inRect:(NSRect)bounds;
- (void)drawTabTextInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect;
- (NSUInteger)tabForPoint:(NSPoint)point inRect:(NSRect)rect;

- (AJRInset)shadowInset;

- (BOOL)isControlViewActive:(NSView *)controlView;
- (BOOL)isControlViewFocused:(NSView *)controlView;

@end
