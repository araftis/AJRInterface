//
//  AJRPNGImageFormat.m
//  LDView
//
//  Created by alex on Thu Nov 15 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AJRPNGImageFormat.h"

@implementation AJRPNGImageFormat

+ (void)load {
    [AJRImageFormat registerFormat:self];
}

- (NSString *)name {
   return @"PNG (Portable Network Graphic)";
}

- (NSString *)extension {
   return @"png";
}

- (NSInteger)imageType {
	return NSBitmapImageFileTypePNG;
}

- (NSDictionary *)properties {
	return @{NSImageInterlaced:[NSNumber numberWithBool:[_progressiveCheck state]]};
}

@end
