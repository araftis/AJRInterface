
#import "NSBundle+Extensions.h"

@implementation NSBundle (AJRInterfaceExtensions)

+ (BOOL)ajr_loadNibNamed:(NSString *)name owner:(id)owner {
    return [[NSBundle bundleForClass:[owner class]] loadNibNamed:name owner:owner topLevelObjects:NULL];
}

+ (BOOL)ajr_loadNibNamed:(NSString *)name owner:(id)owner topLevelObjects:(NSArray **)array {
    return [[NSBundle bundleForClass:[owner class]] loadNibNamed:name owner:owner topLevelObjects:array];
}

@end
