/*
 AJRTwoUpPageLayout.m
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

#import "AJRTwoUpPageLayout.h"

#import "AJRPagedView.h"

NSString * const AJRTwoUpPageLayoutIdentifier = @"twoUp";

@implementation AJRTwoUpPageLayout {
    NSMutableArray<NSView *> *_horizontalViews;
    NSMutableArray<NSView *> *_verticalViews;
}

#pragma mark - Factory

+ (void)load {
    [AJRPageLayout registerPageLayout:self];
}

+ (NSString *)identifier {
    return AJRTwoUpPageLayoutIdentifier;
}

+ (NSString *)name {
    return @"Two Up";
}

- (NSInteger)pairedPageForPage:(NSInteger)pageNumber {
    if ((pageNumber + 1) % 2) {
        return pageNumber + 1;
    } else {
        return pageNumber - 1;
    }
}

#pragma mark - AJRPageLayout

- (void)updateConstraints {
    NSView *previousViewLeft = nil;
    NSView *previousViewRight = nil;
    NSView *currentView = nil;
    id <AJRPagedViewDataSource>  document = [[self pagedView] pageDataSource];
    CGFloat verticalGap = [self verticalGap];
    CGFloat horizontalGap = [self horizontalGap];
    NSInteger pageCount = [document pageCountForPagedView:[self pagedView]];

    _horizontalViews = [NSMutableArray array];
    _verticalViews = [NSMutableArray array];

    if ([[self pagedView] masterPageDisplay] == AJRMasterPageDisplaySingle) {
        [self getView:&currentView forPage:AJRPageIndexMasterSingle];
        [_verticalViews addObject:currentView];
        // Top
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:horizontalGap]];
        // Centered
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        // Left
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeLeft multiplier:1.0 constant:verticalGap]];
        // Right
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeRight multiplier:1.0 constant:-verticalGap]];
        
        previousViewLeft = currentView;
        previousViewRight = currentView;
    } else if ([[self pagedView] masterPageDisplay] == AJRMasterPageDisplayDouble) {
        [self getView:&currentView forPage:AJRPageIndexMasterOdd];
        [_verticalViews addObject:currentView];
        // Top
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:horizontalGap]];
        // Center
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-floor(verticalGap / 2.0)]];
        // Left
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeLeft multiplier:1.0 constant:verticalGap]];
        
        previousViewLeft = currentView;
        
        [self getView:&currentView forPage:AJRPageIndexMasterEven];
        // Top
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:horizontalGap]];
        // Center
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:ceil(verticalGap / 2.0)]];
        // Right
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeRight multiplier:1.0 constant:-verticalGap]];
        
        previousViewRight = currentView;
    }
    
    for (NSInteger x = 0; x < pageCount; x += 2) {
        [self getView:&currentView forPage:x];
        [_verticalViews addObject:currentView];
        if (x == 0) {
            [_horizontalViews addObject:currentView];
        }
        [[self pagedView] addConstraints:@[
            [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:previousViewLeft ? [previousViewLeft bottomAnchor] : [[self pagedView] topAnchor] constant:horizontalGap],
            [[currentView rightAnchor] constraintEqualToAnchor:[[self pagedView] centerXAnchor] constant:-floor(verticalGap / 2.0)],
            [[currentView leftAnchor] constraintGreaterThanOrEqualToAnchor:[[self pagedView] leftAnchor] constant:verticalGap],
        ]];
        previousViewLeft = currentView;

        if (x + 1 < pageCount) {
            NSView *currentViewRight;
            [self getView:&currentViewRight forPage:x + 1];
            if (x == 0) {
                [_horizontalViews addObject:currentViewRight];
            }
            [[self pagedView] addConstraints:@[
                [[currentViewRight topAnchor] constraintGreaterThanOrEqualToAnchor:previousViewRight ? [previousViewRight bottomAnchor] : [[self pagedView] topAnchor] constant:horizontalGap],
                [[currentViewRight leftAnchor] constraintEqualToAnchor:[[self pagedView] centerXAnchor] constant:ceil(verticalGap / 2.0)],
                [[currentViewRight rightAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] rightAnchor] constant:-verticalGap],
            ]];
            previousViewRight = currentViewRight;
        }
    }
    
    // Bottom
    if (previousViewLeft) {
        [[self pagedView] addConstraint:[[previousViewLeft bottomAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] bottomAnchor] constant:-horizontalGap]];
    }
    if (previousViewRight) {
        [[self pagedView] addConstraint:[[previousViewRight bottomAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] bottomAnchor] constant:-horizontalGap]];
    }
}

#pragma mark - Ruler Support

- (NSArray<NSView *> *)horizontalViews {
    return _horizontalViews;
}

- (NSArray<NSView *> *)verticalViews {
    return _verticalViews;
}

@end
