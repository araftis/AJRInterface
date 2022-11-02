/*
 AJRCenteringView.h
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

#import <AJRInterface/AJRScrollView.h>

@interface NSView (AJRCenterViewAdditions)

- (NSView *)viewForPage;
- (NSView *)viewForPage:(NSInteger)pageNumber;

@end


@interface AJRCenteringView : NSView
{
    NSClipView            *clipView;
    NSView                *subview;
    
    NSRect                contentRect;
    
    NSInteger            firstPage, lastPage;
    AJRPagePosition        pagePosition;
    NSInteger            activePage;
    NSRect                *_frameCache;
    
    NSSize                _savedSubviewSize;
    
    NSInteger            printingPageNumber;        // Only used during printing
    
    struct _ncvFlags {
        BOOL            _documentRespondsToViewForPage:1;
        BOOL            _isPrinting:1;
        NSUInteger        _reserved:30;
    } ncvFlags;
}

// Used to create a new centering view based off an old one. This copies some of the more important shared inforamtion.
- (id)initFromPrevious:(AJRCenteringView *)otherView;

- (NSView *)subview;
- (NSView *)documentView;
- (NSView *)viewForPage:(NSInteger)pageNumber;

@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSShadow *pageShadow;
@property (nonatomic,strong) NSColor *pageColor;
@property (nonatomic,assign) CGFloat scale;
@property (nonatomic,assign) CGFloat gutter;

- (void)tile;

- (NSSize)sizeOfContentRect;
- (NSRect)pageRectangleForPage:(NSInteger)pageNumber;

- (void)setActivePage:(NSInteger)aPage;
- (NSInteger)activePage;

- (NSInteger)pageForEvent:(NSEvent *)anEvent;
- (NSInteger)pageForPoint:(NSPoint)aPoint;
- (NSRange)pageRangeForRect:(NSRect)rect;

- (void)printRect:(NSRect)rect;

@end
