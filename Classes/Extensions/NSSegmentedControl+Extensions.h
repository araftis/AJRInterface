
#import <Cocoa/Cocoa.h>

@class MMTranslator;

@interface NSSegmentedControl (AJRInterfaceExtensions)

- (void)translateWithTranslator:(MMTranslator *)translator;

@end
