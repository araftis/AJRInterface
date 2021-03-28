
#import <Cocoa/Cocoa.h>

@interface NSAttributedString (AJRInterfaceExtensions)

- (NSSize)ajr_sizeConstrainedToWidth:(CGFloat)width;

- (void)ajr_drawAtPoint:(NSPoint)point context:(CGContextRef)context;
- (void)ajr_drawInRect:(NSRect)rect context:(CGContextRef)context;

@end
