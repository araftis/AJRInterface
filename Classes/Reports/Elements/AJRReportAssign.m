
#import "AJRReportAssign.h"

#import "AJRReportView.h"

#import <AJRFoundation/NSString+Extensions.h>

@implementation AJRReportAssign

+ (void)load {
    [AJRReportElement registerReportElement:self forName:@"assign"];
}

- (void)apply {
    NSString *key = [[_node attributeForName:@"key"] stringValue];
    NSString *valueKey = [[_node attributeForName:@"valueKey"] stringValue];
    NSString *rawValue = [[_node attributeForName:@"value"] stringValue];
    NSString *type = [[_node attributeForName:@"type"] stringValue];
    id value;
    
    if (key == nil) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"key\" from assign element." userInfo:nil];
    }

    if (valueKey) {
        value = [[_reportView objects] valueForKeyPath:valueKey];
    } else {
        if (type == nil) {
            value = rawValue;
        } else if ([type isEqualToString:@"string"]) {
            value = rawValue;
        } else if ([type isEqualToString:@"short"]) {
            value = [NSNumber numberWithShort:[value integerValue]];
        } else if ([type isEqualToString:@"integer"]) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        } else if ([type isEqualToString:@"long"]) {
            value = [NSNumber numberWithLong:[value longValue]];
        } else if ([type isEqualToString:@"long long"]) {
            value = [NSNumber numberWithLongLong:[value longLongValue]];
        } else if ([type isEqualToString:@"float"]) {
            value = [NSNumber numberWithFloat:[value floatValue]];
        } else if ([type isEqualToString:@"double"]) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } else if ([type isEqualToString:@"bool"]) {
            value = [NSNumber numberWithBool:[value boolValue]];
        } else if ([type isEqualToString:@"date"]) {
        }
    }

    [[_reportView objects] setValue:value forKey:key];
}

@end
