//
//  AJRPageLayout.h
//  AJRInterface
//
//  Created by A.J. Raftis on 5/27/11.
//  Copyright 2011 A.J. Raftis. All rights reserved.
//

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
