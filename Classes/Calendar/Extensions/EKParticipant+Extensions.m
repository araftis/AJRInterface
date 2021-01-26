//
//  CalAttendee.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/6/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "EKParticipant+Extensions.h"

#import "AJRImages.h"

@implementation EKParticipant (AJRInterfaceExtensions)

- (NSImage *)statusImage
{
    NSString    *imageName = @"AJRCalendarStatusUnknown";

    switch ([self participantStatus]) {
        case EKParticipantStatusUnknown:
            imageName = @"AJRCalendarStatusMalformed";
            break;
        case EKParticipantStatusPending:
            break;
        case EKParticipantStatusAccepted:
            imageName = @"AJRCalendarStatusAccepted";
            break;
        case EKParticipantStatusDeclined:
            imageName = @"AJRCalendarStatusDeclined";
            break;
        case EKParticipantStatusTentative:
            imageName = @"AJRCalendarStatusMaybe";
            break;
        case EKParticipantStatusDelegated:
            break;
        case EKParticipantStatusCompleted:
            break;
        case EKParticipantStatusInProcess:
            break;
    }
    
    return [AJRImages imageNamed:imageName forClass:[AJRImages class]];
}

@end
