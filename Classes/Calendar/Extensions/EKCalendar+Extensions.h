//
//  CalCalendar.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/8/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKCalendar (AJRInterfaceExtensions)

- (NSString *)typeString;

- (NSString *)UID;

@end
