//
//  NSViewController+Extensions.h
//  AJRInterface
//
//  Created by AJ Raftis on 10/17/18.
//

#import <Cocoa/Cocoa.h>

@interface NSViewController (Extensions)

- (NSViewController *)ajr_descendantViewControllerOfClass:(Class)viewControllerClass;

@end
