/*
 NSBezierPath+Extensions.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <AppKit/AppKit.h>
#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPathEnumerator;

@interface NSBezierPath (AJRInterfaceExtensions) <AJRXMLCoding, AJRBezierPathProtocol>

/*!
 Appends the `string` to the receiver using `font`.  This will attempt to do a good job with all the various font characteristis, but is a fairly basic mechanism. If you have more complicate stings, consider using `-[NSBezierPAth appendBezierPathWithAttributedString:]`, as that allows more complex typography.

 @param string The string to append.
 @param font The font to use.
 */
- (void)appendBezierPathWithString:(NSString *)string font:(NSFont *)font NS_SWIFT_NAME(appendString(_:font:));

/*!
 Appends the attributed string, `string`, to the receiver. This method allows for complex typography, and should work with all languages.

 @param string The attributed string to append.
 */
- (void)appendBezierPathWithAttributedString:(NSAttributedString *)string NS_SWIFT_NAME(appendAttributedString(_:));

/*!
 Draw the string into the current graphics context. This is mostly here to help support old API usage, and it isn't really considered the ideal way to render a string. You should really consider using the methods on `NSString` and `NSMutableString`. They'll produce superior results.

 Still, this method is simple and straight forward, and can be useful for debugging. Avoid using it for final production code.

 @param string The string to darw.
 @param font The font to use.
 @param point Where to draw the string.
 */
+ (void)drawString:(NSString *)string font:(NSFont *)font at:(NSPoint)point;

/*!
 Creates a bezier path with a rectangle with the opposite corners also joined by line segments. This can be useful to doing things like debugging placements of subcomponents in views and views themselves.

 @param rect The rectangle to render.

 @returns A new bezier path with a rectangle with an X.
 */
+ (NSBezierPath *)bezierPathWithCrossedRect:(NSRect)rect;

/*!
 Appends a rectangle with a crossed X joining the corners. This is useful for things like debugging view layout.

 @param rect The rectangle to append.
 */
- (void)appendBezierPathWithCrossedRect:(NSRect)rect;

/*!
 Appends a cross to the receiver centered at `center`. You can control the size of the legs of the cross via the `legSize` and `legThickness` parameters. Note that the thickness should be less than the size, you'll get some interesting results.

 @param center The center of the cross.
 @param legSize The size of the leg. This is the length from the center.
 @param legThickness This is the thickenss of the leg. The thickness should be less than the size, or strange things will happen.
 */
- (void)appendBezierPathWithCrossCenteredAt:(NSPoint)center legSize:(NSSize)legSize andLegThickness:(NSSize)legThickness;

/*!
 Returns an path enumerator you can uset to enumerate the path. The enumerator has a couple of interfaces that let you interact in different ways, but the two important ones are `-[AJRPathEnumerator nextElementWithPoints:]` and `-[AJRBezierPath nextLineSegmentIsNewSubpath]`, the latter of which will return the path flattened. When using the latter, make sure you consider setting the `error` property of the enumerator, as this will affect the quality of the flattened path.
 */
@property (nonatomic,readonly) AJRPathEnumerator *pathEnumerator;

/*!
 Add the path to the supplied context, including the receivers path settings, such as line width, line cap, etc...
 
 @param context The graphics context into which the path should be added.
 */
- (void)addPathToContext:(CGContextRef)context;

/*!
 Builds and returns a CGPath based on the receiver. This is useful for interoperating with some of the underlying CoreGraphics libraries.
 */
@property (nonatomic,readonly) CGPathRef CGPath;

/*!
 Returns a path that when filled, strokes the receiver as if [self stroke] had been called. Note that the returned path is really not useful for anything other than filling or hit testing.
 
 @return A bezier path useful for filling or hit testing the receivers stroke.
 */
- (NSBezierPath *)bezierPathFromStrokedPath;

/*!
 Returns a new bezier path created from the supplied CGPath.

 This basically just creates an empty path and then calls `-[NSBezierPath appendBezierPathWithCGPath:]`.

 @param path The CoreGraphic's CGPath.

 @return The newly created NSBezierPath.
 */
+ (NSBezierPath *)bezierPathWithCGPath:(CGPathRef)path;

/*!
 Appends `path` to the receiver.

 @param path The path to append.
 */
- (void)appendBezierPathWithCGPath:(CGPathRef)path;

- (NSBezierPath *)pathByUnioningWithPath:(id <AJRBezierPathProtocol>)path NS_SWIFT_NAME(unioning(with:));
- (NSBezierPath *)pathByIntersectingWithPath:(id <AJRBezierPathProtocol>)path NS_SWIFT_NAME(intersecting(with:));
- (NSBezierPath *)pathBySubtractingPath:(id <AJRBezierPathProtocol>)path NS_SWIFT_NAME(subtracting(with:));
- (NSBezierPath *)pathByExclusivelyIntersectingPath:(id <AJRBezierPathProtocol>)path NS_SWIFT_NAME(exclusivelyIntersecting(with:));

- (NSBezierPath *)pathByNormalizingPath;
@property (nonatomic,readonly) NSArray<NSBezierPath *> *separateComponents;

@end

NS_ASSUME_NONNULL_END
