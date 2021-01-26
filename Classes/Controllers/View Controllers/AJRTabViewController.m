//
//  AJRTabViewController.m
//  Service Browser
//
//  Created by A.J. Raftis on 12/10/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRTabViewController.h"

@implementation AJRTabViewController

- (void)setView:(NSView *)view
{
    NSInteger        x;
    
    [super setView:view];
    
    [(NSTabView *)self.view setDelegate:self];
    
    for (x = [(NSTabView *)self.view numberOfTabViewItems] - 1; x >= 0; x--) {
        [(NSTabView *)self.view removeTabViewItem:[(NSTabView *)self.view tabViewItemAtIndex:x]];
    }
    
    for (NSString *name in [[self class] viewControllerNames]) {
        NSTabViewItem        *item;
        NSViewController    *viewController = [self viewControllerForName:name];
        
        item = [[NSTabViewItem alloc] initWithIdentifier:[viewController title]];
        [item setLabel:[viewController title]];
        [item setView:nil];
        [(NSTabView *)self.view addTabViewItem:item];
    }
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([tabViewItem view] == nil) {
        NSViewController    *viewController = [self viewControllerForName:[tabViewItem identifier]];
        
        if (viewController) {
            [tabViewItem setView:[viewController view]];
        }
    }
}

- (void)selectViewAtIndex:(NSUInteger)index
{
    if (index < [(NSTabView *)self.view numberOfTabViewItems]) {
        NSTabViewItem    *item = [(NSTabView *)self.view tabViewItemAtIndex:index];
        [self tabView:(NSTabView *)self.view willSelectTabViewItem:item];
        [(NSTabView *)self.view selectTabViewItem:item];
        
        [super selectViewAtIndex:index];
    }
}

@end
