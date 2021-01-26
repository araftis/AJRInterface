//
//  NSColorSpace+Extensions.m
//  MMFoundation
//
//  Created by AJ Raftis on 11/15/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

#import "NSColorSpace+Extensions.h"

@implementation NSColorSpace (AJRInterfaceExtensions)

+ (NSColorSpace *)ajr_colorSpaceWithName:(NSString *)name {
	CGColorSpaceRef cgColorSpace = NULL;
	if ([name isEqualToString:@"NSCalibratedRGBColorSpace"]) {
		cgColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    } else if ([name isEqualToString:@"NSCalibratedWhiteColorSpace"]) {
        cgColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
	} else {
		cgColorSpace = CGColorSpaceCreateWithName((__bridge CFStringRef)name);
	}
    NSColorSpace *colorSpace = nil;
    if (cgColorSpace) {
        colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:cgColorSpace];
        CGColorSpaceRelease(cgColorSpace);
	}
    return colorSpace;
}

- (NSString *)ajr_name {
    return (__bridge NSString *)CGColorSpaceGetName([self CGColorSpace]);
}

@end
