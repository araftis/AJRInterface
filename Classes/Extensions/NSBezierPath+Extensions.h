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
