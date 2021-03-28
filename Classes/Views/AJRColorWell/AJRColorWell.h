
#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, AJRColorWellDisplay) {
    AJRColorWellDisplayColor,
    AJRColorWellDisplayNone,
    AJRColorWellDisplayMultiple
};

extern void AJRDrawColorSwatch(NSColor *color, BOOL isMultipleValues, NSRect rect);
extern NSImage *AJRColorSwatchImage(NSColor *color, BOOL isMultipleValues, NSSize colorImageSize);
extern NSMenu *AJRColorSwatchMenu(id colorTarget, SEL colorAction, id showColorsTarget, SEL showColorsAction);

IB_DESIGNABLE @interface AJRColorWell : NSColorWell

@property (nonatomic,assign) AJRColorWellDisplay displayMode;

@end
