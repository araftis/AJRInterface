//
//  NSWorkspace+Extensions.m
//  AJRInterface
//
//  Created by AJ Raftis on 1/28/19.
//

#import "NSWorkspace+Extensions.h"

@implementation NSWorkspace (AJRInterfaceExtensions)

- (NSArray<NSURL *> *)applicationURLsForURL:(NSURL *)url {
	return CFBridgingRelease(LSCopyApplicationURLsForURL((__bridge CFURLRef)url, kLSRolesAll));
}

@end
