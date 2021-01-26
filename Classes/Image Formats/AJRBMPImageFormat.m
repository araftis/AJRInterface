//
//  AJRBMPImageFormat.m
//  LDView
//
//  Created by alex on Thu Nov 15 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AJRBMPImageFormat.h"

@implementation AJRBMPImageFormat

+ (void)load {
    [AJRImageFormat registerFormat:self];
}

- (NSString *)name {
   return @"BMP (Windows Bitmap)";
}

- (NSString *)extension {
   return @"bmp";
}

- (NSInteger)imageType {
	return NSBitmapImageFileTypeBMP;
}

- (NSDictionary *)properties {
   return [NSDictionary dictionary];
}

@end
