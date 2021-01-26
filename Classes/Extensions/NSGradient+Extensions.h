//
//  NSGradient+Extensions.h
//  AJRInterface
//
//  Created by AJ Raftis on 1/25/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSGradient (AJRInterfaceExtensions)

- (void)strokeBezierPath:(NSBezierPath *)path angle:(CGFloat)angle;

@end

NS_ASSUME_NONNULL_END
