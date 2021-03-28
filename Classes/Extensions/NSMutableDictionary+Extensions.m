
#import "NSMutableDictionary+Extensions.h"

#import "NSUserDefaults+Extensions.h"

@implementation NSMutableDictionary (AJRInterfaceExtensions)

- (void)setColor:(NSColor *)color forKey:(id)key {
    if (color) {
        [self setObject:AJRStringFromColor(color) forKey:key];
    }
}
         
- (void)setFont:(NSFont *)font forKey:(id)key {
    if (font) {
        [self setObject:AJRStringFromFont(font) forKey:key];
    }
}

@end
