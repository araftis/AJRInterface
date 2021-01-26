//
//  EKRecurrenceRule-Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/6/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKRecurrenceRule (AJRInterfaceExtensions)

+ (NSDateFormatter *)dateFormatter;

- (NSString *)ajr_frequencyString;
- (NSString *)ajr_frequencyIntervalString;
- (NSString *)ajr_frequencyEndString;

@end
