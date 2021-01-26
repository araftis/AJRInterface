//
//  NSWorkspace+Extensions.h
//  AJRInterface
//
//  Created by AJ Raftis on 1/28/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWorkspace (AJRInterfaceExtensions)

- (NSArray<NSURL *> *)applicationURLsForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
