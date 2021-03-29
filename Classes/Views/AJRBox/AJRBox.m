/*
AJRBox.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#import "AJRBox.h"

#import "AJRBorder.h"
#import "AJRFill.h"
#import "AJRFlippedView.h"
#import "AJRLineBorder.h"
#import "AJRSolidFill.h"
#import "AJRGradientFill.h"
#import "AJRInterfaceFunctions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <QuartzCore/QuartzCore.h>

#define AJRSetColor(r,g,b) [[NSColor colorWithCalibratedRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0] set]

@interface NSView (ApplePrivate)

- (void)_recursiveDisplayAllDirtyWithLockFocus:(BOOL)focus visRect:(NSRect)rect;
- (void)_drawRect:(NSRect)rect clip:(BOOL)clip;
- (id)_focusInto:(id)into withClip:(BOOL)clip;
- (void)_setSuperview:(NSView *)aView;

@end


@interface AJRBox (Private)

- (NSView *)_backgroundView;
- (NSView *)_foregroundView;
- (void)_addSubview:(NSView *)aSubview;

@end


@interface AJRBoxSubview : NSView
{
    BOOL isBackground:1;
    BOOL isHitTesting:1;
}

- (void)setIsBackground:(BOOL)flag;
- (BOOL)isBackground;

@end


@implementation AJRBoxSubview

- (BOOL)isOpaque {
    return NO;
}

- (void)setIsBackground:(BOOL)flag {
    isBackground = flag;
}

- (BOOL)isBackground {
    return isBackground;
}

- (void)drawRect:(NSRect)rect {
    AJRBox *box = (AJRBox *)[self superview];
    AJRBorder *border = [box border];
    
    if (isBackground) {
        NSRect bounds = [self bounds];
        AJRFill *fill = [(AJRBox *)[self superview] contentFill];
        
        [border drawBorderBackgroundInRect:bounds clippedToRect:rect controlView:self];
        [NSGraphicsContext saveGraphicsState];
        [[border clippingPathForRect:bounds] addClip];
        [fill fillRect:bounds controlView:self];
        [NSGraphicsContext restoreGraphicsState];
    } else {
        NSRect        titleRect;
        
        [border drawBorderForegroundInRect:[self bounds] clippedToRect:rect controlView:self];
        [[NSColor redColor] set];
//        NSFrameRect([self bounds]);
        
        if (border == nil) {
            titleRect = [box titleRect];
            if (titleRect.size.width != 0.0 && titleRect.size.height != 0.0) {
                NSFrameRect(titleRect);
                [[box titleCell] drawInteriorWithFrame:[box titleRect] inView:self];
            }
        }
    }
}

- (NSView *)hitTest:(NSPoint)aPoint {
//    NSView        *result = [super hitTest:aPoint];
//    
//    AJRPrintf(@"%C: %@ %S%P\n", self, result, _cmd, aPoint);
//    
    return nil; //result == self ? [self superview] : result;
}

@end


@implementation AJRBox {
	AJRLabelCell *_titleCell;
}

+ (void)initialize {
    [self setVersion:7];
}

- (BOOL)isOpaque {
    BOOL isOpaque = YES;
    
    if (boxFlags.appIsIB) {
        // IB doesn't deal with this flag getting flipped at run time, so we'll always return NO
        // to IB.
        return NO;
    }
    
    // We're opaque if our content fill and border report themselves as being opaque.
    if (contentFill) {
        isOpaque = [contentFill isOpaque];
    }
    if (border) {
        isOpaque = isOpaque & [border isOpaque];
    }
    
    return isOpaque;
}

- (void)setupSubviews {
    NSMutableArray *subviews = [[self subviews] mutableCopy];
    AJRBoxSubview *view;
    
    if ([(NSArray *)[self subviews] count] > 1) {
        [[subviews objectAtIndex:0] setIsBackground:YES];
        return;
    }
    
    view = [[AJRBoxSubview alloc] initWithFrame:[self bounds]];
    [view setIsBackground:YES];
    [subviews insertObject:view atIndex:0];
    [view _setSuperview:self];
    [subviews removeLastObject];
    view = [[AJRBoxSubview alloc] initWithFrame:[self bounds]];
    [subviews addObject:view];
    [view _setSuperview:self];
    [subviews removeLastObject];
    
    [self setSubviews:subviews];
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    [self setBorder:[AJRBorder borderForName:@"Line"]];
    
    // Create out content fill.
    contentFill = [AJRFill fillForName:@"Solid Fill"];
    [(AJRSolidFill *)contentFill setColor:[NSColor whiteColor]];
    boxFlags.titleAlignment = NSTextAlignmentCenter;
    boxFlags.appIsIB = [[[NSProcessInfo processInfo] processName] isEqualToString:@"Interface Builder"];
    [self setAutoresize:YES];
    
    _titleCell = [(AJRLabelCell *)[AJRLabelCell alloc] initTextCell:@"Box"];
    [(AJRLabelCell *)[self titleCell] setAlignment:NSTextAlignmentCenter];
    
    boxFlags.contentPosition = AJRContentScaledMask | AJRContentScaledPorportional;
    
    [self setTitlePosition:NSBelowTop];
    [self setTitleFont:[NSFont boldSystemFontOfSize:12.0]];
    [self setupSubviews];
    [self tile];
    
    return self;
}

- (void)setTitlePosition:(NSTitlePosition)titlePosition {
    [super setTitlePosition:titlePosition];
    [[self border] setTitlePosition:titlePosition];
    [self tile];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-  (AJRLabelCell *)titleCell {
	return _titleCell;
}

- (void)setTitleCell:(AJRLabelCell *)titleCell {
	_titleCell = titleCell;
	[self setNeedsDisplay:YES];
}

- (void)setFont:(NSFont *)font {
    [[self titleCell] setFont:font];
    [[[self border] titleCell] setFont:font];
    [self setNeedsDisplay:YES];
}

- (NSFont *)font {
    return [[self titleCell] font];
}

- (void)setFrame:(NSRect)frameRect {
    if (!boxFlags.ibResizeHack/* && boxFlags.drawnOnce*/) {
        [[self contentView] setAutoresizesSubviews:[self autoresizesSubviews]];
    } else {
        [[self contentView] setAutoresizesSubviews:NO];
    }
    [super setFrame:frameRect];
    [self tile];
}

