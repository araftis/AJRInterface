
#import "AJRTIFFImageFormat.h"


@implementation AJRTIFFImageFormat

+ (void)load {
    [AJRImageFormat registerFormat:self];
}

- (void)awakeFromNib {
    const NSTIFFCompression *types;
    NSInteger count;
    NSInteger x;
    NSMenuItem *item;
    
    [NSBitmapImageRep getTIFFCompressionTypes:&types count:&count];
    
    [_compressionPopUp removeAllItems];
    for (x = 0; x < count; x++) {
        if (types[x] == NSTIFFCompressionJPEG) continue;
        [_compressionPopUp addItemWithTitle:[NSBitmapImageRep localizedNameForTIFFCompressionType:types[x]]];
        item = [_compressionPopUp lastItem];
        [item setTag:types[x]];
    }
}

- (NSString *)name {
    return @"TIFF (Tagged Image File Format)";
}

- (NSString *)extension {
    return @"tiff";
}

- (NSInteger)imageType {
	return NSBitmapImageFileTypeTIFF;
}

- (NSDictionary *)properties {
	return @{NSImageCompressionMethod:[NSNumber numberWithInteger:[[_compressionPopUp selectedItem] tag]]};
}

@end
