
#import "AJRCIEColor.h"

NSString * const AJRCIEXYZColorSpace = @"AJRCIEXYZColorSpace";

@implementation NSColor (AJRCIEColor)

+ (NSColor *)colorWithCIEX:(CGFloat)xIn y:(CGFloat)yIn z:(CGFloat)zIn alpha:(CGFloat)alphaIn
{
    return [AJRCIEColor colorWithCIEX:xIn y:yIn z:zIn alpha:alphaIn];
}

@end

static CGColorSpaceRef _xyzColorSpace;
static NSColorSpace *_xyzNSColorSpace;
static CGColorSpaceRef _cmykColorSpace;
static CGColorSpaceRef _sRGBColorSpace;
static CGColorSpaceRef _whiteColorSpace;

@implementation AJRCIEColor
{
    CGFloat _x, _y, _z;
    CGFloat _alpha;
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xyzColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericXYZ);
		_xyzNSColorSpace = [[NSColorSpace alloc] initWithCGColorSpace:_xyzColorSpace];
        _cmykColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericCMYK);
        _sRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceExtendedSRGB);
        _whiteColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceExtendedLinearGray);
    });
}

+ (NSColor *)colorWithCIEX:(CGFloat)xIn y:(CGFloat)yIn z:(CGFloat)zIn alpha:(CGFloat)alphaIn {
    return [[self alloc] initWithCIEX:xIn y:yIn z:zIn alpha:alphaIn];
}

- (id)initWithCIEX:(CGFloat)xIn y:(CGFloat)yIn z:(CGFloat)zIn alpha:(CGFloat)alphaIn {
    if ((self = [super init])) {
        _x = xIn;
        _y = yIn;
        _z = zIn;
        _alpha = alphaIn;
    }
    return self;
}

- (CGColorRef)CGColor {
    CGFloat components[] = { _x, _y, _z, _alpha };
    return (CGColorRef)CFAutorelease(CGColorCreate(_xyzColorSpace, components));
}

- (CGFloat)alphaComponent {
    return _alpha;
}

- (CGFloat)blackComponent {
    CGFloat component;
    [self getCyan:NULL magenta:NULL yellow:NULL black:&component alpha:NULL];
    return component;
}

- (CGFloat)blueComponent {
    CGFloat component;
    [self getRed:NULL green:NULL blue:&component alpha:NULL];
    return component;
}

- (CGFloat)brightnessComponent {
    CGFloat component;
    [self getHue:NULL saturation:NULL brightness:&component alpha:NULL];
    return component;
}

- (NSString *)catalogNameComponent {
    return nil;
}

- (NSString *)colorNameComponent {
    return nil;
}

- (NSColorSpace *)colorSpace {
	return _xyzNSColorSpace;
}

- (NSColor *)colorUsingColorSpace:(NSColorSpace *)colorSpace {
    if ([colorSpace colorSpaceModel] == NSColorSpaceModelCMYK) {
        CGFloat components[5];
        [self getCyan:&components[0] magenta:&components[1] yellow:&components[2] black:&components[3] alpha:&components[4]];
		return [NSColor colorWithColorSpace:colorSpace components:components count:5];
    } else if ([colorSpace colorSpaceModel] == NSColorSpaceModelGray) {
        CGFloat white, alpha2;
        [self getWhite:&white alpha:&alpha2];
        return [NSColor colorWithDeviceWhite:white alpha:alpha2];
    } else if ([colorSpace colorSpaceModel] == NSColorSpaceModelRGB) {
        CGFloat red, green, blue, alpha2;
        [self getRed:&red green:&green blue:&blue alpha:&alpha2];
        return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha2];
    }
    
    return nil;
}

- (NSColor *)colorWithAlphaComponent:(CGFloat)alphaIn {
    return [[[self class] alloc] initWithCIEX:_x y:_y z:_z alpha:alphaIn];
}

- (CGFloat)cyanComponent {
    CGFloat component;
    [self getCyan:&component magenta:NULL yellow:NULL black:NULL alpha:NULL];
    return component;
}

- (void)drawSwatchInRect:(NSRect)rect {
    [self set];
    NSRectFill(rect);
}