- (void)setContentViewMargins:(NSSize)size {
    [super setContentViewMargins:size];
    [self tile];
}

- (CAAnimationGroup *)_flipAnimationWithDuration:(CGFloat)duration isFront:(BOOL)isFront {
    // Rotating halfway (pi radians) around the Y axis gives the appearance of flipping
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    
    // The hidden view rotates from negative to make it look like it's in the back
#define LEFT_TO_RIGHT (isFront ? -M_PI : M_PI)
#define RIGHT_TO_LEFT (isFront ? M_PI : -M_PI)
    //flipAnimation.toValue = [NSNumber numberWithDouble:[backView isHidden] ? LEFT_TO_RIGHT : RIGHT_TO_LEFT];
    flipAnimation.toValue = [NSNumber numberWithDouble:LEFT_TO_RIGHT / 2.0];
    flipAnimation.duration = duration / 2.0;
    flipAnimation.autoreverses = YES;
    
    // Shrinking the view makes it seem to move away from us, for a more natural effect
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    shrinkAnimation.toValue = [NSNumber numberWithDouble:1.0];
    
    // We only have to animate the shrink in one direction, then use autoreverse to "grow"
    shrinkAnimation.duration = duration / 2.0;
    shrinkAnimation.autoreverses = YES;
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, shrinkAnimation, nil];
    
    // As the edge gets closer to us, it appears to move faster. Simulate this in 2D with an easing function
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Set ourselves as the delegate so we can clean up when the animation is finished
    animationGroup.delegate = self;
    animationGroup.duration = duration;
    
    // Hold the view in the state reached by the animation until we can fix it, or else we get an annoying flicker
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

