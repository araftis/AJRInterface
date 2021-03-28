
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