- (void)getCyan:(CGFloat *)cyan magenta:(CGFloat *)magenta yellow:(CGFloat *)yellow black:(CGFloat *)black alpha:(CGFloat *)alphaIn {
    CGColorRef color = CGColorCreateCopyByMatchingToColorSpace(_cmykColorSpace, kCGRenderingIntentDefault, [self CGColor], NULL);
    if (color) {
        const CGFloat *components = CGColorGetComponents(color);
    
        if (cyan) *cyan = components[0];
        if (magenta) *magenta = components[1];
        if (yellow) *yellow = components[2];;
        if (black) *black = components[3];
        if (alphaIn) *alphaIn = _alpha;
    }
}

- (void)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alphaIn {
    CGColorRef color = CGColorCreateCopyByMatchingToColorSpace(_sRGBColorSpace, kCGRenderingIntentDefault, [self CGColor], NULL);
    if (color) {
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat h, s, b;
        
        AJRRGBToHSB(components[0], components[1], components[2], &h, &s, &b);
        if (hue) *hue = h;
        if (saturation) *saturation = s;
        if (brightness) *brightness = b;
        if (alphaIn) *alphaIn = _alpha;
    }
}

- (void)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alphaIn {
    CGColorRef color = CGColorCreateCopyByMatchingToColorSpace(_sRGBColorSpace, kCGRenderingIntentDefault, [self CGColor], NULL);
    if (color) {
        const CGFloat *components = CGColorGetComponents(color);

        if (red) *red = components[0];
        if (green) *green = components[1];
        if (blue) *blue = components[2];
        if (alphaIn) *alphaIn = _alpha;
    }
}

- (void)getWhite:(CGFloat *)white alpha:(CGFloat *)alphaIn {
    CGColorRef color = CGColorCreateCopyByMatchingToColorSpace(_whiteColorSpace, kCGRenderingIntentDefault, [self CGColor], NULL);
    if (color) {
        const CGFloat *components = CGColorGetComponents(color);
        
        if (white) *white = components[0];
        if (alphaIn) *alphaIn = _alpha;
    }
}

- (CGFloat)greenComponent {
    CGFloat component;
    [self getRed:NULL green:&component blue:NULL alpha:NULL];
    return component;
}
/* Hopefully handled by superclass.
 - (NSColor *)highlightWithLevel:(CGFloat)highlightLevel
 */
- (CGFloat)hueComponent {
    CGFloat component;
    [self getHue:&component saturation:NULL brightness:NULL alpha:NULL];
    return component;
}

- (NSString *)localizedCatalogNameComponent {
    return nil;
}

- (NSString *)localizedColorNameComponent {
    return nil;
}

- (CGFloat)magentaComponent {
    CGFloat component;
    [self getCyan:NULL magenta:&component yellow:NULL black:NULL alpha:NULL];
    return component;
}

- (NSImage *)patternImage {
    return nil;
}

- (CGFloat)redComponent {
    CGFloat component;
    [self getRed:&component green:NULL blue:NULL alpha:NULL];
    return component;
}

- (CGFloat)saturationComponent {
    CGFloat component;
    [self getHue:NULL saturation:&component brightness:NULL alpha:NULL];
    return component;
}

- (void)set {
    CGFloat r, g, b, a;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    CGContextSetRGBFillColor(context, r, g, b, a);
    CGContextSetRGBStrokeColor(context, r, g, b, a);
}

- (CGFloat)whiteComponent {
    CGFloat component;
    [self getWhite:&component alpha:NULL];
    return component;
}

- (void)writeToPasteboard:(NSPasteboard *)pasteBoard {
}

- (CGFloat)yellowComponent {
    CGFloat component;
    [self getCyan:NULL magenta:NULL yellow:&component black:NULL alpha:NULL];
    return component;
}

@end

void AJRRGBToHSB(CGFloat red, CGFloat green, CGFloat blue, CGFloat *hue, CGFloat *saturation, CGFloat *brightness) {
    CGFloat minRGB = MIN(red, MIN(green, blue));
    CGFloat maxRGB = MAX(red, MAX(green, blue));
    
    if (minRGB == maxRGB) {
        *hue = 0;
        *saturation = 0;
        *brightness = minRGB;
    } else {
        CGFloat d = (red == minRGB) ? green - blue : ((blue == minRGB) ? red - green : blue - red);
        CGFloat h = (red == minRGB) ? 3 : ((blue == minRGB) ? 1 : 5);
        *hue = (h - d / (maxRGB - minRGB)) / 6.0;
        *saturation = (maxRGB - minRGB) / maxRGB;
        *brightness = maxRGB;
    }
}