- (void)animateSetContentView:(NSView *)newView {
#define ANIMATION_DURATION_IN_SECONDS (0.5)
    // Hold the shift key to flip the window in slo-mo. It's really cool!
    NSDictionary *views;
    NSView *oldView = self.contentView;
    CGFloat flipDuration = ANIMATION_DURATION_IN_SECONDS * (self.window.currentEvent.modifierFlags & NSEventModifierFlagShift ? 10.0 : 1.0);
    
    views = [[NSDictionary alloc] initWithObjectsAndKeys:oldView, @"oldView", newView, @"newView", nil];
    
    // The hidden layer is "in the back" and will be rotating forward. The visible layer is "in the front" and will be rotating backward
    [self setWantsLayer:YES];
    CALayer *layer = [self layer];
    
    // Before we can "rotate" the window, we need to make the hidden view look like it's facing backward by rotating it pi radians (180 degrees). We make this its own transaction and supress animation, because this is already the ajrsumed state
    [CATransaction begin]; {
        [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
        //[newLayer setValue:[NSNumber numberWithDouble:M_PI] forKeyPath:@"transform.rotation.y"];
    } [CATransaction commit];
    
    // There's no way to know when we are halfway through the animation, so we have to use a timer. On a sufficiently fast machine (like a Mac) this is close enough. On something like an iPhone, this can cause minor drawing glitches
    [self performSelector:@selector(_animateSetContentView:) withObject:views afterDelay:flipDuration / 2.0];
    [self performSelector:@selector(_animateSetContentViewFinalize:) withObject:views afterDelay:flipDuration];
    
    // Both layers animate the same way, but in opposite directions (front to back versus back to front)
    [CATransaction begin]; {
        [layer addAnimation:[self _flipAnimationWithDuration:flipDuration isFront:YES] forKey:@"flipGroup"];
    } [CATransaction commit];
}

- (void)_animateSetContentView:(NSDictionary *)views {
    [self setContentView:[views objectForKey:@"newView"]];
}

- (void)_animateSetContentViewFinalize:(NSDictionary *)views {
    [self setWantsLayer:NO];
}

- (void)setContentView:(NSView *)view {
    [super setContentView:view];
    // Re-order the views, as necessary...
    if ([[self subviews] count] == 3) {
        NSMutableArray *subviews = [[self subviews] mutableCopy];
        NSView *object = [[self subviews] lastObject];
        [subviews removeLastObject];
        [subviews insertObject:object atIndex:1];
        [self setSubviews:subviews];
    }
    [self tile];
}

- (void)sizeToFit {
    [super sizeToFit];
    [self tile];
}

- (void)setFrameFromContentFrame:(NSRect)frame {
    [super setFrameFromContentFrame:frame];
    [self tile];
}

- (NSSize)titleSize {
    AJRLabelCell *titleCell = (AJRLabelCell *)[self titleCell];
    NSSize titleCellSize = [titleCell cellSize];
    
    if ([self titlePosition] == NSNoTitle) {
        return NSMakeSize(0.0, 0.0);
    }
    
    return titleCellSize;
}

- (NSRect)borderRect {
    return borderRect;
}

- (void)calcBorderRect {
    borderRect = [self bounds];
}

- (void)calcContentViewRect {
    // I haven't decided if I want to preserve margins or not.
    if (border) {
        contentViewRect = [border contentRectForRect:[self bounds]];
    } else {
        contentViewRect = [self bounds];
    }
}

- (BOOL)titleIsAboveCenter {
    NSTitlePosition titlePosition = [self titlePosition];
    
    return titlePosition == NSAboveTop || titlePosition == NSAtTop || titlePosition == NSBelowTop;
}

- (NSRect)titleRect {
    NSRect rect;
    NSSize size = [self titleSize];
    NSRect titleRect = {{0.0, 0.0}, size};
    NSUInteger position = [self titlePosition];
    NSUInteger alignment = [self titleAlignment];
    
    if (border) {
        rect = [[self border] contentRectForRect:[self bounds]];
    } else {
        rect = [self bounds];
    }
    
    switch (position) {
        case NSNoTitle:
            return NSZeroRect;
        case NSAboveTop:
            titleRect.origin.y = rect.origin.y + rect.size.height;
            break;
        case NSAtTop:
            titleRect.origin.y = rect.origin.y + rect.size.height - rint(size.height / 2.0);
            break;
        case NSBelowTop:
            titleRect.origin.y = rect.origin.y + rect.size.height - size.height;
            break;
        case NSAboveBottom:
            titleRect.origin.y = rect.origin.y;
            break;
        case NSAtBottom:
            titleRect.origin.y = rect.origin.y - rint(size.height / 2.0);
            break;
        case NSBelowBottom:
            titleRect.origin.y = rect.origin.y - size.height; 
            break;
    }
    
    switch (alignment) {
    }
    
    //AJRPrintf(@"%C: %d, %d, titleRect: %R\n", self, position, alignment, titleRect);
    
    return titleRect;
}

- (void)_tile:(char)blah {
    [self tile];
}

- (void)tile {
    [self calcBorderRect];
    [self calcContentViewRect];
    fullTitleRect = [self titleRect];
    [(NSView *)[self contentView] setFrame:AJRComputeScaledRect(contentViewRect, contentNaturalSize, boxFlags.contentPosition)];
    labelSize = [[self titleCell] cellSize];
    [[self _backgroundView] setFrame:[self bounds]];
    [[self _foregroundView] setFrame:[self bounds]];
    //AJRPrintf(@"tile: %@, %@\n", [self _backgroundView], [self _foregroundView]);
}

- (NSColor *)backgroundColor {
    if ([contentFill respondsToSelector:@selector(color)]) {
        return [(AJRSolidFill *)contentFill color];
    }
    return nil;
}

- (void)setBackgroundColor:(NSColor *)aColor {
    if ([contentFill respondsToSelector:@selector(setColor:)]) {
        [(AJRSolidFill *)contentFill setColor:aColor];
        [self setNeedsDisplay:YES];
    }
}

- (AJRBoxPosition)position {
    return boxFlags.position;
}

- (void)setPosition:(AJRBoxPosition)position {
    boxFlags.position = position;
    [self tile];
    [self setNeedsDisplay:YES];
}

- (void)setBorder:(AJRBorder *)aBorder {
    if (border != aBorder) {
        NSRect pRect;
        BOOL adjustFrame = NO;
        
        if (border) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AJRBorderDidUpdateNotification object:border];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AJRBorderWillUpdateNotification object:border];
            pRect = [border contentRectForRect:[self frame]];
            adjustFrame = YES;
        }
        border = aBorder;
        if (adjustFrame) {
            if (border) {
                //[self setFrame:[border rectForContentRect:pRect]];
            } else {
            }
        }
        if (border) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(borderWillUpdate:) name:AJRBorderWillUpdateNotification object:border];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(borderDidUpdate:) name:AJRBorderDidUpdateNotification object:border];
            // And make the border share my title cell
            [border setTitleCell:[self titleCell]];
            [border setTitlePosition:[self titlePosition]];
            [border setTitleAlignment:[self titleAlignment]];
        }
        [self tile];
        [self setNeedsDisplay:YES];
    }
}

