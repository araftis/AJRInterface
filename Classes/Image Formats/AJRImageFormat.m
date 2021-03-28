
#import "AJRImageFormat.h"

#import "NSBundle+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

static NSMutableDictionary        *_formats = nil;

@implementation AJRImageFormat

+ (void)initialize {
    if (_formats == nil) {
        _formats = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerFormat:(Class)aClass {
    AJRImageFormat *instance = [[aClass alloc] init];
    
    [_formats setObject:instance forKey:[instance name]];
}

+ (NSArray *)formatNames {
    return [[_formats allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (AJRImageFormat *)imageFormatForName:(NSString *)name {
    return [_formats objectForKey:name];
}

- (NSString *)name {
    return nil;
}

- (NSString *)extension {
    return nil;
}

- (NSView *)view {
    if (!view) {
        [NSBundle ajr_loadNibNamed:NSStringFromClass([self class]) owner:self];
    }
    
    return view;
}

- (NSInteger)imageType {
    return -1;
}

- (NSDictionary *)properties {
    return nil;
}

@end
