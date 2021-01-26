//
//  CalEvent-Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/12/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKEvent (Extensions)

- (NSString *)ajr_eventUID;

@end
