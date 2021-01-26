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
