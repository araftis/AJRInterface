
#import "AJRTerritoryCanvas.h"

#import "AJRTerritoryObject.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRTerritoryCanvas

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _objectIndex = [[NSMutableDictionary alloc] init];
        _objects = [[NSMutableArray alloc] init];
        _center = (NSPoint){0.0, 0.0};
        _currentScaleRect = (NSRect){{-180.0, -90.0}, {360.0, 180.0}};
        _scale = -1.0;
        _maxScale = 15.0;
        _oceanColor = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.0 green:0.494 blue:0.925 alpha:1.0] endingColor:[NSColor colorWithDeviceRed:0.004 green:0.314 blue:0.749 alpha:1.0]];
    }
    return self;
}


- (void)awakeFromNib {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

@synthesize objects = _objects;
@synthesize worldButton = _worldButton;
@synthesize amrButton = _amrButton;
@synthesize apacButton = _apacButton;
@synthesize emeaButton = _emeaButton;
@synthesize japanButton = _japanButton;
@synthesize zoomSlider = _zoomSlider;
@synthesize minScale = _minScale;
@synthesize maxScale = _maxScale;

- (CGFloat)scale {
    return _scale;
}

- (void)setScale:(CGFloat)scale {
    if (scale < _minScale) {
        _scale = _minScale;
    } else if (scale > _maxScale) {
        _scale = _maxScale;
    } else {
        _scale = scale;
    }
    [self.zoomSlider setDoubleValue:_scale];
    [self setNeedsDisplay:YES];
}

- (void)setScaleForRect:(NSRect)rect {
    CGFloat xScale, yScale;
    NSRect bounds = [self bounds];
    
    xScale = bounds.size.width / rect.size.width;
    yScale = bounds.size.height / rect.size.height;
    if (xScale < yScale) {
        [self setScale:xScale];
    } else {
        [self setScale:yScale];
    }
    _currentScaleRect = rect;
}

- (void)recomputeScale {
    [self setScaleForRect:_currentScaleRect];
    if (_currentScaleRect.size.width == 360.0 && _currentScaleRect.size.height == 180.0) {
        _minScale = _scale;
        [self.zoomSlider setMinValue:_minScale];
    }
}

@synthesize oceanColor = _oceanColor;

- (void)setOceanColor:(NSGradient *)oceanColor {
    if (oceanColor != _oceanColor) {
        _oceanColor = oceanColor;
        [self setNeedsDisplay:YES];
    }
}

- (AJRTerritoryObject *)addGeoPath:(NSString *)geoPath {
    AJRTerritoryObject *object = [[AJRTerritoryObject alloc] initWithGeoPath:geoPath];
    
    if (object) {
        [_objectIndex setObject:object forKey:geoPath];
        [_objects addObject:object];
        [self setNeedsDisplay:YES];
    } else {
        AJRPrintf(@"WARNING: Unable to find path for geoPath: %@", geoPath);
    }
    
    return object;
}

- (void)removeGeoPath:(NSString *)geoPath {
    AJRTerritoryObject *object = [_objectIndex objectForKey:geoPath];
    
    if (object) {
        [_objects removeObject:object];
        [_objectIndex removeObjectForKey:geoPath];
        [self setNeedsDisplay:YES];
    }
}

- (AJRTerritoryObject *)objectForGeoPath:(NSString *)geoPath {
    return [_objectIndex objectForKey:geoPath];
}

- (void)drawRect:(NSRect)rect {
    NSAffineTransform *transform = [[NSAffineTransform alloc] init];
    NSRect bounds = [self bounds];
    
    [[NSColor darkGrayColor] set];
    NSFrameRect(bounds);
    
    bounds = NSInsetRect(bounds, 1.0, 1.0);
    NSRectClip(bounds);
    
    if (_scale < 0.0) {
        _scale = 1.0;
        [self recomputeScale];
    }
    
    [self.oceanColor drawInRect:bounds angle:45.0];
    
    [transform scaleXBy:_scale yBy:_scale];
    [transform translateXBy:(bounds.size.width / _scale) / 2.0 - _center.x yBy:(bounds.size.height / _scale) / 2.0 - _center.y];
    [transform concat];

    for (AJRTerritoryObject *object in _objects) {
        [object drawInView:self];
    }
}

- (IBAction)selectWorld:(id)sender {
    _center = (NSPoint){0.0, 0.0};
    _currentScaleRect = (NSRect){{-180.0, -90.0}, {360.0, 180.0}};
    [self setScaleForRect:_currentScaleRect];
}

- (IBAction)selectAMR:(id)sender {
    AJRTerritoryObject *object = [self objectForGeoPath:@"ww.amr"];
    NSRect bounds = [object bounds];
    
    bounds.size.width *= (1.0 / 3.0);
    bounds.origin.y += bounds.size.height * 0.45;
    bounds.size.height *= 0.55;
    
    _center = (NSPoint){bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0};
    [self setScaleForRect:bounds];
}

- (IBAction)selectAPAC:(id)sender {
    AJRTerritoryObject *object = [self objectForGeoPath:@"ww.apac"];
    NSRect bounds = [object bounds];
    
    bounds.origin.x += bounds.size.width * 0.5;
    bounds.size.width *= 0.5;
    bounds.origin.y += bounds.size.height * 0.10;
    bounds.size.height *= 0.90;
    
    _center = (NSPoint){bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0};
    [self setScaleForRect:bounds];
}

- (IBAction)selectEMEA:(id)sender {
    AJRTerritoryObject *object = [self objectForGeoPath:@"ww.emea"];
    NSRect bounds = [object bounds];
    
    bounds.origin.y += bounds.size.height * 0.60;
    bounds.size.height *= 0.30;
    
    _center = (NSPoint){bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0};
    [self setScaleForRect:bounds];
}

- (IBAction)selectJAPAN:(id)sender {
    AJRTerritoryObject *object = [self objectForGeoPath:@"ww.japan"];
    NSRect bounds = [object bounds];
    
    _center = (NSPoint){bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0};
    [self setScaleForRect:bounds];
}

- (IBAction)takeZoomValueFrom:(id)sender {
    [self setScale:[sender floatValue]];
}

- (void)mouseDown:(NSEvent *)event {
    _dragOrigin = [self convertPoint:[event locationInWindow] fromView:nil];
    _dragPrevious = _dragOrigin;
    //AJRPrintf(@"%C: mouseDown: %P\n", self, _dragOrigin);
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSPoint delta = (NSPoint){point.x - _dragPrevious.x, point.y - _dragPrevious.y};
        
    //AJRPrintf(@"%C: mouseDown: %P\n", self, delta);
    
    _center.x -= delta.x / _scale;
    _center.y -= delta.y / _scale;
    [self setNeedsDisplay:YES];
    
    _dragPrevious = point;
}

- (void)scrollWheel:(NSEvent *)event {
    //AJRPrintf(@"%C: scrollWheel: %@\n", self, event);
    [self setScale:_scale + [event deltaY] / 4.0];
}

- (void)mouseMoved:(NSEvent *)event {
    AJRPrintf(@"%C: mouseMoved: %@\n", self, event);
}

- (void)zoomToTerritoryWithGeoPath:(NSString *)geoPath {
    return [self zoomToTerritory:[self objectForGeoPath:geoPath]];
}

- (void)zoomToTerritory:(AJRTerritoryObject *)territory {
    if (territory) {
        NSRect bounds = [territory bounds];
        
        _center.x = bounds.origin.x + bounds.size.width / 2.0;
        _center.y = bounds.origin.y + bounds.size.height / 2.0;
        
        [self setScaleForRect:bounds];
    }
}
         
@end
