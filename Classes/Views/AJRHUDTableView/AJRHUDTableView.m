//
//  AJRHUDTableView.m
//  AJRInterface
//
//  Created by A.J. Raftis on 2/18/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRHUDTableView.h"

#import <AJRFoundation/AJRFunctions.h>

@interface NSTableView (ApplePrivate)

- (id)_alternatingRowBackgroundColors;

@end


@implementation AJRHUDTableView

- (id)_alternatingRowBackgroundColors
{
    return [NSArray arrayWithObjects:[[NSColor blackColor] colorWithAlphaComponent:0.700], [[NSColor blackColor] colorWithAlphaComponent:0.725], nil];
}

@end
