//
//  NSColor+Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/15/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

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
