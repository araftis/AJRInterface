
#import <AppKit/AppKit.h>

@class AJRImageFormat;

@interface AJRImageSaveAccessory : NSObject

- (instancetype)initWithSavePanel:(NSSavePanel *)savePanel;

- (AJRImageFormat *)currentImageFormat;

- (NSView *)view;

- (void)selectFormat:(id)sender;

- (NSData *)representationForImage:(NSImage *)image;

@end
