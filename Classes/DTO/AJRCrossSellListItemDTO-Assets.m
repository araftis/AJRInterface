/*
 AJRCrossSellListItemDTO-Assets.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
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
//  AJRCrossSellListItemDTO.m
//  AJRInterface
//
//  Created by Nick Gillett on 1.4.09.
//  Copyright 2009 Apple Inc.. All rights reserved.
//

#import <AJRFoundation/AJRCrossSellListItemDTO.h>
#import "AJRCrossSellListItemDTO-Assets.h"

#import <Log4Cocoa/Log4Cocoa.h>

@interface AJRCrossSellListItemDTO (Private)

+(NSDictionary *)getBadgeMap;

@end

@implementation AJRCrossSellListItemDTO (Assets)

#pragma mark Image Methods
- (NSImage *)badgeImage {
    //get our bundle
    NSBundle *myBundle = [NSBundle bundleWithIdentifier:@"com.apple.store.interface"];
    NSDictionary *badgeMap = [AJRCrossSellListItemDTO getBadgeMap];
    //NSLog(@"Bundle: %@\n", myBundle);
    
    //get the image for this badge path
    NSString *imageName = [badgeMap valueForKey:self.sourceBadge];
    NSString *path = [myBundle pathForImageResource:imageName];
    
    //NSLog(@"Bundle Path: %@\n", path);
    NSImage *image = [[NSImage alloc]initWithContentsOfFile:path];
    log4Debug(@"Image: %@", image);
    if(![image isValid]) {
        log4Error(@"Image is not valid: %@", image);
        return nil;
    }
    
    return image;
}

+(NSDictionary *)getBadgeMap {
    NSDictionary *badgeMap = [[NSDictionary alloc]initWithObjectsAndKeys:@"algorithm", @"ALGORITHM", @"whiteList", @"XSELL_WHITE_LIST",
                                                        @"blackList", @"XSELL_BLACK_LIST", @"pimList", @"PIM_LIST",
                                                        @"globalList", @"PIM_GLOBAL_DEFAULT_LIST", nil];
    
    return badgeMap;
}

@end
