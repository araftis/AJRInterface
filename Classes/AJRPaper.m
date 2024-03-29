/*
 AJRPaper.m
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

#import "AJRPaper.h"

const AJRPaperId AJRPaperIdA3 = @"iso-a3";
const AJRPaperId AJRPaperIdA4 = @"iso-a4";
const AJRPaperId AJRPaperIdA5 = @"iso-a5";
const AJRPaperId AJRPaperIdB5 = @"iso-b5";
const AJRPaperId AJRPaperIdEnvelope = @"na-number-10-envelope";
const AJRPaperId AJRPaperIdISODesignated = @"iso-designated";
const AJRPaperId AJRPaperIdJISB5 = @"jis-b5";
const AJRPaperId AJRPaperIdSuperB = @"super-b";
const AJRPaperId AJRPaperIdTabloid = @"tabloid";
const AJRPaperId AJRPaperIdArchB = @"arch-b";
const AJRPaperId AJRPaperIdLegal = @"na-legal";
const AJRPaperId AJRPaperIdLetter = @"na-letter";

@interface AJRPaper ()

@property (nonatomic,strong) AJRPaperId paperId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *localizedName;
@property (nonatomic,assign) NSSize size;
@property (nonatomic,assign) AJRInset margins;

@end

@interface AJRPaperPlaceholder : NSObject <AJRXMLDecoding>

@property (nonatomic,strong) AJRPaperId paperId;

@end


@implementation AJRPaper

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self allGenericPapers];
    });
}

static NSArray<AJRPaper *> *customPapers;

+ (NSArray<AJRPaper *> *)customPapers {
    if (customPapers == nil) {
        NSUserDefaults *paperDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.print.custompapers"];
        if (paperDefaults == nil) {
            AJRLogWarning(@"Unable to open com.apple.print.custompapers. To get around this, you likely need to add \"com.apple.security.temporary-exception.shared-preference.read-only\" entitlement to your application. The value of this entitlement is an array of strings representing the domain names of the user defaults you want to access.");
        }
        [paperDefaults.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSDictionary *dictionary = AJRObjectIfKindOfClass(obj, NSDictionary);
            if (dictionary != nil) {
                // Let's see if this is a likely candidate for a custom paper size (we have to weed out all the unnecessary data).
                if (dictionary[@"printer"] != nil
                    && dictionary[@"left"] != nil
                    && dictionary[@"right"] != nil
                    && dictionary[@"top"] != nil
                    && dictionary[@"bottom"] != nil
                    && dictionary[@"width"] != nil
                    && dictionary[@"height"] != nil) {
                    AJRPaper *paper = [[AJRPaper alloc] init];
                    paper.name = dictionary[@"name"];
                    paper.size = NSMakeSize([dictionary[@"width"] floatValue], [dictionary[@"height"] floatValue]);
                    paper.margins = (AJRInset){
                        .left = [dictionary[@"left"] floatValue],
                        .right = [dictionary[@"right"] floatValue],
                        .top = [dictionary[@"top"] floatValue],
                        .bottom = [dictionary[@"bottom"] floatValue]
                    };
                }
            }
        }];
    }
    return customPapers;
}

static NSArray<AJRPaper *> *genericPapers = nil;

+ (NSArray<AJRPaper *> *)allGenericPapers {
    if (genericPapers == nil) {
        genericPapers = [NSPrinter allPapersForPrinter:nil];
    }
    return genericPapers;
}

+ (AJRPaper *)paperForSize:(NSSize)size {
    AJRPaper *paper;

    for (AJRPaper *paper in [NSPrinter allPapersForPrinter:nil]) {
        if ((paper.size.width == size.width && paper.size.height == size.height)
            || (paper.size.width == size.height && paper.size.height == size.width)) {
            return paper;
        }
    }

    paper = [[AJRPaper alloc] init];
    paper.name = @"Custom";
    paper.size = size;

    return paper;
}

static NSMutableDictionary<AJRPaperId, AJRPaper *> *papersByPaperId = nil;

+ (AJRPaper *)paperForPaperId:(AJRPaperId)paperId {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        papersByPaperId = [NSMutableDictionary dictionary];
    });
    return papersByPaperId[paperId];
}

+ (AJRPaper *)paperFromPMPaper:(PMPaper)paper onPrinter:(PMPrinter)printer {
    AJRPaper *newPaper = nil;
    CFStringRef paperName;

    CFStringRef cfPaperId;
    NSString *paperId;
    if (PMPaperGetID(paper, &cfPaperId) == kPMNoError) {
        paperId = (__bridge_transfer NSString *)cfPaperId;
    }

    if (paperId != nil) {
        newPaper = [self paperForPaperId:paperId];
    }

    if (newPaper == nil && PMPaperGetPPDPaperName(paper, &paperName) == kPMNoError) {
        newPaper = [[AJRPaper alloc] init];
        newPaper.name = (__bridge_transfer NSString *)paperName;
        newPaper.paperId = paperId ?: newPaper.name;

        double width, height;
        PMPaperGetWidth(paper, &width);
        PMPaperGetHeight(paper, &height);
        newPaper.size = (NSSize){width, height};

        CFStringRef localizedName;
        if (PMPaperCreateLocalizedName(paper, printer, &localizedName) == kPMNoError) {
            newPaper.localizedName = (NSString *)CFBridgingRelease(localizedName);
        } else {
            newPaper.localizedName = newPaper.name;
        }

        PMPaperMargins margins;
        if (PMPaperGetMargins(paper, &margins) == kPMNoError) {
            newPaper.margins = (AJRInset){
                .left = margins.left,
                .right = margins.right,
                .top = margins.top,
                .bottom = margins.bottom
            };
        }

        if (paperId != nil) {
            papersByPaperId[paperId] = newPaper;
        }
    }

    return newPaper;
}

- (NSSize)sizeForOrientation:(NSPaperOrientation)orientation {
    if (orientation == NSPaperOrientationPortrait) {
        return _size;
    }
    return (NSSize){_size.height, _size.width};
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p: %@ %@: %Z>", self, self, _paperId, _name, _size);
}

- (NSUInteger)hash {
    return [_paperId hash];
}

- (BOOL)isEqual:(id)object {
    return [self isEqualTo:object];
}

- (BOOL)isEqualTo:(id)object {
    AJRPaper *other = AJRObjectIfKindOfClass(object, AJRPaper);
    if (other != nil) {
        return [_paperId isEqualToString:other->_paperId];
    }
    return NO;
}

// MARK: - AJRXMLCoding

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRPaperPlaceholder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeString:_paperId forKey:@"paperId"];
}

@end


@implementation AJRPaperPlaceholder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"paperId" setter:^(NSString *string) {
        self->_paperId = string;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    return [AJRPaper paperForPaperId:_paperId];
}

@end


@implementation NSPrinter (AJRPaperExtensions)

+ (NSArray<AJRPaper *> *)allPapersForPrinter:(NSPrinter *)printerIn {
    PMPrinter printer = nil;
    NSMutableArray<AJRPaper *> *papers = [NSMutableArray array];

    OSStatus status;
    if (printerIn == nil || [printerIn.name isEqualToString:@" "]) {
        status = PMCreateGenericPrinter(&printer) != kPMNoError;
        if (status != kPMNoError) {
            AJRLogError(@"Failed to create a generic printer: %d", status);
        }
    } else {
        CFArrayRef cfPrinters;
        status = PMServerCreatePrinterList(kPMServerLocal, &cfPrinters);
        if (status == kPMNoError) {
            NSArray *printers = (__bridge NSArray *)cfPrinters;
            for (NSInteger x = 0; x < printers.count; x++) {
                PMPrinter searchPrinter = (__bridge PMPrinter)printers[x];
                NSString *name = (__bridge NSString *)PMPrinterGetName(searchPrinter);
                if ([name isEqualToString:printerIn.name]) {
                    PMRetain(searchPrinter);
                    printer = searchPrinter;
                    break;
                }
            }
            CFRelease(cfPrinters);
        }
        if (printer == nil) {
            AJRLogError(@"Failed to create printer \"%@\"", printerIn.name);
            status = PMCreateGenericPrinter(&printer) != kPMNoError;
            if (status != kPMNoError) {
                AJRLogError(@"Failed to create a generic printer: %d", status);
            }
        }
    }

    if (printer != nil) {
        CFArrayRef pageFormatList;
        if (PMSessionCreatePageFormatList([[NSPrintInfo sharedPrintInfo] PMPrintSession], printer, &pageFormatList) == kPMNoError) {
            for (NSInteger index = 0; index < CFArrayGetCount(pageFormatList); index++) {
                PMPageFormat currentPage = (PMPageFormat)CFArrayGetValueAtIndex(pageFormatList, index);
                PMPaper paper;
                if (PMGetPageFormatPaper(currentPage, &paper) == kPMNoError) {
                    AJRPaper *newPaper = [AJRPaper paperFromPMPaper:paper onPrinter:printer];
                    if (newPaper != nil) {
                        [papers addObject:newPaper];
                    }
                }
            }
        }
        PMRelease(printer);
    }
    [papers sortUsingComparator:^NSComparisonResult(AJRPaper *left, AJRPaper *right) {
        return [left.localizedName caseInsensitiveCompare:right.localizedName];
    }];

    return papers;
}

- (NSArray<AJRPaper *> *)allPapers {
    NSArray<AJRPaper *> *papers = objc_getAssociatedObject(self, _cmd);

    if (papers == nil) {
        papers = [[self class] allPapersForPrinter:self];
        objc_setAssociatedObject(self, _cmd, papers, OBJC_ASSOCIATION_RETAIN);
    }

    return papers;
}

@end
