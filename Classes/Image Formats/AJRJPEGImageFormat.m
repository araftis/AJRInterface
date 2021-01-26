//
//  AJRJPEGImageFormat.m
//  LDView
//
//  Created by alex on Thu Nov 15 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AJRJPEGImageFormat.h"

@implementation AJRJPEGImageFormat

+ (void)load {
    [AJRImageFormat registerFormat:self];
}

- (NSString *)name {
   return @"JPEG (Joint Photographic Extension Group)";
}

- (NSString *)extension {
   return @"jpg";
}

- (NSInteger)imageType {
	return NSBitmapImageFileTypeJPEG;
}

- (NSDictionary *)properties {
	return @{NSImageCompressionFactor:[NSNumber numberWithFloat:[_qualitySlider floatValue] / 100.0]};
}

@end
