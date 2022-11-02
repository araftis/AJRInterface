/*
 AJRReportAssign.m
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
