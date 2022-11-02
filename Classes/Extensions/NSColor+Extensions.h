/*
 NSColor+Extensions.h
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import <Cocoa/Cocoa.h>

#import <AJRFoundation/AJRXMLCoding.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor (AJRInterfaceExtensions) <AJRXMLCoding>

@property (class,nonatomic,readonly) NSColor *activeRegionColor;
@property (class,nonatomic,readonly) NSColor *regionColor;
@property (class,nonatomic,readonly) NSColor *assortmentIncludedColor;
@property (class,nonatomic,readonly) NSColor *assortmentExcludedColor;
@property (class,nonatomic,readonly) NSColor *assortmentMixedColor;
@property (class,nonatomic,readonly) NSColor *sourceBadgeColor;
@property (class,nonatomic,readonly) NSColor *sourceBadgeHighlightColor;
@property (class,nonatomic,readonly) NSColor *sourceBadgeTextColor;
@property (class,nonatomic,readonly) NSColor *sourceBadgeTextHighlightColor;
@property (class,nonatomic,readonly) NSColor *sourceActiveBackgroundColor;
@property (class,nonatomic,readonly) NSColor *sourceInactiveBackgroundColor;

@property (nonatomic,readonly) NSGradient *gradient;
@property (nonatomic,readonly) NSGradient *strongGradient;
- (NSGradient *)gradientWithSaturationWeight:(CGFloat)saturationWeight andBrightnessWeight:(CGFloat)brightnessWeight;

- (nullable NSColor *)colorByShiftingHue:(CGFloat)degreeDelta;
- (nullable NSColor *)colorByMultiplyingBrightness:(CGFloat)percent;
- (nullable NSColor *)colorByMultiplyingSaturation:(CGFloat)percent;
- (nullable NSColor *)colorByMultiplyingSaturation:(CGFloat)percent andBrightness:(CGFloat)brightnessPercent;

+ (nullable NSColor *)colorFromHTMLString:(NSString *)html;

@end

NS_ASSUME_NONNULL_END