- (AJRBorder *)border {
    return border;
}

- (void)borderWillUpdate:(NSNotificationCenter *)notification {
    [self willChangeValueForKey:@"border"];
}

- (void)borderDidUpdate:(NSNotificationCenter *)notification {
    [self didChangeValueForKey:@"border"];
    [self setNeedsDisplay:YES];
}

- (void)setContentFill:(AJRFill *)aFill {
    if (contentFill != aFill) {
        if (contentFill) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AJRFillDidUpdateNotification object:contentFill];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AJRFillWillUpdateNotification object:contentFill];
        }
        contentFill = aFill;
        if (contentFill) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentFillDidUpdate:) name:AJRFillDidUpdateNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentFillWillUpdate:) name:AJRFillWillUpdateNotification object:nil];
        }
        [self setNeedsDisplay:YES];
    }
}

- (void)contentFillWillUpdate:(NSNotification *)notification {
    [self willChangeValueForKey:@"contentFill"];
}

- (void)contentFillDidUpdate:(NSNotification *)notification {
    [self didChangeValueForKey:@"contentFill"];
    [self setNeedsDisplay:YES];
}

- (AJRFill *)contentFill {
    return contentFill;
}

- (NSView *)_backgroundView {
    if ([[self subviews] count] == 3) {
        return [[self subviews] objectAtIndex:0];
    }
    return nil;
}

- (NSView *)_foregroundView {
    if ([[self subviews] count] == 3) {
        return [[self subviews] objectAtIndex:2];
    }
    return nil;
}

