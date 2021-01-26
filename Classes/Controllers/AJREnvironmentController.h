//
//  AJREnvironmentController.h
//  AJRInterface
//
//  Created by Alex Raftis on 11/14/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJREnvironment;

@interface AJREnvironmentController : NSArrayController <NSCoding>
{
    NSString        *_environmentName;
}

- (void)setEnvironment:(AJREnvironment *)environment;
- (AJREnvironment *)environment;

@end
