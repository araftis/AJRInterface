
#import "EKEvent+Extensions.h"

#import <AJRFoundation/AJRFormat.h>

@implementation EKEvent (Extensions)

- (NSString *)ajr_eventUID {
    return AJRFormat(@"%@/%@", [self eventIdentifier], [self startDate]);
}

@end
