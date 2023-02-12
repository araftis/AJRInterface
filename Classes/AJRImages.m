/*
 AJRImages.m
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

#import "AJRImages.h"

#import "AJRInterfaceFunctions.h"
#import "NSUserDefaults+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

NSString *AJRDownArrowTemplateName = @"AJRDownArrowTemplate";

static NSMutableDictionary *imageCache = nil;
static NSMutableDictionary *checkboxImagesCache = nil;

@implementation AJRImages   

+ (void)initialize {
    if (imageCache == nil) {
        imageCache = [[NSMutableDictionary alloc] init];
        checkboxImagesCache = [[NSMutableDictionary alloc] init];
    }
}

+ (NSMutableDictionary *)imageCacheForBundle:(NSBundle *)bundle {
    NSMutableDictionary *cache = [imageCache objectForKey:[bundle bundlePath]];
    
    if (cache == nil) {
        cache = [[NSMutableDictionary alloc] init];
        [imageCache setObject:cache forKey:[bundle bundlePath]];
    }
    
    return cache;
}

+ (NSImage *)imageNamed:(NSString *)name {
    return [self imageNamed:name forClass:self];
}

+ (NSImage *)imageNamed:(NSString *)name forObject:(id)object {
    return [self imageNamed:name forClass:[object class]];
}

+ (NSImage *)imageNamed:(NSString *)name forClass:(id)class {
    return [self imageNamed:name inBundle:[NSBundle bundleForClass:class]];
}

+ (NSImage *)imageForObject:(id)object {
    return [self imageForClass:[object class]];
}

+ (NSImage *)imageForClass:(id)class {
    return [self imageNamed:NSStringFromClass(class) inBundle:[NSBundle bundleForClass:class]];
}

+ (NSImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    NSMutableDictionary *cache = [self imageCacheForBundle:bundle];
    NSImage *image = [cache objectForKey:name];
    
    if (image == nil) {
        NSString        *path;
        
        path = [bundle pathForResource:name ofType:@"tiff"];
        if (path == nil) {
            path = [bundle pathForResource:name ofType:@"png"];
        }
        if (path == nil) {
            path = [bundle pathForResource:name ofType:@"tif"];
        }
        if (path == nil) {
            path = [bundle pathForResource:name ofType:@"icns"];
        }
        if (path == nil) {
            path = [bundle pathForResource:name ofType:@"gif"];
        }
        if (path == nil) {
            path = [bundle pathForResource:name ofType:@"jpg"];
        }
        if (path == nil) {
            path = [bundle pathForResource:name ofType:@"psd"];
        }
        if (path == nil) {
            image = [bundle imageForResource:name];
        }
        if (image == nil && path == nil && bundle != [NSBundle bundleForClass:self]) {
            // As a last attempt, see if we can return a shared image from our own bundle.
            return [self imageNamed:name inBundle:[NSBundle bundleForClass:self]];
        }
        if (path != nil) {
            image = [[NSImage alloc] initWithContentsOfFile:path];
        }
        if (image != nil) {
            [cache setObject:image forKey:name];
            [image setName:name];
            if (!image.isTemplate && [name hasSuffix:@"Template"]) {
                [image setTemplate:YES];
            }
        }
    }
    return image;
}

+ (nullable NSImage *)imageNamed:(NSString *)name inBundles:(NSArray<NSBundle *> *)bundles {
    for (NSBundle *bundle in bundles) {
        NSImage *image = [self imageNamed:name inBundle:bundle];
        if (image != nil) {
            return image;
        }
    }
    return nil;
}

+ (NSImage *)compositeCheckbox:(NSArray *)pieces {
    NSImage *image = [[NSImage alloc] initWithSize:(NSSize){14.0, 15.0}];
    
    [image lockFocus];
    for (id piece in pieces) {
        if ([piece isKindOfClass:[NSColor class]]) {
            NSBezierPath    *path = [[NSBezierPath alloc] init];
            [(NSColor *)piece set];
            [path appendBezierPathWithRoundedRect:(NSRect){{1.0, 1.0}, {12.0, 12.0}} xRadius:2.0 yRadius:2.0];
            [path fill];
        } else {
            NSImage        *image = [self imageNamed:piece forClass:self];
            [image drawAtPoint:NSZeroPoint fromRect:(NSRect){NSZeroPoint, [image size]} operation:NSCompositingOperationSourceOver fraction:1.0];
        }
    }
    [image unlockFocus];
    
    return image;
}

+ (NSArray *)checkBoxImagesForColor:(NSColor *)color {
    NSString *key = AJRStringFromColor(color);
    NSMutableArray *images = [checkboxImagesCache objectForKey:key];
    
    if (images == nil) {
        images = [[NSMutableArray alloc] init];
        [checkboxImagesCache setObject:images forKey:key];
        
        [images addObject:[self compositeCheckbox:[NSArray arrayWithObjects:@"AJRCheckboxShadow", color, @"AJRCheckboxOverlay", nil]]];
        [images addObject:[self compositeCheckbox:[NSArray arrayWithObjects:@"AJRCheckboxShadow", color, @"AJRCheckboxOverlayH", nil]]];
        [images addObject:[self compositeCheckbox:[NSArray arrayWithObjects:@"AJRCheckboxShadow", color, @"AJRCheckboxOverlay", @"AJRCheckboxCheck", nil]]];
        [images addObject:[self compositeCheckbox:[NSArray arrayWithObjects:@"AJRCheckboxShadow", color, @"AJRCheckboxOverlayH", @"AJRCheckboxCheck", nil]]];
        [images addObject:[self compositeCheckbox:[NSArray arrayWithObjects:@"AJRCheckboxShadow", color, @"AJRCheckboxOverlay", @"AJRCheckboxDash", nil]]];
        [images addObject:[self compositeCheckbox:[NSArray arrayWithObjects:@"AJRCheckboxShadow", color, @"AJRCheckboxOverlayH", @"AJRCheckboxDash", nil]]];
    }
    
    return images;
}

+ (NSImage *)viewBorderImageFocused {
	return [self imageNamed:@"AJRViewBorderFocused" forClass:[AJRImages class]];
}

+ (NSImage *)viewBorderImageUnfocused {
	return [self imageNamed:@"AJRViewBorderUnfocused" forClass:[AJRImages class]];
}

+ (NSImage *)dotWithColor:(AJRDotColor)color controlSize:(NSControlSize)controlSize {
    NSString *colorString = @"Black";
    switch (color) {
        case AJRDotColorBlack:   colorString = @"Black";   break;
        case AJRDotColorGray:    colorString = @"Gray";    break;
        case AJRDotColorWhite:   colorString = @"White";   break;
        case AJRDotColorRed:     colorString = @"Red";     break;
        case AJRDotColorYellow:  colorString = @"Yellow";  break;
        case AJRDotColorGreen:   colorString = @"Green";   break;
        case AJRDotColorCyan:    colorString = @"Cyan";    break;
        case AJRDotColorBlue:    colorString = @"Blue";    break;
        case AJRDotColorMagenta: colorString = @"Magenta"; break;
    }
    
    NSString *sizeString = @"";
    switch (controlSize) {
        case NSControlSizeRegular: sizeString = @"";      break;
        case NSControlSizeSmall:   sizeString = @"Small"; break;
        case NSControlSizeMini:    sizeString = @"Mini";  break;
        case NSControlSizeLarge:   sizeString = @"Large"; break;
    }
    
    NSString *name = AJRFormat(@"AJRDot%@%@", sizeString, colorString);
    
    return [self imageNamed:name inBundle:AJRInterfaceBundle()];
}

@end
