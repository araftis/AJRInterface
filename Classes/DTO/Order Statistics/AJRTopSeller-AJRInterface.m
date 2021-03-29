/*
AJRTopSeller-AJRInterface.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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
