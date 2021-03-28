
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *AJRDownArrowTemplateName;

typedef NS_ENUM(NSInteger, AJRDotColor) {
    AJRDotColorBlack,
    AJRDotColorGray,
    AJRDotColorWhite,
    AJRDotColorRed,
    AJRDotColorYellow,
    AJRDotColorGreen,
    AJRDotColorCyan,
    AJRDotColorBlue,
    AJRDotColorMagenta,
};

@interface AJRImages : NSObject

+ (nullable NSImage *)imageNamed:(NSString *)name;
+ (nullable NSImage *)imageNamed:(NSString *)name forObject:(id)object;
+ (nullable NSImage *)imageNamed:(NSString *)name forClass:(id)class;
+ (nullable NSImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle NS_SWIFT_NAME(image(named:in:));
+ (nullable NSImage *)imageNamed:(NSString *)name inBundles:(NSArray<NSBundle *> *)bundles NS_SWIFT_NAME(image(named:in:));
+ (nullable NSImage *)imageForObject:(id)object;
+ (nullable NSImage *)imageForClass:(id)class;

+ (nullable NSImage *)compositeCheckbox:(NSArray *)pieces;
+ (nullable NSArray<NSImage *> *)checkBoxImagesForColor:(NSColor *)color;

+ (NSImage *)viewBorderImageFocused;
+ (NSImage *)viewBorderImageUnfocused;

+ (NSImage *)dotWithColor:(AJRDotColor)color controlSize:(NSControlSize)controlSize;

@end

NS_ASSUME_NONNULL_END
