
#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRFoundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *NSUnitsOfMeasure;

extern NSString *AJRStringFromPaginationMode(NSPrintingPaginationMode mode);
extern NSPrintingPaginationMode AJRPaginationModeFromString(NSString *mode);

    @interface AJRPaper : NSObject

+ (instancetype)paperForSize:(NSSize)size;

@property (nonatomic,strong) NSString *name;
@property (nonatomic,readonly) NSString *localizedName;
@property (nonatomic,assign) NSSize size;

- (NSSize)sizeForOrientation:(NSPaperOrientation)orientation;

@end

@interface NSPrintInfo (Extensions) <AJRXMLCoding>

// Maping coordinates to units and visa-versa
- (CGFloat)pointsToMeasure:(CGFloat)points;
- (CGFloat)measureToPoints:(CGFloat)measure;
- (NSString *)pointsAsMeasureString:(CGFloat)points;
- (NSString *)pointsAsMeasureString:(CGFloat)points places:(NSInteger)places;
- (NSString *)measureAsString:(CGFloat)measure;
- (NSString *)measureAsString:(CGFloat)measure places:(NSInteger)places;

@property (nonatomic,strong) NSString *unitsOfMeasure;

+ (NSArray<AJRPaper *> *)allPapers;

@end

NS_ASSUME_NONNULL_END
