/*
 NSPrintInfo+Extensions.m
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

#import "NSPrintInfo+Extensions.h"

#import "AJRPaper.h"
#import "NSPrinter+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

NSString *NSUnitsOfMeasure = @"NSUnitsOfMeasure";
NSPrintInfoAttributeKey const AJRIsPrintingKey = @"AJRIsPrinting";

NSString *AJRStringFromPaginationMode(NSPrintingPaginationMode mode) {
    switch (mode) {
        case NSPrintingPaginationModeAutomatic: return @"auto";
        case NSPrintingPaginationModeFit: return @"fit";
        case NSPrintingPaginationModeClip: return @"clip";
    }
    return @"auto";
}

NSPrintingPaginationMode AJRPaginationModeFromString(NSString *mode) {
    if ([mode isEqualToString:@"auto"]) return NSPrintingPaginationModeAutomatic;
    if ([mode isEqualToString:@"fit"]) return NSPrintingPaginationModeFit;
    if ([mode isEqualToString:@"clip"]) return NSPrintingPaginationModeClip;
    return NSPrintingPaginationModeAutomatic;
}

@interface AJRPrintInfoPlaceHolder : NSObject <AJRXMLDecoding>

@property (nullable,nonatomic,strong) NSString *paperName;
@property (nonatomic,assign) NSSize paperSize;
@property (nonatomic,assign) NSPaperOrientation orientation;
@property (nonatomic,assign) CGFloat scalingFactor;
@property (nonatomic,assign) CGFloat leftMargin;
@property (nonatomic,assign) CGFloat rightMargin;
@property (nonatomic,assign) CGFloat topMargin;
@property (nonatomic,assign) CGFloat bottomMargin;
@property (nonatomic,assign) BOOL horizontallyCentered;
@property (nonatomic,assign) BOOL verticallyCentered;
@property (nonatomic,assign) NSPrintingPaginationMode horizontalPagination;
@property (nonatomic,assign) NSPrintingPaginationMode verticalPagination;
@property (nonatomic,strong) NSString *printerName;

@end

@implementation NSPrintInfo (Extensions)

- (AJRPaper *)paper {
    return [self.printer.allPapers ajr_firstObjectPassingTest:^BOOL(AJRPaper * _Nonnull object) {
        return object.paperId == self.paperName;
    }];
}

- (void)setPaper:(AJRPaper *)paper {
    self.paperName = paper.paperId;
}

- (CGFloat)pointConversionFactor {
    NSString *conversion = [[self dictionary] objectForKey:NSUnitsOfMeasure];

    if (!conversion) return 72.0;

    if ([conversion isEqualToString:@"Inches"]) {
        return 72.0;
    } else if ([conversion isEqualToString:@"Centimeters"]) {
        return 72.0 / 2.54;
    } else if ([conversion isEqualToString:@"Points"]) {
        return 1.0;
    } else if ([conversion isEqualToString:@"Picas"]) {
        return 12.0;
    }

    return 72.0;
}

- (NSString *)measureAbbreviation {
    NSString *conversion = [[self dictionary] objectForKey:NSUnitsOfMeasure];

    if (!conversion) return @"\"";

    if ([conversion isEqualToString:@"Inches"]) {
        return @"\"";
    } else if ([conversion isEqualToString:@"Centimeters"]) {
        return @"cm.";
    } else if ([conversion isEqualToString:@"Points"]) {
        return @"pts.";
    } else if ([conversion isEqualToString:@"Picas"]) {
        return @"picas";
    }

    return @"\"";
}

- (CGFloat)pointsToMeasure:(CGFloat)points {
    return points / [self pointConversionFactor];
}

- (CGFloat)measureToPoints:(CGFloat)measure {
    return measure * [self pointConversionFactor];
}

- (NSString *)pointsAsMeasureString:(CGFloat)points {
    return [self pointsAsMeasureString:points places:3];
}

- (NSString *)pointsAsMeasureString:(CGFloat)points places:(NSInteger)places {
    return [NSString stringWithFormat:@"%1.*f %@", (int)places, [self pointsToMeasure:points], [self measureAbbreviation]];
}

- (NSString *)measureAsString:(CGFloat)measure {
    return [self measureAsString:measure places:3];;
}

- (NSString *)measureAsString:(CGFloat)measure places:(NSInteger)places {
    return [NSString stringWithFormat:@"%1.*f %@", (int)places, measure, [self measureAbbreviation]];
}

- (NSString *)unitsOfMeasure {
    NSString *value = [[self dictionary] objectForKey:NSUnitsOfMeasure];

    if (value == nil) return @"Inches";

    return value;
}

- (void)setUnitsOfMeasure:(NSString *)value {
    [[self dictionary] setObject:value forKey:NSUnitsOfMeasure];
}

- (void)setIsPrinting:(BOOL)isPrinting {
    if (isPrinting) {
        self.dictionary[AJRIsPrintingKey] = @YES;
    } else {
        self.dictionary[AJRIsPrintingKey] = nil;
    }
}

- (BOOL)isPrinting {
    return [self.dictionary[AJRIsPrintingKey] boolValue];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRPrintInfoPlaceHolder alloc] init];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"printInfo";
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeString:self.paperName forKey:@"paperName"];
    [coder encodeSize:self.paperSize forKey:@"paperSize"];
    if (self.orientation != NSPaperOrientationPortrait) {
        [coder encodeString:self.orientation == NSPaperOrientationLandscape ? @"landscape" : @"portrait" forKey:@"orientation"];
    }
    if (self.scalingFactor != 1.0) {
        [coder encodeDouble:self.scalingFactor forKey:@"scale"];
    }
    [coder encodeDouble:self.leftMargin forKey:@"leftMargin"];
    [coder encodeDouble:self.rightMargin forKey:@"rightMargin"];
    [coder encodeDouble:self.topMargin forKey:@"topMargin"];
    [coder encodeDouble:self.bottomMargin forKey:@"bottomMargin"];
    if (!self.horizontallyCentered) {
        [coder encodeBool:self.horizontallyCentered forKey:@"horizontallyCentered"];
    }
    if (!self.verticallyCentered) {
        [coder encodeBool:self.verticallyCentered forKey:@"verticallyCentered"];
    }
    if (self.horizontalPagination != NSPrintingPaginationModeClip) {
        [coder encodeString:AJRStringFromPaginationMode(self.horizontalPagination) forKey:@"horizontalPagination"];
    }
    if (self.verticalPagination != NSPrintingPaginationModeAutomatic) {
        [coder encodeString:AJRStringFromPaginationMode(self.verticalPagination) forKey:@"verticalPagination"];
    }
    if ([[self.printer.name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] length] > 0) {
        [coder encodeString:self.printer.name forKey:@"printerName"];
    }
}

@end

@implementation  AJRPrintInfoPlaceHolder

- (id)init {
    if ((self = [super init])) {
        _paperName = NSPrintInfo.sharedPrintInfo.paperName;
        _paperSize = NSPrintInfo.sharedPrintInfo.paperSize;
        _orientation = NSPaperOrientationPortrait;
        _scalingFactor = 1.0;
        _leftMargin = 72.0;
        _rightMargin = 72.0;
        _topMargin = 1.25 * 72.0;
        _bottomMargin = 1.25 * 72.0;
        _horizontallyCentered = YES;
        _verticallyCentered = YES;
        _horizontalPagination = NSPrintingPaginationModeClip;
        _verticalPagination = NSPrintingPaginationModeAutomatic;
        _printerName = NSPrintInfo.sharedPrintInfo.printer.name;
    }
    return self;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"paperName" setter:^(NSString * _Nonnull string) {
        self->_paperName = string;
    }];
    [coder decodeSizeForKey:@"paperSize" setter:^(CGSize size) {
        self->_paperSize = size;
    }];
    [coder decodeStringForKey:@"orientation" setter:^(NSString * _Nonnull string) {
        self->_orientation = [string isEqualToString:@"landscape"] ? NSPaperOrientationLandscape : NSPaperOrientationPortrait;
    }];
    [coder decodeDoubleForKey:@"scale" setter:^(double value) {
        self->_scalingFactor = value;
    }];
    [coder decodeDoubleForKey:@"leftMargin" setter:^(double value) {
        self->_leftMargin = value;
    }];
    [coder decodeDoubleForKey:@"rightMargin" setter:^(double value) {
        self->_rightMargin = value;
    }];
    [coder decodeDoubleForKey:@"topMargin" setter:^(double value) {
        self->_topMargin = value;
    }];
    [coder decodeDoubleForKey:@"bottomMargin" setter:^(double value) {
        self->_bottomMargin = value;
    }];
    [coder decodeBoolForKey:@"verticallyCentered" setter:^(BOOL value) {
        self->_verticallyCentered = value;
    }];
    [coder decodeBoolForKey:@"horizontallyCentered" setter:^(BOOL value) {
        self->_horizontallyCentered = value;
    }];
    [coder decodeStringForKey:@"horizontalPagination" setter:^(NSString * _Nonnull string) {
        self->_horizontalPagination = AJRPaginationModeFromString(string);
    }];
    [coder decodeStringForKey:@"verticalPagination" setter:^(NSString * _Nonnull string) {
        self->_verticalPagination = AJRPaginationModeFromString(string);
    }];
    [coder decodeStringForKey:@"printerName" setter:^(NSString * _Nonnull string) {
        self->_printerName = string;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    NSPrintInfo *printInfo = [[NSPrintInfo sharedPrintInfo] copy];
    printInfo.paperName = _paperName;
    printInfo.paperSize = _paperSize;
    printInfo.orientation = _orientation;
    printInfo.scalingFactor = _scalingFactor;
    printInfo.leftMargin = _leftMargin;
    printInfo.rightMargin = _rightMargin;
    printInfo.topMargin = _topMargin;
    printInfo.bottomMargin = _bottomMargin;
    printInfo.verticallyCentered = _verticallyCentered;
    printInfo.horizontallyCentered = _horizontallyCentered;
    printInfo.verticalPagination = _verticalPagination;
    printInfo.horizontalPagination = _horizontalPagination;
    NSPrinter *possible = [NSPrinter printerWithName:_printerName];
    if (possible) {
        printInfo.printer = possible;
    }
    return printInfo;
}

@end
