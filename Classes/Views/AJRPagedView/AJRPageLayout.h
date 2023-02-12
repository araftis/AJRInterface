/*
 AJRPageLayout.h
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

#import <AJRInterface/AJRPagedView.h>

@interface AJRPageLayout : NSObject

#pragma mark - Factory

+ (void)registerPageLayout:(Class)class;
+ (NSArray *)pageLayoutIdentifiers;
+ (NSArray *)pageLayouts;
+ (Class)pageLayoutForIdentifier:(NSString *)identifier;
+ (id)pageLayoutForView:(AJRPagedView *)pagedView withIdentifier:(NSString *)identifier;

+ (NSString *)identifier;
+ (NSString *)name;

#pragma mark - Creation

- (id)initWithPagedView:(AJRPagedView *)pagedView;

#pragma mark - Properties

@property (readonly) AJRPagedView *pagedView;
@property (nonatomic,readonly) NSString *identifier;

/*! If the layout is a "paired" payout, like facing pages, this returns the paired page number. Otherwise, it returns NSNotFound. */
- (NSInteger)pairedPageForPage:(NSInteger)pageNumber;

#pragma mark - Actions

/*! Updates the constraints for the ajrsociated pagedView. */
- (void)updateConstraints;

#pragma mark - Utilities

- (id <AJRPagedViewDataSource>)pageDataSource;
- (CGFloat)verticalGap;
- (CGFloat)horizontalGap;

- (void)getView:(NSView **)view forPage:(NSInteger)pageNumber;

#pragma mark - Ruler Support

- (NSArray<NSView *> *)horizontalViews;
- (NSArray<NSView *> *)verticalViews;

@end
