/*
 NSColor+Extensions.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

#import "NSColor+Extensions.h"

#import "NSColorSpace+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRColorUtilities.h>

@interface AJRColorDecodingPlaceholder : NSObject <AJRXMLDecoding>

@end

@implementation AJRColorDecodingPlaceholder {
    NSColorSpaceModel _model;
    NSColorSpace *_colorSpace;
    CGFloat *_components;
    
    NSString *_colorSpaceName; // Name of the color space specific to device-N
    NSInteger _componentCount;
    
    NSString *_catalogName;
    NSString *_colorName;
    
    NSImage *_patternImage;
}

- (id)init {
    if ((self = [super init])) {
        _model = NSColorSpaceModelUnknown;
    }
    return self;
}

- (void)allocateComponents:(NSInteger)count {
    if (_components) {
        _components = (CGFloat *)NSZoneRealloc(NULL, _components, sizeof(CGFloat) * count);
    } else {
        _components = (CGFloat *)NSZoneMalloc(NULL, sizeof(CGFloat) * count);
    }
}

- (void)setColorSpace:(NSColorSpace *)colorSpace {
    _colorSpace = colorSpace;
    
    if (_colorSpace != nil) {
        _componentCount = [_colorSpace numberOfColorComponents];
        [self allocateComponents:_componentCount + 1];
    } else {
        if (_components) {
            NSZoneFree(NULL, _components);
            _components = NULL;
            _componentCount = 0;
        }
    }
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"colorSpace" setter:^(NSString * _Nonnull string) {
        [self setColorSpace:[NSColorSpace ajr_colorSpaceWithName:string]];
    }];
    [coder decodeFloatForKey:@"white" setter:^(float value) {
        self->_components[0] = value;
    }];
    [coder decodeFloatForKey:@"red" setter:^(float value) {
        self->_components[0] = value;
    }];
    [coder decodeFloatForKey:@"green" setter:^(float value) {
        self->_components[1] = value;
    }];
    [coder decodeFloatForKey:@"blue" setter:^(float value) {
        self->_components[2] = value;
    }];
    [coder decodeFloatForKey:@"cyan" setter:^(float value) {
        self->_components[0] = value;
    }];
    [coder decodeFloatForKey:@"magenta" setter:^(float value) {
        self->_components[1] = value;
    }];
    [coder decodeFloatForKey:@"yellow" setter:^(float value) {
        self->_components[2] = value;
    }];
    [coder decodeFloatForKey:@"black" setter:^(float value) {
        self->_components[3] = value;
    }];
    [coder decodeFloatForKey:@"alpha" setter:^(float value) {
        NSInteger componentCount = [self->_colorSpace numberOfColorComponents];
        if (componentCount != NSNotFound) {
            self->_components[componentCount] = value;
        }
    }];
    [coder decodeStringForKey:@"catalog" setter:^(NSString * _Nonnull string) {
        self->_catalogName = string;
    }];
    [coder decodeStringForKey:@"name" setter:^(NSString * _Nonnull string) {
        self->_colorName = string;
    }];
//    [coder decodeStringForKey:@"colorSpaceName" setter:^(NSString * _Nonnull string) {
//        self->_colorSpaceName = string;
//    }];
    [coder decodeIntegerForKey:@"componentCount" setter:^(NSInteger value) {
        if (self->_colorSpaceName != nil) {
            self->_componentCount = value;
            [self allocateComponents:self->_componentCount];
            // This may have to move out of here. I'm not sure if I can embed these or not...
            for (NSInteger x = 0; x < self->_componentCount; x++) {
                [coder decodeFloatForKey:AJRFormat(@"%d", (int)(x + 1)) setter:^(float value) {
                    if (self->_components && self->_componentCount < x) {
                        self->_components[x] = value;
                    }
                }];
            }
        }
    }];
    [coder decodeObjectForKey:@"patternImage" setter:^(id  _Nonnull object) {
        [self setColorSpace:nil];
        self->_patternImage = object;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    NSColor *color = nil;
    
    if (_colorSpace != nil) {
        color = [NSColor colorWithColorSpace:_colorSpace components:_components count:_colorSpace.numberOfColorComponents + 1];
    } else if (_patternImage != nil) {
        color = [NSColor colorWithPatternImage:_patternImage];
    } else if (_catalogName != nil && _colorName != nil) {
        color = [NSColor colorWithCatalogName:_catalogName colorName:_colorName];
    } else if (_model == NSColorSpaceModelGray
               || _model == NSColorSpaceModelRGB
               || _model == NSColorSpaceModelCMYK) {
        NSInteger count = [_colorSpace numberOfColorComponents];
        color = [NSColor colorWithColorSpace:_colorSpace components:_components count:count + 1];
    }
    
    return color;
}

@end

@implementation NSColor (AJRInterfaceExtensions)

+ (NSColor *)activeRegionColor {
    return [NSColor lightGrayColor];
}

+ (NSColor *)regionColor {
    return [NSColor darkGrayColor];
}

+ (NSColor *)assortmentIncludedColor {
    return [NSColor colorWithCalibratedRed:0.337 green:0.678 blue:0.259 alpha:1.0];
}

+ (NSColor *)assortmentExcludedColor {
    return [NSColor colorWithCalibratedRed:0.631 green:0.184 blue:0.196 alpha:1.0];
}

+ (NSColor *)assortmentMixedColor {
    return [NSColor colorWithCalibratedRed:0.914 green:0.773 blue:0.373 alpha:1.0];
}

+ (NSColor *)sourceBadgeColor {
    return [NSColor colorWithCalibratedRed:0.533 green:0.600 blue:0.737 alpha:1.0];
}

+ (NSColor *)sourceBadgeHighlightColor {
    return [NSColor whiteColor];
}

+ (NSColor *)sourceBadgeTextColor {
    return [NSColor sourceBadgeHighlightColor];
}

+ (NSColor *)sourceBadgeTextHighlightColor {
    return [self sourceBadgeColor];
}

+ (NSColor *)sourceActiveBackgroundColor {
    return [NSColor colorWithCalibratedRed:0.820 green:0.843 blue:0.886 alpha:1.0];
}

+ (NSColor *)sourceInactiveBackgroundColor {
    return [NSColor colorWithCalibratedRed:0.910 green:0.910 blue:0.910 alpha:1.0];
}

- (NSGradient *)gradient {
    CGFloat h,s,b,a;
    [[self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
    s *= 0.9;
    b *= 0.8;
    return [[NSGradient alloc] initWithStartingColor:self endingColor:[NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a]];
}

- (NSGradient *)strongGradient {
    CGFloat h,s,b,a;
    [[self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
    s *= 0.8;
    b *= 0.7;
    return [[NSGradient alloc] initWithStartingColor:self endingColor:[NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a]];
}

- (NSGradient *)gradientWithSaturationWeight:(CGFloat)saturationWeight andBrightnessWeight:(CGFloat)brightnessWeight; {
    CGFloat h,s,b,a;
    [[self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
    s *= saturationWeight;
    b *= brightnessWeight;
    if (s > 1.0) s = 1.0;
    if (b > 1.0) b = 1.0;
    return [[NSGradient alloc] initWithStartingColor:self endingColor:[NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a]];
}

- (NSColor *)colorByMultiplyingBrightness:(CGFloat)percent {
    NSColor *converted = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    if (converted) {
        CGFloat h,s,b,a;
        [converted getHue:&h saturation:&s brightness:&b alpha:&a];
        b *= percent;
        return [NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a];
    }
    return nil;
}

- (NSColor *)colorByMultiplyingSaturation:(CGFloat)percent {
    NSColor *converted = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    if (converted) {
        CGFloat h,s,b,a;
        [converted getHue:&h saturation:&s brightness:&b alpha:&a];
        s *= percent;
        return [NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a];
    }
    return nil;
}

- (NSColor *)colorByShiftingHue:(CGFloat)degreeDelta {
    NSColor *converted = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    if (converted) {
        CGFloat h,s,b,a;
        [converted getHue:&h saturation:&s brightness:&b alpha:&a];
        h += (degreeDelta / 360.0);
        return [NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a];
    }
    
    return nil;
}

- (NSColor *)colorByMultiplyingSaturation:(CGFloat)percent andBrightness:(CGFloat)brightnessPercent {
    NSColor *converted = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    if (converted) {
        CGFloat h,s,b,a;
        [converted getHue:&h saturation:&s brightness:&b alpha:&a];
        s *= percent;
        b *= brightnessPercent;
        return [NSColor colorWithCalibratedHue:h saturation:s brightness:b alpha:a];
    }

    return nil;
}

#pragma mark - AJRXMLCoding

+ (NSString *)ajr_nameForXMLArchiving {
    return @"color";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSColor class];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if (self.type == NSColorTypeComponentBased) {
        NSColorSpace *colorSpace = self.colorSpace;
        [coder encodeString:[colorSpace ajr_name] forKey:@"colorSpace"];
        if ([colorSpace colorSpaceModel] == NSColorSpaceModelGray) {
            [coder encodeFloat:[self whiteComponent] forKey:@"white"];
            [coder encodeFloat:[self alphaComponent] forKey:@"alpha"];
        } else if ([colorSpace colorSpaceModel] == NSColorSpaceModelRGB) {
            [coder encodeFloat:[self redComponent] forKey:@"red"];
            [coder encodeFloat:[self greenComponent] forKey:@"green"];
            [coder encodeFloat:[self blueComponent] forKey:@"blue"];
            [coder encodeFloat:[self alphaComponent] forKey:@"alpha"];
        } else if ([colorSpace colorSpaceModel] == NSColorSpaceModelCMYK) {
            [coder encodeFloat:[self cyanComponent] forKey:@"cyan"];
            [coder encodeFloat:[self magentaComponent] forKey:@"magenta"];
            [coder encodeFloat:[self yellowComponent] forKey:@"yellow"];
            [coder encodeFloat:[self blackComponent] forKey:@"black"];
            [coder encodeFloat:[self alphaComponent] forKey:@"alpha"];
        } else {
            NSInteger componentCount = [self numberOfComponents];
            CGFloat *components;
            
            CFStringRef name = CGColorSpaceCopyName([[self colorSpace] CGColorSpace]);
            [coder encodeString:(__bridge NSString *)name forKey:@"colorSpaceName"];
            CFRelease(name);
            components = (CGFloat *)malloc(sizeof(CGFloat) * componentCount);
            [self getComponents:components];
            [coder encodeInteger:componentCount forKey:@"componentCount"];
            for (NSInteger x = 0; x < componentCount; x++) {
                [coder encodeFloat:components[x] forKey:[NSString stringWithFormat:@"c%d", (int)(x + 1)]];
            }
            free(components);
        }
    } else if (self.type == NSColorTypeCatalog) {
        [coder encodeString:[self catalogNameComponent] forKey:@"catalog"];
        [coder encodeString:[self colorNameComponent] forKey:@"name"];
    } else if (self.type == NSColorTypePattern) {
        [coder encodeObject:[self patternImage] forKey:@"patternImage"];
    }
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRColorDecodingPlaceholder alloc] init];
}

#pragma mark - Creation Utilities

+ (NSColor *)colorFromHTMLString:(NSString *)html {
    CGColorRef color = AJRColorCreateFromHTMLString(html);
    return color ? [NSColor colorWithCGColor:color] : nil;
}

@end
