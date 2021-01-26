//
//  AJRAssortmentSetItem-UI.m
//  AJRInterface
//
//  Created by Alex Raftis on 10/15/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRAssortmentSetItem-UI.h"

#import "NSColor-Extensions.h"

@implementation AJRAssortmentSetItem (UI)

- (NSColor *)typeColor
{
    if (self.type == AJRAssortmentTypeIncluded) {
        return [NSColor ajrsortmentIncludedColor];
    }
    return [NSColor ajrsortmentExcludedColor];
}

- (NSColor *)statusColor
{
    NSString    *status = [self status];
    
    if ([status isEqualToString:AJRAssortmentIncludedStatus]) {
        return [NSColor ajrsortmentIncludedColor];
    } else if ([status isEqualToString:AJRAssortmentExcludedStatus]) {
        return [NSColor ajrsortmentExcludedColor];
    } else if ([status isEqualToString:AJRAssortmentPreviewStatus]) {
        return [NSColor ajrsortmentMixedColor];
    } else if ([status isEqualToString:AJRAssortmentEndOfLifeStatus]) {
        return [NSColor ajrsortmentExcludedColor];
    }
    return [NSColor controlTextColor];
}

@end
