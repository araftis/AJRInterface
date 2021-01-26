//
//  AJRBoxController.m
//  Service Browser
//
//  Created by A.J. Raftis on 12/10/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRBoxController.h"

#import "AJRViewController.h"

@implementation AJRBoxController

- (void)selectViewAtIndex:(NSUInteger)index
{
    NSString            *name = [[[self class] viewControllerNames] objectAtIndex:index];
    NSViewController    *viewController = [self viewControllerForName:name];
    NSView                *view = [viewController view];
    
    if (view) {
        [(NSBox *)self.view setContentView:view];
    }
    [(NSBox *)self.view setTitle:[viewController title]];
    
    [super selectViewAtIndex:index];
}

@end
