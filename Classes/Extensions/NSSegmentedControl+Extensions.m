
#import "NSSegmentedControl+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <objc/runtime.h>

#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
static const char *keys[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20" };
#endif

@implementation NSSegmentedControl (AJRInterfaceExtensions)

- (void)translateWithTranslator:(AJRTranslator *)translator {
	for (NSInteger x  = 0, max = [self segmentCount]; x < max; x++) {
		NSString *key = nil;
		NSString *translation;
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
        const char *subkey = keys[x];
        key = objc_getAssociatedObject(self, subkey);
        if (key == nil) {
            key = [self labelForSegment:x];
            objc_setAssociatedObject(self, subkey, key, OBJC_ASSOCIATION_RETAIN);
        }
#else
		key = [self labelForSegment:x];
#endif
		translation = [translator valueForKey:key];
		[self setLabel:translation forSegment:x];
	}
	
	[self sizeToFit];
}

@end
