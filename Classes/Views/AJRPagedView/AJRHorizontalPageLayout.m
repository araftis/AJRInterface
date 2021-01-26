//
//  AJRHorizontalPageLayout.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/15/11.
//  Copyright 2011 A.J. Raftis. All rights reserved.
//

#import "AJRHorizontalPageLayout.h"

#import "AJRPagedView.h"

#import <AJRFoundation/AJRFoundation.h>

NSString * const AJRHorizontalPageLayoutIdentifier = @"horizontal";

@implementation AJRHorizontalPageLayout
{
	NSMutableArray<NSView *> *_horizontalViews;
}

#pragma mark - Factory

+ (void)load {
    [AJRPageLayout registerPageLayout:self];
}

+ (NSString *)identifier {
    return AJRHorizontalPageLayoutIdentifier;
}

+ (NSString *)name {
    return @"Horizontal";
}

#pragma mark - AJRPageLayout

- (void)updateConstraints {
    NSView *previousView = nil;
    NSView *currentView = nil;
    id <AJRPagedViewDataSource> document = [[self pagedView] pageDataSource];
    CGFloat verticalGap = [self verticalGap];
    CGFloat horizontalGap = [self horizontalGap];
    NSInteger pageCount = [document pageCountForPagedView:[self pagedView]];
	
	_horizontalViews = [NSMutableArray array];
	
    if ([[self pagedView] masterPageDisplay] == AJRMasterPageDisplaySingle) {
        [self getView:&currentView forPage:AJRPageIndexMasterSingle];
		[_horizontalViews addObject:currentView];
		[[self pagedView] addConstraints:@[[[currentView leftAnchor] constraintEqualToAnchor:[[self pagedView] leftAnchor] constant:verticalGap],
									 [[currentView centerYAnchor] constraintEqualToAnchor:[[self pagedView] centerYAnchor] constant:0.0],
									 [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:[[self pagedView] topAnchor] constant:horizontalGap],
									 [[currentView bottomAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] bottomAnchor] constant:-horizontalGap],
									 ]];
        previousView = currentView;
    } else if ([[self pagedView] masterPageDisplay] == AJRMasterPageDisplayDouble) {
        [self getView:&currentView forPage:AJRPageIndexMasterEven];
		[_horizontalViews addObject:currentView];
		[[self pagedView] addConstraints:@[[[currentView leftAnchor] constraintEqualToAnchor:[[self pagedView] leftAnchor] constant:verticalGap],
									 [[currentView centerYAnchor] constraintEqualToAnchor:[[self pagedView] centerYAnchor] constant:0.0],
									 [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:[[self pagedView] topAnchor] constant:horizontalGap],
									 [[currentView bottomAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] bottomAnchor] constant:-horizontalGap],
									 ]];
        previousView = currentView;

        [self getView:&currentView forPage:AJRPageIndexMasterOdd];
		[_horizontalViews addObject:currentView];
		[[self pagedView] addConstraints:@[[[currentView leftAnchor] constraintEqualToAnchor:[[self pagedView] leftAnchor] constant:verticalGap],
									 [[currentView centerYAnchor] constraintEqualToAnchor:[[self pagedView] centerYAnchor] constant:0.0],
									 [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:[[self pagedView] topAnchor] constant:horizontalGap],
									 [[currentView bottomAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] bottomAnchor] constant:-horizontalGap],
									 ]];
        previousView = currentView;
    }
	
    for (NSInteger x = 0; x < pageCount; x++) {
        [self getView:&currentView forPage:x];
		[_horizontalViews addObject:currentView];
		[[self pagedView] addConstraints:@[[[currentView leftAnchor] constraintEqualToAnchor:previousView ? [previousView rightAnchor] : [[self pagedView] leftAnchor] constant:verticalGap],
									 [[currentView centerYAnchor] constraintEqualToAnchor:[[self pagedView] centerYAnchor] constant:0.0],
									 [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:[[self pagedView] topAnchor] constant:horizontalGap],
									 [[currentView bottomAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] bottomAnchor] constant:-horizontalGap],
									 ]];
        previousView = currentView;
    }
	
    // Right
    if (previousView) {
		[[self pagedView] addConstraint:[[previousView rightAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] rightAnchor] constant:-horizontalGap]];
    }
}

#pragma mark - Ruler Support

- (NSArray<NSView *> *)horizontalViews {
	return _horizontalViews;
}

- (NSArray<NSView *> *)verticalViews {
	NSUInteger count = [[self pageDataSource] pageCountForPagedView:[self pagedView]];
	if (count == 0) {
		return @[];
	} else {
		return @[[[self pageDataSource] pagedView:[self pagedView] viewForPage:0]];
	}
}

@end
