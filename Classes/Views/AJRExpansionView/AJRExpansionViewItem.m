
#import "AJRExpansionViewItem.h"

#import "AJRExpansionView.h"

static NSInteger titleCount = 0;

@implementation AJRExpansionViewItem

+ (void)initialize {
    [self exposeBinding:@"title"];
}


@synthesize title;

- (NSString *)title {
    @synchronized (self) {
        if (title == nil) {
            title = [NSString stringWithFormat:@"Untitled Section %ld", titleCount++];
        }
    }
    return title;
}

@end
