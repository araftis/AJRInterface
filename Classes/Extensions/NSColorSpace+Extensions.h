
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColorSpace (AJRInterfaceExtensions)

+ (nullable NSColorSpace *)ajr_colorSpaceWithName:(NSString *)name;
- (NSString *)ajr_name;

@end

NS_ASSUME_NONNULL_END