- (void)setTitleAlignment:(NSUInteger)alignment {
    boxFlags.titleAlignment = alignment;
    [[self border] setTitleAlignment:alignment];
    [self tile];
    [self setNeedsDisplay:YES];
}

- (NSUInteger)titleAlignment {
    return boxFlags.titleAlignment;
}

- (void)setContentPosition:(AJRContentPosition)aPosition {
    boxFlags.contentPosition = aPosition;
    [self tile];
    [self setNeedsDisplay:YES];
}

- (AJRContentPosition)contentPosition {
    return boxFlags.contentPosition;
}

- (void)setContentNatualSize:(NSSize)aSize {
    contentNaturalSize = aSize;
    [self tile];
    [self setNeedsDisplay:YES];
}

- (NSSize)contentNaturalSize {
    return contentNaturalSize;
}

- (void)takeBackgroundColorFrom:sender {
    [self setBackgroundColor:[(NSColorWell *)sender color]]; 
}

- (void)takePositionFrom:sender {
    if ([sender isKindOfClass:[NSMatrix class]]) {
        [self setPosition:[[sender selectedCell] tag]];
    } else {
        [self setPosition:[sender intValue]];
    }
}

- (void)takeBorderTypeFrom:sender {
    [self setBorder:[AJRBorder borderForName:[sender titleOfSelectedItem]]];
}

- (void)takeContentFillTypeFrom:sender {
    [self setContentFill:[AJRFill fillForName:[sender titleOfSelectedItem]]];
}
/*
 - (void)setUpGState
 {
 [super setUpGState];
 [[border clippingPathForRect:[self bounds]] addClip];
 }
 
 - (void)unlockFocus
 {
 //NSBezierPath        *path;
 NSRect                bounds = [self bounds];
 
 // This may seem silly, but it resets the clipping path back to our frame/bounds.
 [super unlockFocus];
 [super lockFocus];
 //[[NSColor blackColor] set];
 //path = [[NSBezierPath alloc] init];
 //[path appendBezierPathWithCrossedRect:bounds];
 //[path stroke];
 [border drawBorderForegroundInRect:bounds clippedToRect:bounds controlView:self];
 [super unlockFocus];
 }
 */

- (void)drawRect:(NSRect)rect
{
//    NSRect                bounds = [self bounds];
//    
//    [[NSColor blackColor] set];
//    NSFrameRect(bounds);
    
//    [border drawBorderBackgroundInRect:bounds clippedToRect:rect controlView:self];
//    [NSGraphicsContext saveGraphicsState];
//    [[border clippingPathForRect:bounds] addClip];
//    [contentFill fillRect:bounds];
//    [NSGraphicsContext restoreGraphicsState];
//    [border drawBorderForegroundInRect:[self bounds] clippedToRect:rect controlView:self];
}

- (NSString *)inspectorClassName {
    NSEvent *event;
    
    event = [NSApp currentEvent];
    if ([event modifierFlags] & NSEventModifierFlagOption) {
        return @"AJRLabelInspector";
    } else {
        return @"AJRBoxInspector";
    }
}

- (AJRBorder *)borderForBorderType:(NSBorderType)type {
    AJRBorder *aBorder;
    
    aBorder = [AJRBorder borderForName:@"Line"];
    
    return aBorder;
}

