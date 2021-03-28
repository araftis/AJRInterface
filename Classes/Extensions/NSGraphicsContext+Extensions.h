
#import <Cocoa/Cocoa.h>

@interface NSGraphicsContext (AJRInterfaceExtensions)

- (void)drawWithSavedGraphicsState:(void (^)(NSGraphicsContext *context))block;

+ (void)drawInContext:(CGContextRef)context withBlock:(void (^)(void))block;

@end
