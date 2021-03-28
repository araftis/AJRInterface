
#import "AJRReportConditional.h"

#import "AJRReportView.h"
#import "DOMNode+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSObject+Extensions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>
#import <WebKit/WebKit.h>

@implementation AJRReportConditional

+ (void)load {
    [AJRReportElement registerReportElement:self forName:@"conditional"];
}

- (void)apply {
    NSString *key = [[_node attributeForName:@"condition"] stringValue];
    BOOL negate = [[[_node attributeForName:@"negate"] stringValue] boolValue];
    id value;
    BOOL isTrue = NO;
    
    if (key == nil) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"key\" from conditional element." userInfo:nil];
    }
    
    value = [[_reportView objects] valueForKeyExpression:key];
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            isTrue = [value boolValue];
        } else if (value == [NSNull null]) {
            isTrue = NO;
        } else {
            isTrue = YES;
        }
    }
    
    if (negate) {
        isTrue = !isTrue;
    }
    
    if (!isTrue) {
        [(NSXMLElement *)[_node parent] removeChild:_node];
    }
}

@end
