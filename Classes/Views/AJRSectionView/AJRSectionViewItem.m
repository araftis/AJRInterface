/*
 AJRSectionViewItem.m
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

#import "AJRSectionViewItem.h"

@implementation AJRSectionViewItem

- (id)initWithView:(NSView *)view sectionView:(AJRSectionView *)sectionView {
    if ((self = [super init])) {
        self.view = view;
        _viewFrame = [view frame];
        self.expanded = YES;
        self.sectionView = sectionView;
    }
    return self;
}


#pragma mark Properties

@synthesize view = _view;
@synthesize title = _title;
@synthesize viewFrame = _viewFrame;
@synthesize expanded = _expanded;
@synthesize sectionView = _sectionView;

#pragma mark Utility Methods

- (NSSize)desiredSize {
    if (self.expanded) {
        return _viewFrame.size;
    }
    return NSZeroSize;
}

- (void)setHeight:(CGFloat)height {
    _viewFrame.size.height = height;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object {
    return self == object;
}

- (NSUInteger)hash {
    return (NSUInteger)self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _view = [coder decodeObjectForKey:@"view"];
        _title = [coder decodeObjectForKey:@"title"];
        _viewFrame = [coder decodeRectForKey:@"viewFrame"];
        _expanded = [coder decodeBoolForKey:@"expanded"];
        _sectionView = [coder decodeObjectForKey:@"sectionView"]; // Not retained.
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
    [coder encodeObject:_view forKey:@"view"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeRect:_viewFrame forKey:@"viewFrame"];
    [coder encodeBool:_expanded forKey:@"expanded"];
    [coder encodeObject:_sectionView forKey:@"sectionView"];
}

@end
