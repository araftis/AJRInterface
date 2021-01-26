//
//  AJRVerticalPageLayout.m
//  AJRInterface
//
//  Created by A.J. Raftis on 5/27/11.
//  Copyright 2011 A.J. Raftis. All rights reserved.
//

#import "AJRVerticalPageLayout.h"

#import "AJRPagedView.h"

NSString * const AJRVerticalPageLayoutIdentifier = @"vertical";

@implementation AJRVerticalPageLayout {
    NSMutableArray<NSView *> *_verticalViews;
}

#pragma mark - Factory

+ (void)load {
    [AJRPageLayout registerPageLayout:self];
}

+ (NSString *)identifier {
    return AJRVerticalPageLayoutIdentifier;
}

+ (NSString *)name {
    return @"Vertical";
}

#pragma mark - AJRPageLayout

- (void)updateConstraints {
    NSView *previousView = nil;
    NSView *currentView = nil;
    id <AJRPagedViewDataSource> document = self.pageDataSource;
    CGFloat verticalGap = self.verticalGap;
    CGFloat horizontalGap = self.horizontalGap;
    NSInteger pageCount = [document pageCountForPagedView:self.pagedView];
    
    if (self.pagedView.masterPageDisplay == AJRMasterPageDisplaySingle) {
        [self getView:&currentView forPage:AJRPageIndexMasterSingle];
        [_verticalViews addObject:currentView];
        [self.pagedView addConstraints:@[
            [currentView.topAnchor constraintEqualToAnchor:self.pagedView.topAnchor constant:verticalGap],
            [currentView.centerXAnchor constraintEqualToAnchor:self.pagedView.centerXAnchor constant:0.0],
            [currentView.leftAnchor constraintGreaterThanOrEqualToAnchor:self.pagedView.leftAnchor constant:horizontalGap],
            [currentView.rightAnchor constraintLessThanOrEqualToAnchor:self.pagedView.rightAnchor constant:-horizontalGap],
        ]];
        previousView = currentView;
    } else if (self.pagedView.masterPageDisplay == AJRMasterPageDisplayDouble) {
        [self getView:&currentView forPage:AJRPageIndexMasterEven];
        [_verticalViews addObject:currentView];
        [self.pagedView addConstraints:@[
            [currentView.topAnchor constraintEqualToAnchor:self.pagedView.topAnchor constant:verticalGap],
            [currentView.centerXAnchor constraintEqualToAnchor:self.pagedView.centerXAnchor constant:0.0],
            [currentView.leftAnchor constraintGreaterThanOrEqualToAnchor:self.pagedView.leftAnchor constant:horizontalGap],
            [currentView.rightAnchor constraintLessThanOrEqualToAnchor:self.pagedView.rightAnchor constant:-horizontalGap],
        ]];
        previousView = currentView;

        [self getView:&currentView forPage:AJRPageIndexMasterOdd];
        [_verticalViews addObject:currentView];
        [self.pagedView addConstraints:@[
            [currentView.topAnchor constraintEqualToAnchor:self.pagedView.topAnchor constant:verticalGap],
            [currentView.centerXAnchor constraintEqualToAnchor:self.pagedView.centerXAnchor constant:0.0],
            [currentView.leftAnchor constraintGreaterThanOrEqualToAnchor:self.pagedView.leftAnchor constant:horizontalGap],
            [currentView.rightAnchor constraintLessThanOrEqualToAnchor:self.pagedView.rightAnchor constant:-horizontalGap],
        ]];
        previousView = currentView;
    }

    _verticalViews = [NSMutableArray array];
    for (NSInteger x = 0; x < pageCount; x++) {
        [self getView:&currentView forPage:x];
        [_verticalViews addObject:currentView];
        [self.pagedView addConstraints:@[
            [currentView.topAnchor constraintEqualToAnchor:previousView ? previousView.bottomAnchor : self.pagedView.topAnchor constant:verticalGap],
            [currentView.centerXAnchor constraintEqualToAnchor:self.pagedView.centerXAnchor constant:0.0],
            [currentView.leftAnchor constraintGreaterThanOrEqualToAnchor:self.pagedView.leftAnchor constant:horizontalGap],
            [currentView.rightAnchor constraintLessThanOrEqualToAnchor:self.pagedView.rightAnchor constant:-horizontalGap],
        ]];
        previousView = currentView;
    }
    
    // Bottom
    if (previousView) {
        [self.pagedView addConstraint:[NSLayoutConstraint constraintWithItem:previousView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.pagedView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-horizontalGap]];
    }
}

#pragma mark - Ruler Support

- (NSArray<NSView *> *)horizontalViews {
    NSUInteger count = [self.pageDataSource pageCountForPagedView:self.pagedView];
    if (count == 0) {
        return @[];
    } else {
        return @[[self.pageDataSource pagedView:self.pagedView viewForPage:0]];
    }
}

- (NSArray<NSView *> *)verticalViews {
    return _verticalViews;
}

@end
