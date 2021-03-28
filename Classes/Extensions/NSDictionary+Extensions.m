
#import "NSDictionary+Extensions.h"

#import "NSUserDefaults+Extensions.h"

#import <AJRFoundation/NSDictionary+Extensions.h>

@implementation NSDictionary (AJRInterfaceExtensions)

- (NSColor *)colorForKey:(id)key defaultValue:(NSColor *)defaultValue {
    NSString *string = [self stringForKey:key defaultValue:nil];
    NSColor *color = AJRColorFromString(string);
    
    return color ? color : defaultValue;
}

- (NSFont *)fontForKey:(id)key defaultValue:(NSFont *)defaultValue {
    NSString *string = [self stringForKey:key defaultValue:nil];
    NSFont *font = AJRFontFromString(string);
    
    return font ? font : defaultValue;
}

@end
