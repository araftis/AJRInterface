
#import "NSGraphicsContext+Extensions.h"

@implementation NSGraphicsContext (AJRInterfaceExtensions)

- (void)drawWithSavedGraphicsState:(void (^)(NSGraphicsContext *context))block {
	[self saveGraphicsState];
	block(self);
	[self restoreGraphicsState];
}

+ (void)drawInContext:(CGContextRef)context withBlock:(void (^)(void))block {
	// See: http://stackoverflow.com/questions/715750/ugly-looking-text-when-drawing-nsattributedstring-in-cgcontext
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext *graphics = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
	[NSGraphicsContext setCurrentContext:graphics];
	block();
	[NSGraphicsContext restoreGraphicsState];
}

@end
