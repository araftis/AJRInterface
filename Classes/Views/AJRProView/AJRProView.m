
#import "AJRProView.h"

@implementation AJRProView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [NSGraphicsContext saveGraphicsState];
    
    // Create the shadow below and to the right of the shape.
    NSShadow* theShadow = [[NSShadow alloc] init];
    [theShadow setShadowOffset:NSMakeSize(10.0, -10.0)];
    [theShadow setShadowBlurRadius:3.0];
    
    // Use a partially transparent color for shapes that overlap.
    [theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
    
    [theShadow set];
    
    // Draw your custom content here. Anything you draw
    // automatically has the shadow effect applied to it.

    NSRect bounds = [self bounds];
    
    NSBezierPath* clipShape = [NSBezierPath bezierPath];
    [clipShape appendBezierPathWithRoundedRect:bounds xRadius:20 yRadius:20];
    
    NSColor *top = [NSColor colorWithDeviceRed:190.0 / 255.0 green:190.0 / 255.0 blue:190.0 / 255.0 alpha:1.0];
    NSColor *bottom = [NSColor colorWithDeviceRed:64.0 / 255.0 green:64.0 / 255.0 blue:64.0 / 255.0 alpha:1.0];

    NSGradient* aGradient = [[NSGradient alloc] initWithColorsAndLocations:top, (CGFloat)0.0,
                             bottom, (CGFloat)1.0,
                             nil];
    
    [aGradient drawInBezierPath:clipShape angle:-90.0];
    
    // end shadow
    [NSGraphicsContext restoreGraphicsState];
}

@end
