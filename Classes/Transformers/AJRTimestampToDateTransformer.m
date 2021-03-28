
#import "AJRTimestampToDateTransformer.h"

#import <AJRFoundation/AJRFunctions.h>

@implementation AJRTimestampToDateTransformer

+ (void)load {
    AJRTimestampToDateTransformer *transformer = [[AJRTimestampToDateTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"TimestampToDateTransformer"];
}

+ (Class)transformedValueClass {
    return [NSDate class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    NSTimeInterval timestamp = 0.0;
    
    if (value == nil) return nil;
    
    // Attempt to get a reasonable value from the value object.
    if ([value respondsToSelector: @selector(doubleValue)]) {
        // handles NSString and NSNumber
        timestamp = [value doubleValue] / 1000.0;
    } else {
        [NSException raise: NSInternalInconsistencyException format: @"Value (%@) does not respond to -floatValue.", [value class]];
    }
    
    //AJRPrintf(@"%C: Transforming %@ (%f) to %@\n", self, value, timestamp, [NSDate dateWithTimeIntervalSince1970:1229026590]);// / 1000.0]);
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
    
}

- (id)reverseTransformedValue:(id)value {
    return [NSNumber numberWithDouble:[value timeIntervalSince1970] * 1000.0];
}

@end
