
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
