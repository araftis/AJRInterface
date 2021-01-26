//
//  AJRGeo-UI.m
//  AJRInterface
//
//  Created by Alex Raftis on 2/6/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import "AJRGeo-UI.h"

#import "AJRImages.h"

#import <Cocoa/Cocoa.h>

@implementation AJRGeo (UI)

- (NSImage *)image
{
    NSString    *name = AJRFormat(@"geo-%@", [self geoCode]);
    NSImage        *image = [AJRImages imageNamed:name forClass:[AJRImages class]];
    
    return image;
}

@end
