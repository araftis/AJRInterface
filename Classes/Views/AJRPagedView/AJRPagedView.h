/*
AJRPagedView.h
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

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger AJRPageIndexMasterSingle;
extern const NSInteger AJRPageIndexMasterEven;
extern const NSInteger AJRPageIndexMasterOdd;
extern const NSInteger AJRPageIndexFirst;

typedef NS_ENUM(uint8_t, AJRMasterPageDisplay) {
    AJRMasterPageDisplayNone,
    AJRMasterPageDisplaySingle,
    AJRMasterPageDisplayDouble
};

@class AJRBorder, AJRPageLayout, AJRPagedView;

@protocol AJRPagedViewDataSource <NSObject>

@required - (NSUInteger)pageCountForPagedView:(AJRPagedView *)pagedView;
@required - (NSView *)pagedView:(AJRPagedView *)pagedView viewForPage:(NSInteger)pageNumber;
@required - (NSSize)pagedView:(AJRPagedView *)pagedView sizeForPage:(NSInteger)pageNumber;
@optional - (NSColor *)pagedView:(AJRPagedView *)pagedView colorForPage:(NSInteger)pageNumber;

@end

@protocol AJRPagedViewDelegate <NSObject>

@optional - (BOOL)pagedView:(AJRPagedView *)pagedView shouldSwitchToLayout:(AJRPageLayout *)layout;
@optional - (void)pagedView:(AJRPagedView *)pagedView willSwitchToLayout:(AJRPageLayout *)layout;
@optional - (void)pagedView:(AJRPagedView *)pagedView didSwitchToLayout:(AJRPageLayout *)layout;
@optional - (BOOL)pagedView:(AJRPagedView *)pagedView isLayoutValid:(AJRPageLayout *)layout;

@optional - (void)pagedView:(AJRPagedView *)pagedView willScaleTo:(CGFloat)scale;
@optional - (void)pagedView:(AJRPagedView *)pagedView didScaleTo:(CGFloat)scale;

@end

@interface AJRPagedView : NSView

@property (nonatomic,weak) IBOutlet id <AJRPagedViewDelegate> delegate;
@property (nonatomic,strong) IBOutlet id <AJRPagedViewDataSource> pageDataSource;

@property (nonatomic,assign) CGFloat verticalGap;
@property (nonatomic,assign) CGFloat horizontalGap;

@property (nullable,nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) AJRBorder *pageBorder;
@property (nonatomic,assign) CGFloat scale;

@property (nonatomic,strong) AJRPageLayout *pageLayout;
@property (nonatomic,strong) NSString *pageLayoutIdentifier;

@property (nonatomic,assign) AJRMasterPageDisplay masterPageDisplay;

@property (weak, nonatomic,readonly) NSIndexSet *visiblePageIndexes;
@property (weak, nonatomic,readonly) NSString *visiblePageString;

#pragma mark - Page Data Source

- (void)reloadPages;

#pragma mark - Scrolling

- (void)scrollPageToVisible:(NSInteger)pageIndex;
- (void)scrollPagesToVisible:(NSIndexSet *)pageIndex;

@end

NS_ASSUME_NONNULL_END
