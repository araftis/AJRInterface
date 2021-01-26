//
//  AJRArrayController.h
//  AJRInterface
//
//  Created by Alex Raftis on 7/7/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRArrayController : NSArrayController
{
    NSMutableArray    *_observedKeyPathsQueue;
}

@end
