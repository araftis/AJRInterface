
#import <AppKit/AppKit.h>

@interface AJRImageFormat : NSObject {
   IBOutlet NSView *view;
}

+ (void)registerFormat:(Class)aClass;
+ (NSArray *)formatNames;

+ (AJRImageFormat *)imageFormatForName:(NSString *)name;

- (NSString *)name;
- (NSString *)extension;
- (NSView *)view;
- (NSInteger)imageType;
- (NSDictionary *)properties;

@end
