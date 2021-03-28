
#import "AJRRibbonView.h"

#import "AJRGradientColor.h"
#import "AJRRibbonViewItem.h"
#import "AJRSeparatorBorder.h"

static AJRGradientColor *_separatorGradientDark;
static AJRGradientColor *_separatorGradientLight;
static AJRGradientColor *_separatorGradientDarkInactive;
static AJRGradientColor *_separatorGradientLightInactive;

@interface AJRRibbonView ()

- (void)layoutSubviews;

@end


@implementation AJRRibbonView

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _separatorGradientDark = [AJRGradientColor gradientColorWithGradient:[[NSGradient alloc] initWithColorsAndLocations:
                                                                             [NSColor colorWithCalibratedWhite:0.33 alpha:0.0], 0.1,
                                                                             [NSColor colorWithCalibratedWhite:0.33 alpha:0.9], 0.45,
                                                                             [NSColor colorWithCalibratedWhite:0.33 alpha:0.9], 0.55,
                                                                             [NSColor colorWithCalibratedWhite:0.33 alpha:0.0], 0.9,
                                                                             nil]
                                                                      angle:90.0];
        _separatorGradientLight = [AJRGradientColor gradientColorWithGradient:[[NSGradient alloc] initWithColorsAndLocations:
                                                                              [NSColor colorWithCalibratedWhite:1.0 alpha:0.0], 0.1,
                                                                              [NSColor colorWithCalibratedWhite:1.0 alpha:0.9], 0.45,
                                                                              [NSColor colorWithCalibratedWhite:1.0 alpha:0.9], 0.55,
                                                                              [NSColor colorWithCalibratedWhite:1.0 alpha:0.0], 0.9,
                                                                              nil]
                                                                       angle:90.0];
        _separatorGradientDarkInactive = [AJRGradientColor gradientColorWithGradient:[[NSGradient alloc] initWithColorsAndLocations:
                                                                                     [NSColor colorWithCalibratedWhite:0.66 alpha:0.0], 0.1,
                                                                                     [NSColor colorWithCalibratedWhite:0.66 alpha:0.9], 0.45,
                                                                                     [NSColor colorWithCalibratedWhite:0.66 alpha:0.9], 0.55,
                                                                                     [NSColor colorWithCalibratedWhite:0.66 alpha:0.0], 0.9,
                                                                                     nil]
                                                                              angle:90.0];
        _separatorGradientLightInactive = [AJRGradientColor gradientColorWithGradient:[[NSGradient alloc] initWithColorsAndLocations:
                                                                                      [NSColor colorWithCalibratedWhite:1.0 alpha:0.0], 0.1,
                                                                                      [NSColor colorWithCalibratedWhite:1.0 alpha:0.9], 0.45,
                                                                                      [NSColor colorWithCalibratedWhite:1.0 alpha:0.9], 0.55,
                                                                                      [NSColor colorWithCalibratedWhite:1.0 alpha:0.0], 0.9,
                                                                                      nil]
                                                                               angle:90.0];
    });
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _border = [[AJRSeparatorBorder alloc] init];
        [_border setBottomColor:[AJRGradientColor gradientColorWithColor:[NSColor colorWithDeviceWhite:0.40 alpha:1.0]]];
        [_border setBackgroundColor:[AJRGradientColor gradientColorWithGradient:[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.7 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.55 alpha:1.0], 1.0, nil] angle:270.0]];
        [_border setTopColor:[AJRGradientColor gradientColorWithColor:[NSColor colorWithDeviceWhite:0.80 alpha:1.0]]];

        [_border setInactiveBottomColor:[AJRGradientColor gradientColorWithColor:[NSColor colorWithDeviceWhite:0.50 alpha:1.0]]];
        [_border setInactiveBackgroundColor:[AJRGradientColor gradientColorWithColor:[NSColor colorWithDeviceWhite:0.88 alpha:1.0]]];
        [_border setInactiveTopColor:[AJRGradientColor gradientColorWithColor:[NSColor colorWithDeviceWhite:0.91 alpha:1.0]]];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    return self;
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (void)setBorder:(AJRSeparatorBorder *)border {
    if (_border != border) {
        _border = border;
        [self setNeedsLayout:YES];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers != viewControllers) {
        NSMutableArray *newSubviews = [NSMutableArray array];
        
        _viewControllers = [viewControllers copy];
        for (NSViewController *viewController in _viewControllers) {
            AJRRibbonViewItem *item = [[AJRRibbonViewItem alloc] initWithContentView:[viewController view]];
            [newSubviews addObject:item];
        }
        [self setSubviews:newSubviews];
        [self setNeedsLayout:YES];
        [self layoutSubviews];
    }
}

#pragma mark - Utilities

- (void)layoutSubviews {
    NSRect bounds = [_border contentRectForRect:[self bounds]];
    NSRect newSubviewFrame;
    NSArray *subviews = [self subviews];
    
    newSubviewFrame = bounds;
    for (NSInteger x = 0, max = [subviews count]; x < max; x++) {
        AJRRibbonViewItem *view = [subviews objectAtIndex:x];
        NSRect subviewFrame = [view frame];
        
        newSubviewFrame.size.width = subviewFrame.size.width;
        [view setFrame:newSubviewFrame];
        newSubviewFrame.origin.x += newSubviewFrame.size.width;
        if (x != max - 1) {
            [[view border] setRightColor:_separatorGradientDark];
            [[view border] setInactiveRightColor:_separatorGradientDarkInactive];
        } else {
            [[view border] setRightColor:nil];
            [[view border] setInactiveRightColor:nil];
        }
        if (x != 0) {
            [[view border] setLeftColor:_separatorGradientLight];
            [[view border] setInactiveLeftColor:_separatorGradientLightInactive];
        } else {
            [[view border] setLeftColor:nil];
            [[view border] setInactiveLeftColor:nil];
        }
    }
}

#pragma mark - NSView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)layout {
    [super layout];
    [self layoutSubviews];
}

- (void)drawRect:(NSRect)dirtyRect {
    [_border drawBorderInRect:[self bounds] controlView:self];
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDisplay:) name:NSWindowDidBecomeKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDisplay:) name:NSWindowDidResignKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDisplay:) name:NSApplicationDidResignActiveNotification object:NSApp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDisplay:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

- (void)updateDisplay:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

@end
