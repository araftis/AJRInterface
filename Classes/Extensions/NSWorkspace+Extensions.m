
#import "NSWorkspace+Extensions.h"

@implementation NSWorkspace (AJRInterfaceExtensions)

- (NSArray<NSURL *> *)applicationURLsForURL:(NSURL *)url {
	return CFBridgingRelease(LSCopyApplicationURLsForURL((__bridge CFURLRef)url, kLSRolesAll));
}

@end
