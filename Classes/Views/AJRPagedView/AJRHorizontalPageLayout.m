/*
AJRHorizontalPageLayout.m
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

#import "AJRHorizontalPageLayout.h"

#import "AJRPagedView.h"

#import <AJRFoundation/AJRFoundation.h>

NSString * const AJRHorizontalPageLayoutIdentifier = @"horizontal";

@implementation AJRHorizontalPageLayout {
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