- (NSView *)contentView {
    if ([[self subviews] count] > 1) {
        return [[self subviews] objectAtIndex:1];
    }
    return [super contentView];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger tInt;
    NSInteger version;
    
    self = [super initWithCoder:aDecoder];
    [[self contentView] setAutoresizesSubviews:NO];
    //   NSLog(@"contenview desired frame:%@\n", NSStringFromRect([self contentViewRect]));
    
    boxFlags.titleAlignment = NSTextAlignmentCenter;
    boxFlags.contentPosition = AJRContentScaledMask | AJRContentScaledPorportional;
    
    if ([aDecoder allowsKeyedCoding] && [aDecoder containsValueForKey:@"fullTitleRect"]) {
        fullTitleRect = [aDecoder decodeRectForKey:@"fullTitleRect"];
        contentViewRect = [aDecoder decodeRectForKey:@"contentViewRect"];
        borderRect = [aDecoder decodeRectForKey:@"borderRect"];
        labelSize = [aDecoder decodeSizeForKey:@"labelSize"];
        boxFlags.autoresizeSubviews = [aDecoder decodeBoolForKey:@"autoresizeSubviews"];
        boxFlags.titleAlignment = [aDecoder decodeIntForKey:@"titleAlignment"];
        [self setBorder:[aDecoder decodeObjectForKey:@"border"]];
        contentFill = [aDecoder decodeObjectForKey:@"contentFill"];
    } else {
        version = [aDecoder versionForClassName:@"AJRBox"];
        if (version == 1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            // These are here to support really old boxes.
            NSColor        *backgroundColor1 = [aDecoder decodeNXColor];
            NSColor        *backgroundColor2 = [aDecoder decodeNXColor];
#pragma clang diagnostic pop
            BOOL        sweeps;
            
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            [self setBorder:[self borderForBorderType:tInt]];
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            // discard title border
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            sweeps = tInt;
            
            if (backgroundColor1 && backgroundColor2 && sweeps) {
                contentFill = [AJRFill fillForName:@"Sweep Fill"];
                [(AJRGradientFill *)contentFill setColor:backgroundColor1];
                [(AJRGradientFill *)contentFill setSecondaryColor:backgroundColor2];
            } else if (backgroundColor1) {
                contentFill = [AJRFill fillForName:@"Solid Fill"];
                [(AJRSolidFill *)contentFill setColor:backgroundColor1];
            }
        } else if (version <= 5) {
            NSColor        *backgroundColor1 = [aDecoder decodeObject];
            NSColor        *backgroundColor2 = [aDecoder decodeObject];
            BOOL            sweeps;
            
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            [self setBorder:[self borderForBorderType:tInt]];
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            // discard title border
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            sweeps = tInt;
            if (version == 2) {
                [self tile];
            } else if (version >= 3) {
                NSInteger        appearance;
                
                [aDecoder decodeValueOfObjCType:"i" at:&tInt];
                [self borderForBorderType:tInt]; // Discard content border
                [aDecoder decodeValueOfObjCType:"i" at:&tInt];
                boxFlags.position = tInt;
                [aDecoder decodeValueOfObjCType:"i" at:&tInt];
                appearance = tInt;
                [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&fullTitleRect];
                [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&contentViewRect];
                [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&borderRect];
                [aDecoder decodeValueOfObjCType:@encode(NSSize) at:&labelSize];
                if (version >= 4) {
                    [aDecoder decodeValueOfObjCType:"i" at:&tInt];
					[self setAutoresizesSubviews:tInt];
                    boxFlags.autoresizeSubviews = tInt;
                    if (version == 5) {
                        [aDecoder decodeValueOfObjCType:"i" at:&tInt];
                        boxFlags.titleAlignment = tInt;
                    }
                }
                if (backgroundColor1 && backgroundColor2 && sweeps) {
                    contentFill = [AJRFill fillForName:@"Sweep Fill"];
                    [(AJRGradientFill *)contentFill setColor:backgroundColor1];
                    [(AJRGradientFill *)contentFill setSecondaryColor:backgroundColor2];
                } else if (backgroundColor1) {
                    contentFill = [AJRFill fillForName:@"Solid Fill"];
                    [(AJRSolidFill *)contentFill setColor:backgroundColor1];
                }
                [self tile];
            }
        } else if (version == 6) {
            NSColor *backgroundColor1 = [aDecoder decodeObject];
            NSColor *backgroundColor2 = [aDecoder decodeObject];
            BOOL sweeps, drawsBackground;
            
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            sweeps = tInt;
            
            [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&fullTitleRect];
            [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&contentViewRect];
            [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&borderRect];
            [aDecoder decodeValueOfObjCType:@encode(NSSize) at:&labelSize];
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            boxFlags.autoresizeSubviews = tInt;
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            boxFlags.titleAlignment = tInt;
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            drawsBackground = tInt;
            
            [self setBorder:[aDecoder decodeObject]];
            [aDecoder decodeObject]; // discard content border
            if (backgroundColor1 && backgroundColor2 && sweeps) {
                contentFill = [AJRFill fillForName:@"Sweep Fill"];
                [(AJRGradientFill *)contentFill setColor:backgroundColor1];
                [(AJRGradientFill *)contentFill setSecondaryColor:backgroundColor2];
            } else if (backgroundColor1 && drawsBackground) {
                contentFill = [AJRFill fillForName:@"Solid Fill"];
                [(AJRSolidFill *)contentFill setColor:backgroundColor1];
            }
            [self tile];
        } else if (version == 7) {
            [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&fullTitleRect];
            [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&contentViewRect];
            [aDecoder decodeValueOfObjCType:@encode(NSRect) at:&borderRect];
            [aDecoder decodeValueOfObjCType:@encode(NSSize) at:&labelSize];
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            boxFlags.autoresizeSubviews = tInt;
            [aDecoder decodeValueOfObjCType:"i" at:&tInt];
            boxFlags.titleAlignment = tInt;
            
            [self setBorder:[aDecoder decodeObject]];
            contentFill = [aDecoder decodeObject];
            [self tile];
        } else {
            [NSException raise:AJRBadObjectVersionException format:AJRBadObjectVersionFormat];
        }
    } 
    
    boxFlags.appIsIB = [[[NSProcessInfo processInfo] processName] isEqualToString:@"Interface Builder"];
    
    [self setupSubviews];
    [[self contentView] setAutoresizesSubviews:[self autoresizesSubviews]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSInteger tInt;
    
    [super encodeWithCoder:aCoder];
    
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeRect:fullTitleRect forKey:@"fullTitleRect"];
        [aCoder encodeRect:contentViewRect forKey:@"contentViewRect"];
        [aCoder encodeRect:borderRect forKey:@"borderRect"];
        [aCoder encodeSize:labelSize forKey:@"labelSize"];
        [aCoder encodeBool:boxFlags.autoresizeSubviews forKey:@"autoresizeSubviews"];
        [aCoder encodeInt:boxFlags.titleAlignment forKey:@"titleAlignment"];
        [aCoder encodeObject:border forKey:@"border"];
        [aCoder encodeObject:contentFill forKey:@"contentFill"];
    } else {
        [aCoder encodeValueOfObjCType:@encode(NSRect) at:&fullTitleRect];
        [aCoder encodeValueOfObjCType:@encode(NSRect) at:&contentViewRect];
        [aCoder encodeValueOfObjCType:@encode(NSRect) at:&borderRect];
        [aCoder encodeValueOfObjCType:@encode(NSSize) at:&labelSize];
        tInt = boxFlags.autoresizeSubviews;
        [aCoder encodeValueOfObjCType:"i" at:&tInt];
        tInt = boxFlags.titleAlignment;
        [aCoder encodeValueOfObjCType:"i" at:&tInt];
        
        [aCoder encodeObject:border];
        [aCoder encodeObject:contentFill];
    }
}

