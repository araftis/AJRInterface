//
//  NSTreeController-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 10/21/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "NSTreeController+Extensions.h"

@implementation NSTreeController (AJRInterfaceExtensions)

- (void)_selectFirstObject {
    [self setSelectionIndexPath:[NSIndexPath indexPathWithIndex:0]];
}

- (IBAction)selectFirstObject:(id)sender {
    [self selectFirstObject];
}

- (void)selectFirstObject {
    [self performSelector:@selector(_selectFirstObject) withObject:nil afterDelay:0.1];
}

@end
