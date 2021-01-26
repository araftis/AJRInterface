
#import <AppKit/AppKit.h>

#import <AJRInterface/AJRInterfaceDefines.h>

extern NSString *AJRStringFromColor(NSColor *color);
extern NSColor *AJRColorFromString(NSString *color);
extern NSString *AJRStringFromFont(NSFont *font);
extern NSFont *AJRFontFromString(NSString *font);

@interface NSUserDefaults (AJRInterfaceExtensions)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)key;
- (NSColor *)colorForKey:(NSString *)key;

- (void)setPrintInfo:(NSPrintInfo *)anInfo forKey:(NSString *)aKey;
- (NSPrintInfo *)printInfoForKey:(NSString *)aKey;

- (void)setFont:(NSFont *)aFont forKey:(NSString *)aKey;
- (NSFont *)fontForKey:(NSString *)key;
- (NSFont *)fontForKey:(NSString *)key defaultFont:(NSFont *)defaultFont;

- (NSSize)sizeForKey:(NSString *)key;
- (void)setSize:(NSSize)size forKey:(NSString *)key;

@end
