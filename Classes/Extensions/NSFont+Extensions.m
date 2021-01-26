//
//  NSFont+Extensions.m
//  AJRInterface
//
//  Created by AJ Raftis on 6/8/19.
//

#import "NSFont+Extensions.h"

#import "NSBezierPath+Extensions.h"

#import <objc/runtime.h>

@implementation NSFont (Extensions)

- (CGFloat)computedHHeight {
    NSNumber *height = objc_getAssociatedObject(self, @selector(computedHHeight));
    
    if (height == nil) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:NSZeroPoint];
        [path appendBezierPathWithString:@"H" font:self];
        
        height = @(path.bounds.size.height);
        objc_setAssociatedObject(self, @selector(computedHHeight), height, OBJC_ASSOCIATION_RETAIN);
    }
    
    return [height doubleValue];
}

@end
