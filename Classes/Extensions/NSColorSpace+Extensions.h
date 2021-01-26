//
//  NSColorSpace+Extensions.h
//  MMFoundation
//
//  Created by AJ Raftis on 11/15/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColorSpace (AJRInterfaceExtensions)

+ (nullable NSColorSpace *)ajr_colorSpaceWithName:(NSString *)name;
- (NSString *)ajr_name;

@end

NS_ASSUME_NONNULL_END
