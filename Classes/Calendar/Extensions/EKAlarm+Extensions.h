//
//  EKAlarm-Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/6/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKAlarm (AJRInterfaceExtensions)

- (NSString *)ajr_typeString;
- (NSString *)ajr_typeSubstring;
- (NSString *)ajr_triggerString;

@end
