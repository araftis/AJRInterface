//
//  AJRTerritoryObject.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/13/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRTerritoryCanvas;

@interface AJRTerritoryObject : NSObject
{
    NSBezierPath    *_path;
    NSColor            *_backgroundColor;
    NSGradient        *_backgroundGradient;
    NSColor            *_foregroundColor;
    NSString        *_label;
    NSString        *_geoPath;
}

- (id)initWithGeoPath:(NSString *)path;
- (id)initWithPath:(NSBezierPath *)path;

@property (nonatomic,strong) NSBezierPath *path;
@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSColor *foregroundColor;
@property (nonatomic,strong) NSString *label;
@property (nonatomic,strong) NSString *geoPath;

- (NSRect)bounds;

- (void)drawInView:(AJRTerritoryCanvas *)canvas;

@end
