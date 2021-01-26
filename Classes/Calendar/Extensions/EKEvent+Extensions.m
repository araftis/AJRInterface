//
//  CalEvent-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 10/12/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "EKEvent+Extensions.h"

#import <AJRFoundation/AJRFormat.h>

@implementation EKEvent (Extensions)

- (NSString *)ajr_eventUID
{
    return AJRFormat(@"%@/%@", [self eventIdentifier], [self startDate]);
}

@end
