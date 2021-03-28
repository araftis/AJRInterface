
#import <Cocoa/Cocoa.h>

@interface NSString (AJRInterfaceExtensions)

- (NSSize)sizeWithAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes constrainedToWidth:(CGFloat)width NS_SWIFT_NAME(size(withAttributes:constrainedToWidth:));

- (void)drawAtPoint:(NSPoint)point withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs context:(CGContextRef)context;
- (void)drawInRect:(NSRect)rect withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs context:(CGContextRef)contextl;

- (NSString *)stringByReplacingTypographicalSubstitutions;

@end
