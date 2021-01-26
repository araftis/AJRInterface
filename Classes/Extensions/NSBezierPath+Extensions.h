
#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRFoundation.h>

@class AJRPathEnumerator;

@interface NSBezierPath (AJRInterfaceExtensions) <AJRXMLCoding>

- (void)appendBezierPathWithString:(NSString *)string font:(NSFont *)font NS_SWIFT_NAME(appendString(_:font:));
- (void)appendBezierPathWithAttributedString:(NSAttributedString *)string NS_SWIFT_NAME(appendAttributedString(_:));
+ (void)drawString:(NSString *)string font:(NSFont *)font at:(NSPoint)point;

+ (NSBezierPath *)bezierPathWithCrossedRect:(NSRect)rect;
- (void)appendBezierPathWithCrossedRect:(NSRect)rect;
- (void)appendBezierPathWithCrossCenteredAt:(NSPoint)center legSize:(NSSize)legSize andLegThickness:(NSSize)legThickness;

- (AJRPathEnumerator *)pathEnumerator;

/*!
 Add the path to the supplied context, including the receivers path settings, such as line width, line cap, etc...
 
 @param context The graphics context into which the path should be added.
 */
- (void)addPathToContext:(CGContextRef)context;

/*!
 Returns a path that when filled, strokes the receiver as if [self stroke] had been called. Note that the returned path is really not useful for anything other than filling or hit testing.
 
 @return A bezier path useful for filling or hit testing the receivers stroke.
 */
- (NSBezierPath *)bezierPathFromStrokedPath;

@end
