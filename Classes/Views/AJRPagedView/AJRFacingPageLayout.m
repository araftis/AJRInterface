/*
AJRFacingPageLayout.m
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

#import "AJRFacingPageLayout.h"

#import "AJRPagedView.h"

NSString * const AJRFacingPageLayoutIdentifier = @"facing";

@implementation AJRFacingPageLayout {
    NSMutableArray<NSView *> *_horizontalViews;
    NSMutableArray<NSView *> *_verticalViews;
}

#pragma mark - Factory

+ (void)load {
    [AJRPageLayout registerPageLayout:self];
}

+ (NSString *)identifier {
    return AJRFacingPageLayoutIdentifier;
}

+ (NSString *)name {
    return @"Facing Pages";
}

#pragma mark - AJRPageLayout

- (NSInteger)pairedPageForPage:(NSInteger)pageNumber {
    if ((pageNumber + 1) % 2) {
        return pageNumber - 1;
    } else {
        return pageNumber + 1;
    }
}

- (void)updateConstraints {
    NSView *previousViewLeft = nil;
    NSView *previousViewRight = nil;
    NSView *currentView = nil;
    id <AJRPagedViewDataSource> document = [[self pagedView] pageDataSource];
    CGFloat verticalGap = [self verticalGap];
    CGFloat horizontalGap = [self horizontalGap];
    NSUInteger pageCount = [document pageCountForPagedView:[self pagedView]];

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
        [self getView:&currentView forPage:AJRPageIndexMasterEven];

        [_verticalViews addObject:currentView];

        // Top
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:horizontalGap]];
        // Center
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-floor(verticalGap / 2.0)]];
        // Left
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeLeft multiplier:1.0 constant:verticalGap]];
        
        previousViewLeft = currentView;
        
        [self getView:&currentView forPage:AJRPageIndexMasterOdd];
        // Top
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:horizontalGap]];
        // Center
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:[self pagedView] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:ceil(verticalGap / 2.0)]];
        // Right
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeRight multiplier:1.0 constant:-verticalGap]];
        
        previousViewRight = currentView;
    }
    
    for (NSInteger x = 0; x < pageCount + 1; x += 2) {
        if (x - 1 >= 0) {
            [self getView:&currentView forPage:x - 1];
            if (x - 1 == 1) {
                [_horizontalViews addObject:currentView];
            }
            [_verticalViews addObject:currentView];
            [[self pagedView] addConstraints:@[
                [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:previousViewLeft ? [previousViewLeft bottomAnchor] : [[self pagedView] topAnchor] constant:horizontalGap],
                [[currentView topAnchor] constraintGreaterThanOrEqualToAnchor:previousViewRight ? [previousViewRight bottomAnchor] : [[self pagedView] topAnchor] constant:horizontalGap],
                [[currentView rightAnchor] constraintEqualToAnchor:[[self pagedView] centerXAnchor] constant:-floor(verticalGap / 2.0)],
                [[currentView leftAnchor] constraintGreaterThanOrEqualToAnchor:[[self pagedView] leftAnchor] constant:verticalGap],
            ]];
        } else {
            currentView = nil;
        }
        
        if (x < pageCount) {
            NSView *currentViewRight = [document pagedView:[self pagedView] viewForPage:x];
            [self getView:&currentViewRight forPage:x];
            if (x == 0) {
                [_horizontalViews addObject:currentViewRight];
            }
            [_verticalViews addObject:currentViewRight];
            [[self pagedView] addConstraints:@[
                [[currentViewRight topAnchor] constraintGreaterThanOrEqualToAnchor:previousViewLeft ? [previousViewLeft bottomAnchor] : [[self pagedView] topAnchor] constant:horizontalGap],
                [[currentViewRight topAnchor] constraintGreaterThanOrEqualToAnchor:previousViewRight ? [previousViewRight bottomAnchor] : [[self pagedView] topAnchor] constant:horizontalGap],
                [[currentViewRight leftAnchor] constraintEqualToAnchor:[[self pagedView] centerXAnchor] constant:ceil(verticalGap / 2.0)],
                [[currentViewRight rightAnchor] constraintLessThanOrEqualToAnchor:[[self pagedView] rightAnchor] constant:-verticalGap],
            ]];
            previousViewRight = currentViewRight;
        } else {
            previousViewRight = nil;
        }
        
        previousViewLeft = currentView;
        
        if (previousViewLeft && previousViewRight) {
            [[self pagedView] addConstraint:[[previousViewLeft centerYAnchor] constraintEqualToAnchor:[previousViewRight centerYAnchor] constant:0.0]];
        }
    }
    
    // Bottom
    if (previousViewLeft) {
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:previousViewLeft attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-horizontalGap]];
    }
    if (previousViewRight) {
        [[self pagedView] addConstraint:[NSLayoutConstraint constraintWithItem:previousViewRight attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:[self pagedView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-horizontalGap]];
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
