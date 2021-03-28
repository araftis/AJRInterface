
#import <AJRInterface/AJRCalendarItemInspectorWindow.h>

@class AJRCalendarItemInspector, AJRDropShadowBorder;

typedef enum __AJRPointerDirection {
    _AJRPointUp,
    _AJRPointDown,
    _AJRPointLeft,
    _AJRPointRight
} _AJRPointerDirection;

@interface AJRCalendarItemInspectorWindow (Private) 

/*!
 Sets the window title, without calling back to the frame view.
 */
- (void)_setTitle:(NSString *)title;

@end

@interface _AJRCalendarItemInspectorFrame : NSView <NSTextFieldDelegate>
{
    NSGradient *_backgroundGradient;
    NSScrollView *_scrollView;
    NSView *_contentView;
    NSTextField *_titleField;
    NSButton *_rightButton;
    NSButton *_middleButton;
    NSButton *_leftButton;
    NSMutableDictionary *_titleAttributes;
    BOOL _isScrolling;
    BOOL _isTiling;
    _AJRPointerDirection _pointerDirection;
    AJRDropShadowBorder *_dropShadow;
    
    NSRect _desiredBounds;
    NSRect extraFrame;
    NSSize _lastSize;
}

- (AJRCalendarItemInspector *)inspector;

- (NSRect)desiredBounds;
- (CGFloat)desiredHeight;
- (CGFloat)desiredHeightForHeight:(CGFloat)inputHeight;
- (CGFloat)titleHeight;

- (NSRect)contentViewFrame;
- (NSRect)titleFrame;

- (NSRect)buttonFrameForLocation:(AJRButtonLocation)location;
- (NSButton *)buttonForLocation:(AJRButtonLocation)location;

@property (nonatomic,strong) NSScrollView *scrollView;
@property (nonatomic,strong) NSTextField *titleField;
@property (nonatomic,strong) NSButton *rightButton;
@property (nonatomic,strong) NSButton *middleButton;
@property (nonatomic,strong) NSButton *leftButton;
@property (nonatomic,strong) NSMutableDictionary *titleAttributes;
@property (nonatomic,assign) _AJRPointerDirection pointerDirection;

- (NSView *)contentView;
- (void)setContentView:(NSView *)contentView;

- (void)setTitle:(NSString *)title;
- (NSTextField *)titleField;
- (void)setButtonTitle:(NSString *)title 
         keyEquivalent:(NSString *)keyEquivalent
               enabled:(BOOL)enabled
                target:(id)target
                action:(SEL)action
           forLocation:(AJRButtonLocation)location;

- (void)tile;
- (void)tileToContainHeight:(CGFloat)height withAnimation:(BOOL)animate;

- (NSRect)frameForDropShadowForFirstResponder:(NSResponder *)responder;

@end
