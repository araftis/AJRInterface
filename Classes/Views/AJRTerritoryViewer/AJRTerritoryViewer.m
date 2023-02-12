/*
 AJRTerritoryViewer.m
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

#import "AJRTerritoryViewer.h"

#import "AJRTerritoryCanvas.h"
#import "AJRTerritoryObject.h"
#import "NSColor+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRTerritoryViewer

- (id)initWithFrame:(NSRect)frame {
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

- (IBAction)selectWorld:(id)sender {
}

- (IBAction)selectAMR:(id)sender {
}

- (IBAction)selectAPAC:(id)sender {
}

- (IBAction)selectEMEA:(id)sender {
}

- (IBAction)selectJAPAN:(id)sender {
}

- (IBAction)takeZoomValueFrom:(id)sender {
    [self.canvas takeZoomValueFrom:sender];
}

- (void)setFrameSize:(NSSize)size {
    [super setFrameSize:size];
    [self.canvas recomputeScale];
}

- (AJRTerritoryObject *)addGeoPath:(NSString *)geoPath {
    return [self.canvas addGeoPath:geoPath];
}

- (void)removeGeoPath:(NSString *)geoPath {
    return [self.canvas removeGeoPath:geoPath];
}

- (AJRTerritoryObject *)objectForGeoPath:(NSString *)geoPath {
    return [self.canvas objectForGeoPath:geoPath];
}

- (void)_updateColors {
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

- (void)setActiveRegionColor:(NSColor *)aColor {
    if (_activeRegionColor != aColor) {
        _activeRegionColor = aColor;
        [self _updateColors];
    }
}

@synthesize regionColor = _regionColor;

- (void)setRegionColor:(NSColor *)aColor {
    if (_regionColor != aColor) {
        _regionColor = aColor;
        [self _updateColors];
    }
}

@synthesize includedColor = _includedColor;

- (void)setIncludedColor:(NSColor *)aColor {
    if (_includedColor != aColor) {
        _includedColor = aColor;
        [self _updateColors];
    }
}

@synthesize excludedColor = _excludedColor;

- (void)setExcludedColor:(NSColor *)aColor {
    if (_excludedColor != aColor) {
        _excludedColor = aColor;
        [self _updateColors];
    }
}

@synthesize mixedColor = _mixedColor;

- (void)setMixedColor:(NSColor *)aColor {
    if (_mixedColor != aColor) {
        _mixedColor = aColor;
        [self _updateColors];
    }
}

- (void)zoomToTerritoryWithGeoPath:(NSString *)geoPath {
    [self.canvas zoomToTerritoryWithGeoPath:geoPath];
}

- (void)zoomToTerritory:(AJRTerritoryObject *)territory {
    [self.canvas zoomToTerritory:territory];
}

@end