- (void)setAutoresize:(BOOL)flag {
	[super setAutoresizesSubviews:flag];
    boxFlags.autoresizeSubviews = flag;
}

- (BOOL)autoresize {
    return boxFlags.autoresizeSubviews;
}

- (void)setAutoresizesSubviews:(BOOL)flag {
	[super setAutoresizesSubviews:boxFlags.autoresizeSubviews];
}

- (BOOL)autoresizesSubviews {
    return boxFlags.autoresizeSubviews;
}

- (BOOL)isFlipped {
    return boxFlags.flipped;
}

- (AJRInset)shadowInset {
    if (border) {
        [border shadowInset];
    }
    return (AJRInset){0, 0, 0, 0};
}

/*
 - (void)_drawRect:(NSRect)rect clip:(BOOL)clip
 {
 NSRect                bounds = [self bounds];
 
 //AJRPrintf(@"_drawRect:%@ clip:%@\n", NSStringFromRect(rect), clip ? @"YES" : @"NO");
 //AJRPrintf(@"   focusView = %@\n", [NSView focusView]);
 
 NSRectClip(rect);
 [border drawBorderBackgroundInRect:bounds clippedToRect:rect controlView:self];
 [[border clippingPathForRect:bounds] addClip];
 [contentFill fillRect:bounds];
 [super _drawRect:rect clip:clip];
 }
 */

@end

