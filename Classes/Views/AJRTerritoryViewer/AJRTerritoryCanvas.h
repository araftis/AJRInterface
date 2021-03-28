
#import <Cocoa/Cocoa.h>

@class AJRTerritoryObject;

@interface AJRTerritoryCanvas : NSView {
    IBOutlet NSButton *_worldButton;
    IBOutlet NSButton *_amrButton;
    IBOutlet NSButton *_apacButton;
    IBOutlet NSButton *_emeaButton;
    IBOutlet NSButton *_japanButton;
    IBOutlet NSSlider *_zoomSlider;

    NSMutableDictionary *_objectIndex;
    NSMutableArray *_objects;
    CGFloat _scale;
    NSRect _currentScaleRect;
    CGFloat _minScale;
    CGFloat _maxScale;
    NSPoint _center;
    NSGradient *_oceanColor;
    
    // Dragging
    NSPoint _dragOrigin;
    NSPoint _dragPrevious;
}

@property (readonly) NSArray *objects;
@property (nonatomic,strong) NSButton *worldButton;
@property (nonatomic,strong) NSButton *amrButton;
@property (nonatomic,strong) NSButton *apacButton;
@property (nonatomic,strong) NSButton *emeaButton;
@property (nonatomic,strong) NSButton *japanButton;
@property (nonatomic,strong) NSSlider *zoomSlider;
@property (assign) CGFloat scale;
@property (readonly) CGFloat minScale;
@property (assign) CGFloat maxScale;
@property (nonatomic,strong) NSGradient *oceanColor;

- (void)setScaleForRect:(NSRect)rect;
- (void)recomputeScale;

- (AJRTerritoryObject *)addGeoPath:(NSString *)geoPath;
- (void)removeGeoPath:(NSString *)geoPath;
- (AJRTerritoryObject *)objectForGeoPath:(NSString *)geoPath;

- (IBAction)selectWorld:(id)sender;
- (IBAction)selectAMR:(id)sender;
- (IBAction)selectAPAC:(id)sender;
- (IBAction)selectEMEA:(id)sender;
- (IBAction)selectJAPAN:(id)sender;
- (IBAction)takeZoomValueFrom:(id)sender;

- (void)zoomToTerritoryWithGeoPath:(NSString *)geoPath;
- (void)zoomToTerritory:(AJRTerritoryObject *)territory;

@end
