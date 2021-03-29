/*
AJRTerritoryObject.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#import "AJRTerritoryObject.h"

#import "AJRTerritoryCanvas.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRTerritoryObject

- (id)initWithGeoPath:(NSString *)geoPath {
    NSString *fsPath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSArray *parts = [geoPath componentsSeparatedByString:@"."];
    NSInteger x;
    NSData *data;
    
    fsPath = [fsPath stringByAppendingPathComponent:@"Territories"];
    for (x = 0; x < [parts count]; x++) {
        if (x == 0) {
            fsPath = [fsPath stringByAppendingPathComponent:[[parts objectAtIndex:x] lowercaseString]];
        } else if (x == 1) {
            fsPath = [fsPath stringByAppendingPathComponent:[[parts objectAtIndex:x] lowercaseString]];
        } else if (x == 2) {
            fsPath = [fsPath stringByAppendingPathComponent:[[parts objectAtIndex:x] uppercaseString]];
        } else {
            fsPath = [fsPath stringByAppendingPathComponent:[parts objectAtIndex:x]];
        }
    }
    fsPath = [fsPath stringByAppendingPathExtension:@"path"];
    
    data = [[NSData alloc] initWithContentsOfFile:fsPath];
    if (data) {
        // This probably isn't going to work.
		NSBezierPath *path = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSBezierPath class] fromData:data error:NULL];
        if (path) {
            self = [self initWithPath:path];
            self.label = geoPath;
            self.geoPath = geoPath;
        } else {
             self = nil;
        }
    } else {
         self = nil;
    }
    
    return self;
}

- (id)initWithPath:(NSBezierPath *)path {
    if ((self = [super init])) {
        self.path = path;
        self.foregroundColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
        self.backgroundColor = [NSColor darkGrayColor];
        self.label = @"";
        self.geoPath = @"";
    }
    return self;
}


- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (backgroundColor != _backgroundColor) {
        CGFloat        h, s, b, a;
        
        _backgroundColor = backgroundColor;
        
        [[_backgroundColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getHue:&h saturation:&s brightness:&b alpha:&a];
        s *= 1.1;
        b *= 1.2;
        _backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceHue:h saturation:s brightness:b alpha:a] endingColor:_backgroundColor];
    }
}

- (NSRect)bounds {
    return [self.path bounds];
}

- (void)drawInView:(AJRTerritoryCanvas *)canvas {
//    NSBezierPath    *path;
//    
//    path = [NSBezierPath bezierPathWithRect:[self bounds]];
//    [path setLineWidth:1.0 / [canvas scale]];
//    [[NSColor greenColor] set];
//    [path stroke];
    
    [_backgroundGradient drawInBezierPath:self.path angle:45.0];
    [self.foregroundColor set];
    [self.path setLineWidth:0.5 / [canvas scale]];
    [self.path stroke];
}

@end
