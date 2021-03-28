
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class AJRCalendarItemInspector;

typedef NS_ENUM(UInt8) {
    AJRButtonRight = 1,
    AJRButtonMiddle = 2,
    AJRButtonLeft = 3
} AJRButtonLocation;

@interface AJRCalendarItemInspectorWindow : NSWindow <CAAnimationDelegate> {
    CGFloat _arrowShift;

    ///////////////
    // Animation //
    ///////////////
    NSRect _originalWidowFrame;
    NSRect _originalLayerFrame;
    
    NSView *_oldContentView;
    NSResponder *_oldFirstResponder;
    NSView *_animationView;
    CALayer *_animationLayer;
    
    BOOL _growing;
    BOOL _shrinking;
    BOOL _pretendKeyForDrawing;
    NSWindow *_eventualParent;
    CGFloat _minYCoordinate;
    CGFloat _maxXCoordinate;
}

- (id)initWithScreenLocation:(NSPoint)location;

- (AJRCalendarItemInspector *)inspector;

- (CGFloat)arrowShift;
- (void)pointToRect:(NSRect)rect;

- (NSView *)documentView;
- (void)setDocumentView:(NSView *)documentView;
- (IBAction)dismiss:(id)sender;

- (NSTextField *)titleField;
- (void)setButtonTitle:(NSString *)title 
         keyEquivalent:(NSString *)keyEquivalent
               enabled:(BOOL)enabled
                target:(id)target
                action:(SEL)action
           forLocation:(AJRButtonLocation)location;

- (void)popup;
- (void)setEventualParent:(NSWindow *)window;

- (void)updateFrameToAccomodateHeight:(CGFloat)height animate:(BOOL)animate;

@end

@interface NSObject (AJRCalendarItemInspectorWindowDelegate)

- (void)windowDidCompletePopAnimation:(NSWindow *)window;

@end
