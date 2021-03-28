
#import <Cocoa/Cocoa.h>

@interface NSEvent (AJRInterfaceExtensions)

- (NSPoint)ajr_locationInView:(NSView *)view;
+ (NSPoint)ajr_locationInView:(NSView *)view;

@end
