
#import "AJRCalendarItemInspectorWindow.h"

#import "AJRBox.h"
#import "AJRCalendarItemInspectorController.h"
#import "AJRSolidFill.h"
#import "NSAttributedString+Extensions.h"
#import "NSColor+Extensions.h"
#import "_AJRCalendarItemInspectorFrame.h"

#import <Quartz/Quartz.h>

static const CGFloat GROW_ANIMATION_DURATION = 0.20;
static const CGFloat GROW_SCALE = 1.25;
static const CGFloat SHRINK_ANIMATION_DURATION = 0.10;
static const CGFloat SHRINK_SCALE = 0.80;
static const CGFloat RESTORE_ANIMATION_DURATION = 0.10;

static const CGFloat AJRMaxInspectorHeight = 488.0;

@interface AJRCalendarItemInspectorWindow ()

- (_AJRCalendarItemInspectorFrame *)frameView;

@end


@implementation AJRCalendarItemInspectorWindow

#pragma mark Initialization

- (id)initWithScreenLocation:(NSPoint)location {
    if ((self = [super initWithContentRect:(NSRect){{100.0, 50.0}, {312.0, AJRMaxInspectorHeight}} styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO])) {
        _AJRCalendarItemInspectorFrame    *windowFrame;
        NSScreen                        *screen = [self screen];
        NSRect                            screenRect = [screen visibleFrame];
        
        _minYCoordinate = screenRect.origin.y;
        _maxXCoordinate = screenRect.origin.x + screenRect.size.width;
        
        [self setBackgroundColor:[NSColor clearColor]];
        [self setMaxSize:(NSSize){312.0, AJRMaxInspectorHeight}];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self setMovableByWindowBackground:YES];

        windowFrame = [[_AJRCalendarItemInspectorFrame alloc] initWithFrame:(NSRect){NSZeroPoint, [self frame].size}];
        [self setContentView:windowFrame];
    }
    return self;
}


#pragma mark Properties

- (AJRCalendarItemInspector *)inspector {
    return [(AJRCalendarItemInspectorController *)[self delegate] inspector];
}

- (CGFloat)arrowShift {
    return _arrowShift;
}

#pragma mark Window Placement

- (void)pointToRect:(NSRect)rect {
    NSPoint point = { rect.origin.x + rect.size.width * (5.0 / 6.0), NSMidY(rect) };
    NSRect frame = [self frame];
    CGFloat offsetX = 0.0;
    CGFloat offsetY = frame.size.height * (2.0 / 3.0);
    
    frame.origin.x = point.x + offsetX;
    frame.origin.y = point.y - offsetY;
    
    // Make sure if we're pointing off screen, we don't and that we shift our arrow.
    if (frame.origin.y < _minYCoordinate) {
        _arrowShift = fabs(_minYCoordinate - frame.origin.y);
        frame.origin.y = _minYCoordinate;
    } else {
        _arrowShift = 0.0;
    }
    if (frame.origin.x + frame.size.width > _maxXCoordinate) {
        frame.origin.x = rect.origin.x - frame.size.width * (5.0 / 6.0);
        [[self frameView] setPointerDirection:_AJRPointRight];
    } else {
        [[self frameView] setPointerDirection:_AJRPointLeft];
    }

    [self setFrameOrigin:frame.origin];
}

#pragma mark NSWindow

- (_AJRCalendarItemInspectorFrame *)frameView {
    NSView    *view = [self contentView];
    if ([view isKindOfClass:[_AJRCalendarItemInspectorFrame class]]) {
        return [self contentView];
    }
    return nil;
}

- (NSView *)documentView {
    return [[self frameView] contentView];
}

- (void)setDocumentView:(NSView *)documentView {
    [[self frameView] setContentView:documentView];
}

- (void)setTitle:(NSString *)title {
    if (title == nil) title = @"";
    [super setTitle:title];
    [[self frameView] setTitle:title];
}

- (void)_setTitle:(NSString *)title {
    [super setTitle:title];
}

- (void)setFrame:(NSRect)frame display:(BOOL)flag {
    [super setFrame:frame display:_animationView == nil];//YES];
}

- (BOOL)makeFirstResponder:(NSResponder *)responder {
    if ([super makeFirstResponder:responder]) {
        [[self frameView] setNeedsDisplay:YES];
        return YES;
    }
    return NO;
}

