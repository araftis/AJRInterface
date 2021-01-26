//
//  AJRTopSeller-AJRInterface.m
//  AJRInterface
//
//  Created by Alex Raftis on 1/25/10.
//  Copyright 2010 Apple, Inc.. All rights reserved.
//

#import "AJRTopSeller-AJRInterface.h"

#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSObject-AJRUserInfo.h>
#import <AJRFoundation/NSObject-Extensions.h>
#import <AJRInterface/AJRProduct-Assets.h>

@implementation AJRTopSeller (AJRInterface)

- (void)_imageLoaded:(NSImage *)image {
    @synchronized (self) {
        [self willChangeValueForKey:@"image"];
        [__image release];
        __image = image;
        [self didChangeValueForKey:@"image"];
    }
}

- (void)perform_loadImage {
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:_imageUrl];
    [[self mainThreadProxy] _imageLoaded:image];
}

- (NSImage *)image {
    if (__image == nil) {
        @synchronized (self) {
            __image = [[AJRProduct unknownImage] retain];
            [[self backgroundOperationProxy] perform_loadImage];
        }
    }
    return __image;
}

@end
