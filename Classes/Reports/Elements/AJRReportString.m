/*
AJRReportString.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "AJRReportString.h"

#import "AJRReportView.h"
#import "DOMNode+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSObject+Extensions.h>
#import <AJRFoundation/NSString+Extensions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>

@implementation AJRReportString

+ (void)load {
    [AJRReportElement registerReportElement:self forName:@"string"];
}

- (void)apply {
    NSString *key = [[_node attributeForName:@"value"] stringValue];
    
    if (key) {
        id value = nil;
        NSMutableArray *text;
        NSString *numberFormat = [[_node attributeForName:@"numberformat"] stringValue];
        NSNumberFormatter *numberFormatter = nil;
        NSString *dateFormat = [[_node attributeForName:@"dateformat"] stringValue];
        NSDateFormatter *dateFormatter = nil;
        NSString *formatterKey = [[_node attributeForName:@"format"] stringValue];
        NSFormatter *formatter = nil;
        NSString *escapeHTMLString = [[_node attributeForName:@"escapeHTML"] stringValue];
        NSUInteger index;
        NSXMLElement *parent = (NSXMLElement *)[_node parent];
        BOOL escapeHTML = YES;

        if (numberFormat) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setFormat:numberFormat];
            [numberFormatter setNotANumberSymbol:@"—"];
            [numberFormatter setPositiveInfinitySymbol:@"—"];
            [numberFormatter setNegativeInfinitySymbol:@"—"];
        }
        
        if (dateFormat) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:dateFormat];
        }
        
        if (escapeHTMLString) {
            escapeHTML = [escapeHTMLString boolValue];
        }
        
        if (formatterKey) {
            @try {
                formatter = [[_reportView objects] valueForKeyExpression:formatterKey];
            } @catch (NSException *exception) {
                AJRPrintf(@"Exception while evaluating \"%@\": %@", formatterKey, exception);
            }
        }

        @try {
            //value = [[_reportView objects] valueForKeyPath:key];
            value = [[_reportView objects] valueForKeyExpression:key];
            if (numberFormatter) {
                if ([value isKindOfClass:[NSString class]]) {
                    value = [NSNumber numberWithDouble:[value doubleValue]];
                }
                value = [numberFormatter stringForObjectValue:value];
            } else if (dateFormatter) {
                value = [dateFormatter stringForObjectValue:value];
            } else if (formatter) {
                value = [formatter stringForObjectValue:value];
            }
        } @catch (NSException *exception) {
            value = AJRFormat(@"*%@*", [exception description]);
        }
                
        if (value == nil) value = @"";
        value = [value description];
        text = [[NSMutableArray alloc] init];
        if (escapeHTML) {
            NSArray    *lines = [value componentsSeparatedByString:@"\n"];
            for (NSString *line in lines) {
                if ([text count]) {
                    [text addObject:[NSXMLElement elementWithName:@"br"]];
                }
                [text addObject:[NSXMLElement textWithStringValue:line]];
            }
        } else {
            // This may look like a pain in the ajrs, and it is, but this makes embedded HTML in strings work. Basically, we create a new, small document based on the string. Then, we take all of that document's children and make them children of our main document. Thus, all HTML markup should be copied into the new document in an appropriate manner.
            NSXMLNode        *element = [[NSXMLDocument alloc] initWithXMLString:AJRFormat(@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd\"><html><head></head><body>%@</body></html>", value) options:NSXMLDocumentTidyHTML error:NULL];
            NSArray            *elements;
            elements = [[[[[[element children] lastObject] children] objectAtIndex:1] children] mutableCopy];
            for (NSXMLNode *node in elements) {
                [node detach];
                [text addObject:node];
            }
        }
        
        index = [[parent children] indexOfObjectIdenticalTo:_node];
        if (index != NSNotFound) {
            [parent removeChildAtIndex:index];
            [parent insertChildren:text atIndex:index];
        } else {
            // Punt. This seems to fail from time to time.
            //[parent replaceChild:_node withNode:text];
        }
    }
}

@end
