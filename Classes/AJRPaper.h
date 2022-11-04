//
//  AJRPaper.h
//  AJRInterface
//
//  Created by AJ Raftis on 11/4/22.
//

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRPaper : NSObject

+ (instancetype)paperForSize:(NSSize)size;

@property (nonatomic,class,readonly) NSArray<AJRPaper *> *customPapers;
@property (nonatomic,class,readonly) NSArray<AJRPaper *> *allGenericPapers;

+ (nullable AJRPaper *)paperForPaperId:(NSString *)paperId;

@property (nonatomic,readonly) NSString *paperId;
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
