
#import <AJRFoundation/AJRProduct.h>

extern NSString *AJRProductIconDidLoadNotification;

@interface AJRProduct (Assets)

+ (NSImage *)unknownImage;

// Asset management
- (NSDictionary *)ajrsetDataForSize:(NSString *)sizeString;
- (NSURL *)ajrsetURLForSize:(NSString *)sizeString;

- (NSArray *)imageSizes;
- (NSImage *)imageForSize:(NSString *)sizeString key:(NSString *)key loadGeneric:(BOOL)flag;
- (NSImage *)firstImageForSize:(NSArray *)sizeStrings key:(NSString *)key loadGeneric:(BOOL)loadGeneric;

- (NSImage *)galleryZoomImage;
- (NSImage *)galleryZoomHighImage;
- (NSImage *)galleryTourImage;
- (NSImage *)galleryMainImage;
- (NSImage *)galleryThumbImage;
- (NSImage *)mediumThumbImage;
- (NSImage *)galleryLargeImage;
- (NSImage *)galleryZoomMediumImage;
- (NSImage *)galleryZoomLowImage;
- (NSImage *)galleryZoomNoneImage;
- (NSImage *)pimSmallImage;
- (NSImage *)smallThumbImage;
- (NSImage *)pimMediumImage;

- (NSImage *)catalogImageForKey:(NSString *)key inMarketingContext:(AJRMarketingContext *)marketingContext;

- (NSImage *)preferredIconImage;

- (NSAttributedString *)nameAndPartNumber;

@end


