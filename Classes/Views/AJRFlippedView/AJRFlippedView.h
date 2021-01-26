
#import <AppKit/AppKit.h>

@interface AJRFlippedView : NSView <NSCoding>

@property (nonatomic,strong) IBInspectable NSColor *backgroundColor;
@property (nonatomic,strong) IBInspectable NSColor *borderColor;
@property (nonatomic,strong) IBInspectable NSColor *borderColorTop;
@property (nonatomic,strong) IBInspectable NSColor *borderColorLeft;
@property (nonatomic,strong) IBInspectable NSColor *borderColorBottom;
@property (nonatomic,strong) IBInspectable NSColor *borderColorRight;
@property (nonatomic,strong) IBInspectable NSColor *inactiveBorderColor;
@property (nonatomic,strong) IBInspectable NSColor *inactiveBorderColorTop;
@property (nonatomic,strong) IBInspectable NSColor *inactiveBorderColorLeft;
@property (nonatomic,strong) IBInspectable NSColor *inactiveBorderColorBottom;
@property (nonatomic,strong) IBInspectable NSColor *inactiveBorderColorRight;
@property (nonatomic,assign) IBInspectable BOOL borderIsHairline;
@property (nonatomic,strong) IBInspectable NSColor *crossColor;

- (BOOL)isFlipped;

@end
