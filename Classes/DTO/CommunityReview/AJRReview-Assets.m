//
//  AJRReview-Assets.m
//  AJRInterface
//
//  Created by Scottie on 11/6/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRReview-Assets.h"
#import "AJRProduct-Assets.h"
#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRFoundation.h>

@implementation AJRReview (Assets)

- (NSImage *)largeImage
{
    return [[self product] preferredIconImage]; 
}

- (NSImage *)smallImage
{
    return [[self product] preferredIconImage];
}

@end
