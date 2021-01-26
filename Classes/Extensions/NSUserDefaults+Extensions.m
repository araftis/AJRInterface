
#import "NSUserDefaults+Extensions.h"

#import "NSColor+Extensions.h"
#import "NSColorSpace+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/AJRLogging.h>

NSString *AJRStringFromColor(NSColor *color) {
    NSString *description = nil;
    
    if ([color type] == NSColorTypeCatalog) {
        description = AJRFormat(@"%@ %@ %@", NSNamedColorSpace, [color catalogNameComponent], [color colorNameComponent]);
    } else if ([color type] == NSColorTypePattern) {
        AJRLogWarning(@"We don't handle converting pattern colors spaces to a string.");
    } else if ([color type] == NSColorTypeComponentBased) {
        NSColorSpace *colorSpace = [color colorSpace];
        NSInteger count = [colorSpace numberOfColorComponents];
        NSMutableString *work = [[colorSpace ajr_name] mutableCopy];
        CGFloat components[count + 1];
        [color getComponents:components];
        for (NSInteger x = 0; x < count + 1; x++) {
            [work appendFormat:@" %.6f", components[x]];
        }
        description = work;
    }
    
    return description;
}

NSColor *AJRColorFromString(NSString *string) {
    NSArray *parts;
    NSString *colorSpaceName;
    NSColor *color = nil;
    
    if (!string) return nil;
    
    parts = [string componentsSeparatedByString:@" "];
    colorSpaceName = [parts objectAtIndex:0];
    if ([colorSpaceName isEqualToString:@"NSNamedColorSpace"]) {
        color = [NSColor colorWithCatalogName:[parts objectAtIndex:1] colorName:[parts objectAtIndex:2]];
    } else {
        NSColorSpace *colorSpace = [NSColorSpace ajr_colorSpaceWithName:colorSpaceName];
        if (colorSpace) {
            NSInteger count = [colorSpace numberOfColorComponents];
            CGFloat components[count + 1];
            for (NSInteger x = 0; x < count + 1; x++) {
                if (x + 1 >= [parts count]) {
                    components[x] = 1.0;
                } else {
                    components[x] = [[parts objectAtIndex:x + 1] doubleValue];
                }
            }
            color = [NSColor colorWithColorSpace:colorSpace components:components count:count + 1];
        }
    }
    if (color == nil) {
        color = [NSColor whiteColor];
        AJRLogWarning(@"Couldn't map color %@", string);
    }
    
    return color;
}

NSString *AJRStringFromFont(NSFont *font) {
    return [NSString stringWithFormat:@"%@ %.1f", [font fontName], [font pointSize]];
}

NSFont *AJRFontFromString(NSString *value) {
    if (value) {
        NSRange range = [value rangeOfString:@" " options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString *name = [value substringToIndex:range.location];
            float size = [[value substringFromIndex:range.location] floatValue];
            NSFont *font;
            
            font = [NSFont fontWithName:name size:size];
            if (font) return font;
            
            font = [[NSFontManager sharedFontManager] fontWithFamily:name traits:0 weight:5 size:size];
            if (font) return font;
        }
    }
    
    return nil;
}

@implementation NSUserDefaults (AJRInterfaceExtensions)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)key {
    [self setObject:AJRStringFromColor(aColor) forKey:key];
}

- (NSColor *)colorForKey:(NSString *)key {
    return AJRColorFromString([self stringForKey:key]);
}

- (void)setPrintInfo:(NSPrintInfo *)anInfo forKey:(NSString *)aKey {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:anInfo requiringSecureCoding:NO error:NULL];
    if (data) {
        [self setObject:data forKey:aKey];
    }
}

- (NSPrintInfo *)printInfoForKey:(NSString *)aKey {
    NSData *data;
    NSPrintInfo *info = nil;
    
    if ((data = [self objectForKey:aKey])) {
        @try {
            // This probably isn't going to work.
            info = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSPrintInfo class] fromData:data error:NULL];
        } @catch (NSException *localException) {
        }
    }
    
    return info ?: [NSPrintInfo sharedPrintInfo];
}

- (void)setFont:(NSFont *)aFont forKey:(NSString *)aKey {
    [self setObject:AJRStringFromFont(aFont) forKey:aKey];
}

- (NSFont *)fontForKey:(NSString *)key {
    return AJRFontFromString([self objectForKey:key]);
}

- (NSFont *)fontForKey:(NSString *)key defaultFont:(NSFont *)defaultFont {
    NSString *value = [self objectForKey:key];
    
    if (value == nil) return defaultFont;
    
    if (value) {
        NSRange    range = [value rangeOfString:@" "];
        if (range.location != NSNotFound) {
            NSString *name = [value substringToIndex:range.location];
            CGFloat size = [[value substringFromIndex:range.location] floatValue];
            NSFont *font = [NSFont fontWithName:name size:size];
            
            if (font) return font;
        }
    }
    
    return [NSFont fontWithName:@"Courier" size:12.0];
}

- (NSSize)sizeForKey:(NSString *)key {
    NSString *sizeString = [self stringForKey:key];
    NSSize size = NSZeroSize;
    
    if (sizeString) {
        size = NSSizeFromString(sizeString);
    }
    
    return size;
}

- (void)setSize:(NSSize)size forKey:(NSString *)key {
    [self setObject:NSStringFromSize(size) forKey:key];
}

@end
