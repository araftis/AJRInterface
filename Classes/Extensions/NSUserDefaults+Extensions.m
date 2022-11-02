/*
 NSUserDefaults+Extensions.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
                    // This may seam strange, but we only store colors (in strings) to five places of accuracy, which is sufficient that no one would be able to tell the difference, but it's common for colors to be 1/3 or 2/3, which produce repeating decimals. As such, if we detect these out to five places, convert to the repeating value.
                    if (AJRApproximateEquals(components[x], 1.0 / 3.0, 5)) {
                        components[x] = 1.0 / 3.0;
                    }
                    if (AJRApproximateEquals(components[x], 2.0 / 3.0, 5)) {
                        components[x] = 2.0 / 3.0;
                    }
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
