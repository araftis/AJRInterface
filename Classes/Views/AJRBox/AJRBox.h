/*
AJRBox.h
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
#import <QuartzCore/QuartzCore.h>

#import <AJRInterface/AJRLabel.h>
#import <AJRInterfaceFoundation/AJRInset.h>

#ifndef NSBezelOutBorder
#define NSBezelOutBorder 4
#endif

#ifdef AJRPaperBorder
#undef AJRPaperBorder
#endif
#define AJRPaperBorder 5

typedef NS_ENUM(NSInteger, AJRBoxPosition) {
    AJRBoxNone        = 0,
    AJRBoxTop        = 1,
    AJRBoxBottom        = 2,
    AJRBoxLeft        = 3,
    AJRBoxRight        = 4,
    AJRBoxFloating    = 5
};

typedef NSUInteger AJRContentPosition;

@class AJRBorder, AJRFill;


@interface AJRBox : NSBox <CAAnimationDelegate>
{
    NSRect                     fullTitleRect;
    NSRect                     contentViewRect;
    NSRect                     borderRect;
    NSSize                     labelSize;
    NSSize                    contentNaturalSize;
    AJRBorder                *border;
    AJRFill                    *contentFill;
    NSRect                    displayRect;
    
    struct _boxFlags {
        AJRBoxPosition        position:3;
        BOOL                hasInitialized:1;
        BOOL                hasAwakened:1;
        BOOL                autoresizeSubviews:1;
        NSUInteger            titleAlignment:3;
        BOOL                drawnOnce:1;
        BOOL                flipped:1;
        AJRContentPosition    contentPosition:3;
        BOOL                 ibResizeHack:1;
        BOOL                appIsIB:1;
        NSUInteger            _pad:10;
    } boxFlags;
}

- (id)initWithFrame:(NSRect)frameRect;

- (void)animateSetContentView:(NSView *)view;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aColor;
- (void)setBorder:(AJRBorder *)aBorder;
- (AJRBorder *)border;
- (void)setContentFill:(AJRFill *)aFill;
- (AJRFill *)contentFill;
- (void)setTitleAlignment:(NSUInteger)alignment;
- (NSUInteger)titleAlignment;
- (void)setContentPosition:(AJRContentPosition)aPosition;
- (AJRContentPosition)contentPosition;
- (void)setContentNatualSize:(NSSize)aSize;
- (NSSize)contentNaturalSize;

- (AJRBoxPosition)position;
- (void)setPosition: (AJRBoxPosition)position;

- (void)takeBackgroundColorFrom:sender;
- (void)takeBorderTypeFrom:sender;
- (void)takeContentFillTypeFrom:sender;
- (void)takePositionFrom:sender;

- (void)tile;

- (void)setAutoresize: (BOOL)flag;
- (BOOL)autoresize;
- (void)setAutoresizesSubviews: (BOOL)flag;
- (BOOL)autoresizesSubviews;

- (AJRInset)shadowInset;

@end

