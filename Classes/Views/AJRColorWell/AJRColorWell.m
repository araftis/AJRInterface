
#import "AJRColorWell.h"

#import "AJRColorSwatchView.h"

#import <AJRFoundation/NSObject+Extensions.h>
#import <AJRInterface/AJRInterface.h>

void AJRDrawColorSwatch(NSColor *color, BOOL isMultipleValues, NSRect rect) {
    if (!color && isMultipleValues) {
        // TODO: Do something nice here.
    } else if (color == nil) {
        [[NSColor whiteColor] setFill];
        [[NSColor redColor] setStroke];
        NSRectFill(rect);
        [NSBezierPath strokeLineFromPoint:rect.origin toPoint:(NSPoint){NSMaxX(rect), NSMaxY(rect)}];
    } else {
        // If a color has transparency, draw the usual decorations
        if ([color alphaComponent] < 1.0) {
            NSBezierPath *blackTriangle = [NSBezierPath bezierPath];
            [blackTriangle moveToPoint:rect.origin];
            [blackTriangle lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
            [blackTriangle lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
            [[NSColor blackColor] setFill];
            [blackTriangle fill];
            NSBezierPath *whiteTriangle = [NSBezierPath bezierPath];
            [whiteTriangle moveToPoint:rect.origin];
            [whiteTriangle lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
            [whiteTriangle lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
            [[NSColor whiteColor] setFill];
            [whiteTriangle fill];
        }
        [color set];
        [NSBezierPath fillRect:rect];
    }
}

NSImage *AJRColorSwatchImage(NSColor *color, BOOL isMultipleValues, NSSize colorImageSize) {
    return [NSImage ajr_imageWithSize:colorImageSize scales:@[@(1), @(2)] flipped:NO colorSpace:nil commands:^(CGFloat scale) {
        AJRDrawColorSwatch(color, isMultipleValues, (NSRect){NSZeroPoint, colorImageSize});
    }];
}

NSMenu *AJRColorSwatchMenu(id colorTarget, SEL colorAction, id showColorsTarget, SEL showColorsAction){
    NSMenuItem *colorsItem;
    NSMenuItem *swatchItem;
    NSImage *image;
    AJRColorSwatchView *swatchView;
    NSMenu *menu;
    
    menu = [[NSMenu alloc] initWithTitle:@"Colors"];
    
    image = [[NSImage imageNamed:NSImageNameColorPanel] copy];
    [image setSize:(NSSize){14, 14}];
    
    swatchItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    swatchView = [[AJRColorSwatchView alloc] initWithWidth:12 andHeight:10];
    [swatchView setTarget:colorTarget];
    [swatchView setAction:colorAction];
    [swatchItem setView:swatchView];
    
    colorsItem = [menu addItemWithTitle:[[showColorsTarget translator] valueForKey:@"Show Colors"] action:showColorsAction keyEquivalent:@""];
    [colorsItem setState:NSControlStateValueOn];
    [colorsItem setOnStateImage:image];
    [colorsItem setTarget:showColorsTarget];
    [colorsItem setAttributedTitle:[[NSAttributedString alloc] initWithString:[[showColorsTarget translator] valueForKey:@"Show Colors"] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName, nil]]];
    
    return menu;
}

@interface AJRColorWell ()

@end

@implementation AJRColorWell {
    NSMenu *_menu;
}

+ (NSGradient *)backgroundGradient {
    static NSGradient *backgroundGradient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                              [NSColor colorWithCalibratedWhite:0.96 alpha:1.0], 0.0, 
                              [NSColor colorWithCalibratedWhite:0.72 alpha:1.0], 1.0,
                              nil];
    });
    return backgroundGradient;
}

+ (NSGradient *)multipleColorGradient {
    static NSGradient    *multipleColorGradient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        multipleColorGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                 [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0], 0.0, 
                                 [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:1.0], 0.2, 
                                 [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0], 0.4, 
                                 [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:1.0 alpha:1.0], 0.6, 
                                 [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0], 0.8, 
                                 [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:1.0 alpha:1.0], 1.0, 
                                 nil];
    });
    return multipleColorGradient;
}

#pragma mark - Properties

- (void)setDisplayMode:(AJRColorWellDisplay)displayMode {
    if (_displayMode != displayMode) {
        _displayMode = displayMode;
        [self setNeedsDisplay:YES];
    }
}

- (NSMenu *)menu {
    if (_menu == nil) {
        _menu = AJRColorSwatchMenu(self, @selector(selectColor:), self, @selector(showColors:));
    }
    return _menu;
}

#pragma mark - NSResponder

- (void)mouseDown:(NSEvent *)event {
    if (self.isEnabled) {
        NSMenu *menu = [self menu];
        [menu popUpMenuPositioningItem:[[menu itemArray] objectAtIndex:0] atLocation:NSZeroPoint inView:self];
    }
}

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    NSGradient *backgroundGradient = [[self class] backgroundGradient];
    CGFloat adjust = 1.0, inset = 0.5;
    
    if (self.window.screen.backingScaleFactor != 0.0) {
        adjust = 1.0 / self.window.screen.backingScaleFactor;
        if (adjust == 1.0) {
            inset = 0.5;
        } else {
            inset = 1.0 - (adjust / self.window.screen.backingScaleFactor);
        }
    }
    
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(bounds, inset, inset)];
    path.lineWidth = adjust;
    [path stroke];
    
    [backgroundGradient drawInRect:NSInsetRect(bounds, 1.0, 1.0) angle:270.0];
    
    bounds = NSInsetRect(bounds, 2.0, 2.0);
    switch (_displayMode) {
        case AJRColorWellDisplayNone:
            [[NSColor whiteColor] set];
            NSRectFill(bounds);
            [[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
            NSFrameRect(bounds);
            bounds = NSInsetRect(bounds, 1.0, 1.0);
            [[NSColor redColor] set];
            [NSBezierPath strokeLineFromPoint:(NSPoint){NSMinX(bounds), NSMinY(bounds)} toPoint:(NSPoint){NSMaxX(bounds), NSMaxY(bounds)}];
            break;
        case AJRColorWellDisplayColor:
            [[self color] drawSwatchInRect:bounds];
            [[[self color] colorByMultiplyingBrightness:0.8] set];
            NSFrameRect(bounds);
            break;
        case AJRColorWellDisplayMultiple: {
            NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
            [[[self class] multipleColorGradient] drawInRect:bounds angle:0.0];
            [image lockFocus];
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
            NSFrameRect((NSRect){NSZeroPoint, bounds.size});
            [image unlockFocus];
            [image ajr_drawAtPoint:bounds.origin operation:NSCompositingOperationSourceOver];
            break;
        }
    }
}

#pragma mark - Actions

- (IBAction)showColors:(id)sender {
    [[NSColorPanel sharedColorPanel] orderFront:self];
}

- (IBAction)selectColor:(AJRColorSwatchView *)sender {
    if ([sender selectedColor]) {
        [self setColor:[sender selectedColor]];
        [self setDisplayMode:AJRColorWellDisplayColor];
    } else {
        [self setDisplayMode:AJRColorWellDisplayNone];
    }
    [_menu cancelTracking];
    [NSApp sendAction:[self action] to:[self target] from:self];
}

@end
