/*
 AJRLabelCell.h
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

#import <AppKit/AppKit.h>

typedef enum _ajrTextStyle {
    AJRTextNormal            = 0,
    AJRTextOutline            = 1,
    AJRTextShadow            = 2,
    AJRTextBezeledIn            = 3,
    AJRTextBezeledOut        = 4,
    AJRTextGroove            = 5,
    AJRTextBezeledInClean    = 6,
    AJRTextBezeledOutClean    = 7
} AJRTextStyle;

typedef enum _ajrFades {
    AJRFadeSolid            = 0,
    AJRFadeTopToBottom    = 1,
    AJRFadeBottomToTop    = 2,
    AJRFadeLeftToRight    = 3,
    AJRFadeRightToLeft    = 4
} AJRFades;

typedef enum _ajrBorderType {
    AJRNoBorder            = 0,
    AJRLineBorderDep        = 1,
    AJRBezelBorder        = 2,
    _AJRGrooveBorder        = 3,
    AJRButtonBorder        = 4
} AJRBorderType;

@class AJRPathRenderer;

@interface AJRLabelCell : NSTextFieldCell
{
    NSMutableArray    *renderers;
    NSBezierPath    *path;
}

- (id)init;
- (id)initTextCell:(NSString *)string;
- (id)initImageCell:(NSImage *)icon;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)aView;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView;
- (NSSize)cellSize;
- (NSSize)cellSizeForBounds:(NSRect)rect;

- (NSArray *)renderers;
- (NSUInteger)renderersCount;
- (AJRPathRenderer *)rendererAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfRenderer:(AJRPathRenderer *)renderer;
- (AJRPathRenderer *)lastRenderer;
- (void)addRenderer:(AJRPathRenderer *)renderer;
- (void)insertRenderer:(AJRPathRenderer *)renderer atIndex:(NSUInteger)index;
- (void)removeRendererAtIndex:(NSUInteger)index;
- (void)removeRenderersAtIndexes:(NSIndexSet *)indexes;
- (void)moveRendererAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

