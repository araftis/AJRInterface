//
//  AJRGIFImageFormat.m
//  LDView
//
//  Created by alex on Thu Nov 15 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AJRGIFImageFormat.h"

@implementation AJRGIFImageFormat

+ (void)load {
	[AJRImageFormat registerFormat:self];
}

- (NSString *)name {
	return @"GIF (Graphics Interchange Format)";
}

- (NSString *)extension {
	return @"gif";
}

- (NSInteger)imageType {
	return NSBitmapImageFileTypeGIF;
}

- (NSDictionary *)properties {
	return @{NSImageDitherTransparency:[NSNumber numberWithBool:[_ditherTransparencyCheck state]]};
}

@end
