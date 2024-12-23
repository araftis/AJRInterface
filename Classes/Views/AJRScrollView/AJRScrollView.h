/*
 AJRScrollView.h
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
#ifndef __AJR_SCROLL_VIEW_H__
#define __AJR_SCROLL_VIEW_H__

/*
 * Any View that responds to these messages can be a "ruler".
 * This is a nice way to make an object which works in concert
 * with another object, but isn't hardwired into the implementation
 * of that object and, instead, publishes a minimal interface
 * which it expects another object to respond to.
 */

#import <AppKit/AppKit.h>

extern NSString *AJRScrollViewDidChangeZoomPercent;
extern NSString *AJRScrollViewPercentKey;
extern NSString *AJRViewDidChangePageCount API_DEPRECATED("Use KVO on \"pages\" property instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

typedef enum {
    AJRPagesVertical,
    AJRPagesHorizontal,
    AJRPagesTwoUpOddRight,
    AJRPagesTwoUpOddLeft,
    AJRPagesSingle
} AJRPagePosition;

typedef enum {
    AJRAccessoriesLeft,
    AJRAccessoriesRight,
    AJRAccessoriesTop,
    AJRAccessoriesBottom
} AJRAccessoryPosition;

@protocol AJRScrollViewPageProvider <NSObject>

@required - (BOOL)knowsPageRange:(NSRangePointer)aRange;
@required - (NSRect)rectForPage:(NSInteger)pageNumber;

@end

@interface AJRScrollView : NSScrollView
{
    NSMutableArray            *horizontalAccessoriesLeft;
    NSMutableArray            *horizontalAccessoriesRight;
    NSMutableArray            *verticalAccessoriesTop;
    NSMutableArray            *verticalAccessoriesBottom;
    
    id                        delegate;
    
    NSInteger                firstPage, lastPage;
    
    NSInteger                oldScalePercent;
    
    IBOutlet NSTextField    *pageText;
    IBOutlet NSView            *pageAccessory;
    NSPopUpButton            *zoomButton;
    
    BOOL                    showsZoom;
    BOOL                    _hasSetup;
    BOOL                    _pages;
    uint8_t                 _pagePosition;
    BOOL                    _hasAwakened;
}

- (void)updateRulers:(const NSRect *)rect;

- (void)addHorizontalAccessory:(NSView *)anAccessory position:(AJRAccessoryPosition)aPosition;
- (void)addVerticalAccessory:(NSView *)anAccessory position:(AJRAccessoryPosition)aPosition;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setPagePosition:(AJRPagePosition)pagePosition;
- (AJRPagePosition)pagePosition;
- (NSInteger)pageCount;
- (NSInteger)firstPage;
- (NSInteger)lastPage;

- (void)setPageNumber:(NSInteger)aPageNumber;
- (NSInteger)pageNumber;

- (IBAction)takePageNumberFrom:(id)sender;
- (IBAction)pageForward:(id)sender;
- (IBAction)pageBackward:(id)sender;

- (void)setScale:(float)percent;

@end

@protocol NSScrollViewDelegate

- (void)scrollView:(NSScrollView *)aScrollView didZoomToPercent:(float)aPercent;

@end

#endif //__AJR_SCROLL_VIEW_H__
