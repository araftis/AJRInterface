
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
