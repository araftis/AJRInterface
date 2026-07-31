//
//  NSImageRep+Extensions.h
//  AJRInterface
//
//  Created by AJ Raftis on 7/30/26.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImageRep (AJRInterfaceExtensions)

- (nullable CGImageRef)ajr_CGImage CF_RETURNS_NOT_RETAINED;

@end

NS_ASSUME_NONNULL_END
