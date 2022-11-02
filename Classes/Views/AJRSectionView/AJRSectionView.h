/*
 AJRSectionView.h
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

#import <Cocoa/Cocoa.h>

@class AJRSectionViewItem;
@protocol AJRSectionViewDelegate;

@interface AJRSectionView : NSView <NSCoding>
{
    NSMutableArray *_sections;
    NSMutableArray *_sectionSnapshots;
    
    // Visual Attributes
    NSColor *_activeBackgroundColor;
    NSColor *_inactiveBackgroundColor;
    NSDictionary *_titleAttributes;
    CGFloat _titleHeight;
    NSGradient *_titleActiveBackgroundGradient;
    NSGradient *_titleInactiveBackgroundGradient;
    NSGradient *_titleHighlightBackgroundGradient;
    NSColor *_titleActiveColor;
    NSColor *_titleInactiveColor;
    
    // Animation place holders
    NSMutableArray *_viewsToInsert;
    NSMutableArray *_viewsToRemove;
    NSMutableSet *_viewsToResize;
    CGFloat _arrowProgress;
    
    // Highlights
    AJRSectionViewItem *_highlightedSection;
    
    id <AJRSectionViewDelegate> __unsafe_unretained _delegate;
    
    BOOL _suppressAnimation;
    BOOL _isTiling;
    BOOL _bordered;
    BOOL _delegateRespondsToShouldCollapse;
    BOOL _delegateRespondsToWillCollapse;
    BOOL _delegateRespondsToDidCollapse;
    BOOL _delegateRespondsToShouldExpand;
    BOOL _delegateRespondsToWillExpand;
    BOOL _delegateRespondsToDidExpand;
}

- (id)initWithFrame:(NSRect)frame;

@property (nonatomic,assign,getter=isAnimationSuppressed) BOOL suppressAnimation;
@property (nonatomic,unsafe_unretained) IBOutlet id<AJRSectionViewDelegate> delegate;

@property (nonatomic,strong) NSColor *activeBackgroundColor;
@property (nonatomic,strong) NSColor *inactiveBackgroundColor;

@property (nonatomic,strong) NSDictionary *titleAttributes;
@property (nonatomic,assign) CGFloat titleHeight;
@property (nonatomic,strong) NSGradient *titleActiveBackgroundGradient;
@property (nonatomic,strong) NSGradient *titleInactiveBackgroundGradient;
@property (nonatomic,strong) NSGradient *titleHighlightBackgroundGradient;
@property (nonatomic,strong) NSColor *titleActiveColor;
@property (nonatomic,strong) NSColor *titleInactiveColor;

@property (nonatomic,assign,getter=isBordered) BOOL bordered;

/*!
 @methodgroup Managing Animation
 */
- (void)suppressAnimation;
- (void)enableAnimation;

/*!
 @methodgroup Managing View Layout
 */
- (void)prepareToTile;
- (void)tile;

/*!
 @methodgroup Managing the View Heirarchy
 */
- (void)addSubview:(NSView *)subview expanded:(BOOL)expanded;
- (void)addSubview:(NSView *)subview withTitle:(NSString *)title expanded:(BOOL)expanded;
- (void)addSubview:(NSView *)aView positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView;
- (void)addSubview:(NSView *)aView positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView expanded:(BOOL)expanded;
- (void)addSubview:(NSView *)aView withTitle:(NSString *)title positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView expanded:(BOOL)expanded;

/*!
 @methodgroup Managing Sections
 */
- (AJRSectionViewItem *)sectionForPoint:(NSPoint)point;
- (AJRSectionViewItem *)sectionForView:(NSView *)view;
- (NSUInteger)indexOfSection:(AJRSectionViewItem *)section;
- (BOOL)isSectionHighlighted:(AJRSectionViewItem *)section;

/*!
 @methodgroup Managing Section Size
 */
- (BOOL)isViewExpanded:(NSView *)view;
- (void)expandView:(NSView *)view;
- (void)collapseView:(NSView *)view;
- (void)setHeight:(CGFloat)height ofView:(NSView *)view;

/*!
 @methodgroup Drawing
 */
- (void)drawSectionTitle:(AJRSectionViewItem *)section inRect:(NSRect)rect;

@end


@protocol AJRSectionViewDelegate <NSObject>

@optional
- (void)sectionView:(AJRSectionView *)sectionView willResizeTo:(NSSize)size byAnimating:(BOOL)animating;
- (BOOL)sectionView:(AJRSectionView *)sectionView shouldCollapseView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView willCollapseView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView didCollapseView:(NSView *)view;
- (BOOL)sectionView:(AJRSectionView *)sectionView shouldExpandView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView willExpandView:(NSView *)view;
- (void)sectionView:(AJRSectionView *)sectionView didExpandView:(NSView *)view;

@end
