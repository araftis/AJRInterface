
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import <AJRInterface/AJRLabel.h>
#import <AJRInterfaceFoundation/AJRInset.h>

#ifndef NSBezelOutBorder
#define NSBezelOutBorder 4
#endif

#ifdef AJRPaperBorder
#undef AJRPaperBorder
#endif
#define AJRPaperBorder 5

typedef NS_ENUM(NSInteger, AJRBoxPosition) {
    AJRBoxNone        = 0,
    AJRBoxTop        = 1,
    AJRBoxBottom        = 2,
    AJRBoxLeft        = 3,
    AJRBoxRight        = 4,
    AJRBoxFloating    = 5
};

typedef NSUInteger AJRContentPosition;

@class AJRBorder, AJRFill;


@interface AJRBox : NSBox <CAAnimationDelegate>
{
    NSRect                     fullTitleRect;
    NSRect                     contentViewRect;
    NSRect                     borderRect;
    NSSize                     labelSize;
    NSSize                    contentNaturalSize;
    AJRBorder                *border;
    AJRFill                    *contentFill;
    NSRect                    displayRect;
    
    struct _boxFlags {
        AJRBoxPosition        position:3;
        BOOL                hasInitialized:1;
        BOOL                hasAwakened:1;
        BOOL                autoresizeSubviews:1;
        NSUInteger            titleAlignment:3;
        BOOL                drawnOnce:1;
        BOOL                flipped:1;
        AJRContentPosition    contentPosition:3;
        BOOL                 ibResizeHack:1;
        BOOL                appIsIB:1;
        NSUInteger            _pad:10;
    } boxFlags;
}

- (id)initWithFrame:(NSRect)frameRect;

- (void)animateSetContentView:(NSView *)view;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aColor;
- (void)setBorder:(AJRBorder *)aBorder;
- (AJRBorder *)border;
- (void)setContentFill:(AJRFill *)aFill;
- (AJRFill *)contentFill;
- (void)setTitleAlignment:(NSUInteger)alignment;
- (NSUInteger)titleAlignment;
- (void)setContentPosition:(AJRContentPosition)aPosition;
- (AJRContentPosition)contentPosition;
- (void)setContentNatualSize:(NSSize)aSize;
- (NSSize)contentNaturalSize;

- (AJRBoxPosition)position;
- (void)setPosition: (AJRBoxPosition)position;

- (void)takeBackgroundColorFrom:sender;
- (void)takeBorderTypeFrom:sender;
- (void)takeContentFillTypeFrom:sender;
- (void)takePositionFrom:sender;

- (void)tile;

- (void)setAutoresize: (BOOL)flag;
- (BOOL)autoresize;
- (void)setAutoresizesSubviews: (BOOL)flag;
- (BOOL)autoresizesSubviews;

- (AJRInset)shadowInset;

@end

