//
//  AJRTerritoryViewer.m
//  AJRInterface
//
//  Created by A.J. Raftis on 10/13/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRTerritoryViewer.h"

#import "AJRTerritoryCanvas.h"
#import "AJRTerritoryObject.h"
#import "NSColor+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRTerritoryViewer

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        NSView    *contentView;
        
        [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self topLevelObjects:nil];
        
        contentView = [self.canvas superview];
        [self addSubview:contentView];
        [contentView setFrame:[self bounds]];
        [contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self.canvas addGeoPath:@"ww.amr"];
        [self.canvas addGeoPath:@"ww.apac"];
        [self.canvas addGeoPath:@"ww.emea"];
        [self.canvas addGeoPath:@"ww.japan"];
        [self.canvas addGeoPath:@"ww.antarctic"];
        
        _activeRegionColor = [NSColor activeRegionColor];
        _regionColor = [NSColor regionColor];
        _includedColor = [NSColor assortmentIncludedColor];
        _excludedColor = [NSColor assortmentExcludedColor];
        _mixedColor = [NSColor assortmentMixedColor];
    }
    
    return self;
}


@synthesize canvas = _canvas;

- (IBAction)selectWorld:(id)sender
{
}

- (IBAction)selectAMR:(id)sender
{
}

- (IBAction)selectAPAC:(id)sender
{
}

- (IBAction)selectEMEA:(id)sender
{
}

- (IBAction)selectJAPAN:(id)sender
{
}

- (IBAction)takeZoomValueFrom:(id)sender
{
    [self.canvas takeZoomValueFrom:sender];
}

- (void)setFrameSize:(NSSize)size
{
    [super setFrameSize:size];
    [self.canvas recomputeScale];
}

- (AJRTerritoryObject *)addGeoPath:(NSString *)geoPath
{
    return [self.canvas addGeoPath:geoPath];
}

- (void)removeGeoPath:(NSString *)geoPath
{
    return [self.canvas removeGeoPath:geoPath];
}

- (AJRTerritoryObject *)objectForGeoPath:(NSString *)geoPath
{
    return [self.canvas objectForGeoPath:geoPath];
}

- (void)_updateColors
{
    for (AJRTerritoryObject *object in self.canvas.objects) {
        NSString    *geoPath = [object geoPath];
        if ([geoPath isEqualToString:@"ww.amr"] ||
            [geoPath isEqualToString:@"ww.apac"] ||
            [geoPath isEqualToString:@"ww.emea"] ||
            [geoPath isEqualToString:@"ww.japan"] ||
            [geoPath isEqualToString:@"ww.antarctic"] ||
            [geoPath isEqualToString:@"ww"]) {
            [object setBackgroundColor:_regionColor];
        } else {
            [object setBackgroundColor:_activeRegionColor];
        }
    }
    
    [self setNeedsDisplay:YES];
}

@synthesize activeRegionColor = _activeRegionColor;

- (void)setActiveRegionColor:(NSColor *)aColor
{
    if (_activeRegionColor != aColor) {
        _activeRegionColor = aColor;
        [self _updateColors];
    }
}

@synthesize regionColor = _regionColor;

- (void)setRegionColor:(NSColor *)aColor
{
    if (_regionColor != aColor) {
        _regionColor = aColor;
        [self _updateColors];
    }
}

@synthesize includedColor = _includedColor;

- (void)setIncludedColor:(NSColor *)aColor
{
    if (_includedColor != aColor) {
        _includedColor = aColor;
        [self _updateColors];
    }
}

@synthesize excludedColor = _excludedColor;

- (void)setExcludedColor:(NSColor *)aColor
{
    if (_excludedColor != aColor) {
        _excludedColor = aColor;
        [self _updateColors];
    }
}

@synthesize mixedColor = _mixedColor;

- (void)setMixedColor:(NSColor *)aColor
{
    if (_mixedColor != aColor) {
        _mixedColor = aColor;
        [self _updateColors];
    }
}

- (void)zoomToTerritoryWithGeoPath:(NSString *)geoPath
{
    [self.canvas zoomToTerritoryWithGeoPath:geoPath];
}

- (void)zoomToTerritory:(AJRTerritoryObject *)territory
{
    [self.canvas zoomToTerritory:territory];
}

@end
