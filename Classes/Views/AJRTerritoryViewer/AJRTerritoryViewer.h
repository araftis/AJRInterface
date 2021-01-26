//
//  AJRTerritoryViewer.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/13/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRTerritoryCanvas, AJRTerritoryObject;

@interface AJRTerritoryViewer : NSView
{
    IBOutlet AJRTerritoryCanvas    *_canvas;

    // Colors
    NSColor                *_activeRegionColor;
    NSColor                *_regionColor;
    NSColor                *_includedColor;
    NSColor                *_excludedColor;
    NSColor                *_mixedColor;
}

- (id)initWithFrame:(NSRect)frame;

@property (nonatomic,strong) AJRTerritoryCanvas *canvas;
@property (nonatomic,strong) NSColor *activeRegionColor;
@property (nonatomic,strong) NSColor *regionColor;
@property (nonatomic,strong) NSColor *includedColor;
@property (nonatomic,strong) NSColor *excludedColor;
@property (nonatomic,strong) NSColor *mixedColor;

- (IBAction)selectWorld:(id)sender;
- (IBAction)selectAMR:(id)sender;
- (IBAction)selectAPAC:(id)sender;
- (IBAction)selectEMEA:(id)sender;
- (IBAction)selectJAPAN:(id)sender;
- (IBAction)takeZoomValueFrom:(id)sender;

- (AJRTerritoryObject *)addGeoPath:(NSString *)geoPath;
- (void)removeGeoPath:(NSString *)geoPath;
- (AJRTerritoryObject *)objectForGeoPath:(NSString *)geoPath;

- (void)zoomToTerritoryWithGeoPath:(NSString *)geoPath;
- (void)zoomToTerritory:(AJRTerritoryObject *)territory;

@end