- (void)orderFront:(id)sender {
    [self makeFirstResponder:[self frameView]];
    [super orderFront:sender];
}

#pragma mark Actions

- (IBAction)dismiss:(id)sender {
    NSWindow *parent = [self parentWindow];
    
    if (parent) {
        [parent removeChildWindow:self];
    }
    [self orderOut:self];
}

#pragma mark Window Frame

- (NSTextField *)titleField {
    return [[self frameView] titleField];
}

- (void)setButtonTitle:(NSString *)title 
         keyEquivalent:(NSString *)keyEquivalent
               enabled:(BOOL)enabled
                target:(id)target
                action:(SEL)action
           forLocation:(AJRButtonLocation)location {
    [[self frameView] setButtonTitle:title keyEquivalent:keyEquivalent enabled:enabled target:target action:action forLocation:location];
}

#pragma mark Animation

- (void)_cleanupAndRestoreViews {
    NSScreen *screen = [self screen];
    NSRect screenRect = [screen visibleFrame];

    // Reset this now, since we're about to restore the window to its correct size.
    _minYCoordinate = screenRect.origin.y;
    _maxXCoordinate = screenRect.origin.x + screenRect.size.width;

    // Swap back the content view
    if (_oldContentView != nil) {
        // We disable screen updates to avoid any flashing that might happening when one layer backed view goes away and another regular view replaces it.
        [self setFrame:_originalWidowFrame display:NO];
        [self setContentView:_oldContentView];
        _oldContentView = nil;
        
        [self makeFirstResponder:_oldFirstResponder];
        _oldFirstResponder = nil;
        
        _animationView = nil;
        
        _animationLayer = nil; // Non retained
        
        if (_eventualParent) {
            [_eventualParent addChildWindow:self ordered:NSWindowAbove];
            _eventualParent = nil;
        }
    }
    _shrinking = NO;
    _growing = NO;
    
    // We're done, so notify our delegate if necessary
    if ([[self delegate] respondsToSelector:@selector(windowDidCompletePopAnimation:)]) {
        [(id)[self delegate] windowDidCompletePopAnimation:self];
    }
}

- (CATransform3D)_transformForScale:(CGFloat)scale {
    if (scale == 1.0) {
        return CATransform3DIdentity;
    } else {
        // Start at the scale percentage
        CATransform3D    scaleTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0);
        CGFloat            height = _originalLayerFrame.size.height;
        CGFloat            width = _originalLayerFrame.size.width;
        CGFloat            yOffset = height * (2.0 / 3.0);
        // Create a translation to make us popup from somewhere other than the center
        yOffset = (height - yOffset) / 2.0; // Flip and scale Y for our current coordinate space
        // Now offset for the arrow shift. This happens here, and not before the divide by 2, because
        // the arrow shift is the same, despite being in a "larger" window for the animation.
        yOffset -= [self arrowShift];
        CGFloat yTrans = yOffset - (yOffset * scale);
        CGFloat xTrans = -width / 2.0 + (width * scale) / 2.0;
        CATransform3D translateTransform = CATransform3DTranslate(CATransform3DIdentity, xTrans, yTrans, 1.0);
        return CATransform3DConcat(scaleTransform, translateTransform);
    }
}

- (void)_addAnimationToScale:(CGFloat)scale duration:(NSTimeInterval)duration {
    CABasicAnimation *transformAni = [CABasicAnimation animation];
    transformAni.fromValue = [NSValue valueWithCATransform3D:_animationLayer.transform];
    transformAni.duration = duration;
    // We make ourselves the delegate to get notified when the animation ends
    transformAni.delegate = self;
    // Set the final "toValue" for the animation and the layer contents. 
    // At the end of the animation it is left at this value, which is what we want
    _animationLayer.transform = [self _transformForScale:scale];
    [_animationLayer addAnimation:transformAni forKey:@"transform"];
}

// Chain several animations together -- one starting at the end of the other
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        _animationLayer.transform = [self _transformForScale:1.0];
        [self _cleanupAndRestoreViews];
    } else if (_growing) {
        _growing = NO;
        _shrinking = YES;
        [self _addAnimationToScale:SHRINK_SCALE duration:SHRINK_ANIMATION_DURATION];
    } else if (_shrinking) {
        _shrinking = NO;
        [self _addAnimationToScale:1.0 duration:RESTORE_ANIMATION_DURATION];
    } else {
        [self _cleanupAndRestoreViews];
    }
}

