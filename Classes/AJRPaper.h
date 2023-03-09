/*
 AJRPaper.h
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

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *AJRPaperId NS_TYPED_EXTENSIBLE_ENUM;

extern const AJRPaperId AJRPaperIdA3 NS_SWIFT_NAME(a3);
extern const AJRPaperId AJRPaperIdA4 NS_SWIFT_NAME(a4);
extern const AJRPaperId AJRPaperIdA5 NS_SWIFT_NAME(a5);
extern const AJRPaperId AJRPaperIdB5 NS_SWIFT_NAME(b5);
extern const AJRPaperId AJRPaperIdEnvelope;
extern const AJRPaperId AJRPaperIdISODesignated;
extern const AJRPaperId AJRPaperIdJISB5;
extern const AJRPaperId AJRPaperIdSuperB;
extern const AJRPaperId AJRPaperIdTabloid;
extern const AJRPaperId AJRPaperIdArchB;
extern const AJRPaperId AJRPaperIdLegal;
extern const AJRPaperId AJRPaperIdLetter;

@interface AJRPaper : NSObject <AJRXMLCoding>

+ (instancetype)paperForSize:(NSSize)size;

@property (nonatomic,class,readonly) NSArray<AJRPaper *> *customPapers;
@property (nonatomic,class,readonly) NSArray<AJRPaper *> *allGenericPapers;

+ (nullable AJRPaper *)paperForPaperId:(AJRPaperId)paperId;

@property (nonatomic,readonly) AJRPaperId paperId;
@property (nonatomic,readonly) NSString *name;
@property (nonatomic,readonly) NSString *localizedName;
@property (nonatomic,readonly) NSSize size;
@property (nonatomic,readonly) AJRInset margins;

- (NSSize)sizeForOrientation:(NSPaperOrientation)orientation;

@end


@interface NSPrinter (AJRPaperExtensions)

+ (NSArray<AJRPaper *> *)allPapersForPrinter:(nullable NSPrinter *)printer;
- (NSArray<AJRPaper *> *)allPapers;

@end

NS_ASSUME_NONNULL_END
