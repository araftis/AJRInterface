//
//  NSLayoutManager-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 12/1/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "NSLayoutManager+Extensions.h"

@implementation NSLayoutManager (AJRInterfaceExtensions)

static NSLayoutManager *_shared = nil;

+ (CGFloat)defaultLineHeightForFont:(NSFont *)font {
    if (_shared == nil) {
        _shared = [[NSLayoutManager alloc] init];
    }
    return [_shared defaultLineHeightForFont:font];
}

@end
