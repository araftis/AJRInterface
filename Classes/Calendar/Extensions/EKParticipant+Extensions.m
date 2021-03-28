
#import "EKParticipant+Extensions.h"

#import "AJRImages.h"

@implementation EKParticipant (AJRInterfaceExtensions)

- (NSImage *)statusImage {
    NSString *imageName = @"AJRCalendarStatusUnknown";

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