// Our window doesn't have a title bar or a resize bar, but we want it to still become key. However, we want the tableview to draw as the first responder even when the window isn't key. So, we return NO when we are drawing to work around that.
- (BOOL)canBecomeKeyWindow {
    if (_pretendKeyForDrawing) return NO;
    return YES;
}

// The scrollers always draw blue if they are in a key window. Temporarily tell them that our window is key for caching the proper image.
- (BOOL)isKeyWindow {
    if (_pretendKeyForDrawing) return YES;
    return [super isKeyWindow];
}

- (void)popup {
    NSScreen *screen = [self screen];
    NSRect screenRect = [screen visibleFrame];

    // Stop any existing animations
    if (_animationView != nil) {
        [_animationLayer removeAllAnimations];
        [self _cleanupAndRestoreViews];
    }
    
    // Perform some initial setup - hide the window and make us not have a shadow while animating
    if ([self isVisible]) {
        [self orderOut:nil];
    }
    
    // Grab the content view and cache its contents
    _oldContentView = [self contentView];
    // We also want to restore the current first responder
    _oldFirstResponder = [self firstResponder];
    
    _pretendKeyForDrawing = YES;
    NSRect visibleRect = [_oldContentView visibleRect];
    NSBitmapImageRep *imageRep = [_oldContentView bitmapImageRepForCachingDisplayInRect:visibleRect];
    [_oldContentView cacheDisplayInRect:visibleRect toBitmapImageRep:imageRep];
    _pretendKeyForDrawing = NO;
    
    // Create a new content view for animating
    _animationView = [[AJRBox alloc] initWithFrame:visibleRect];
    [(AJRBox *)_animationView setBorder:nil];
    [(AJRBox *)_animationView setTitlePosition:NSNoTitle];
    AJRSolidFill    *fill = [[AJRSolidFill alloc] init];
    [fill setColor:[NSColor clearColor]];
    [(AJRBox *)_animationView setContentFill:fill];
    [_animationView setWantsLayer:YES];
    [self setContentView:_animationView];

    // Temporarily enlargen the window size to accomidate the "grow" animation.
    _originalWidowFrame = self.frame;
    CGFloat xGrow = NSWidth(_originalWidowFrame)*0.5;
    CGFloat yGrow = NSHeight(_originalWidowFrame)*0.5;
    _minYCoordinate = screenRect.origin.y - yGrow;
    _maxXCoordinate = screenRect.origin.x + screenRect.size.width;
    [self setFrame:NSInsetRect(_originalWidowFrame, -xGrow, -yGrow) display:NO];
    
    // Calculate where we want the animation layer to be based off of the offset we set above
    _originalLayerFrame = visibleRect;
    _originalLayerFrame.origin.x += xGrow;
    _originalLayerFrame.origin.y += yGrow;
    
    // Create a manual layer and control it's contents and position
    _animationLayer = [CALayer layer];
    _animationLayer.frame = NSRectToCGRect(_originalLayerFrame);
    _animationLayer.contents = (id)[imageRep CGImage];
    // A shadow is needed to match what the window normally has
    _animationLayer.shadowOpacity = 0.50;
    _animationLayer.shadowRadius = 4;
    // Start at 1% scale
    _animationLayer.transform = [self _transformForScale:0.01];
    
    // Get the layer into the rendering tree
    [[_animationView layer] addSublayer:_animationLayer];
    
    // Bring the window up and flush the contents
    [self makeKeyAndOrderFront:nil];
    [self displayIfNeeded];
    
    // Start the grow animation
    _growing = YES;
    [self _addAnimationToScale:GROW_SCALE duration:GROW_ANIMATION_DURATION];
}

- (void)setEventualParent:(NSWindow *)window {
    _eventualParent = window;
}

- (void)sendEvent:(NSEvent *)event {
    // Don't send events if our parent window is displaying a sheet.
    if ([[self parentWindow] attachedSheet] == nil) {
        [super sendEvent:event];
    }
}

- (void)updateFrameToAccomodateHeight:(CGFloat)height animate:(BOOL)animate {
    [[self frameView] tileToContainHeight:height withAnimation:animate];
}

@end
