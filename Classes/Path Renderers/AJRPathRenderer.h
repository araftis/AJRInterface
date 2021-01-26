
#import <AppKit/AppKit.h>

extern NSString *AJRPathRendererDidUpdateNotification;

@interface AJRPathRenderer : NSObject <NSCoding,NSCopying>
{
}

+ (void)registerRenderer:(Class)aClass;

+ (NSString *)name;
+ (NSArray *)renderers;

+ (AJRPathRenderer *)rendererForName:(NSString *)name;
+ (AJRPathRenderer *)rendererForDictionary:(NSDictionary *)dictionary;

- (void)didChange;
- (void)renderPath:(NSBezierPath *)path;

@end
