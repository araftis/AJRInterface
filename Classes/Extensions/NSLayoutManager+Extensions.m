
#import "NSLayoutManager+Extensions.h"

@implementation NSLayoutManager (AJRInterfaceExtensions)

static NSLayoutManager *_shared = nil;

+ (CGFloat)defaultLineHeightForFont:(NSFont *)font {
    if (_shared == nil) {
        _shared = [[NSLayoutManager alloc] init];
    }
    return [_shared defaultLineHeightForFont:font];
}

@end
