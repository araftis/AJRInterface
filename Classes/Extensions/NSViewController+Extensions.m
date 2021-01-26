//
//  NSViewController+Extensions.m
//  AJRInterface
//
//  Created by AJ Raftis on 10/17/18.
//

#import "NSViewController+Extensions.h"

@implementation NSViewController (Extensions)

- (NSViewController *)ajr_descendantViewControllerOfClass:(Class)viewControllerClass {
	if ([self class] == viewControllerClass) {
		return self;
	}
	for (NSViewController *child in [self childViewControllers]) {
		NSViewController *possible = [child ajr_descendantViewControllerOfClass:viewControllerClass];
		if (possible) {
			return possible;
		}
	}
	return Nil;
}

@end
