//
//  AJRReportString.m
//  AJRInterface
//
//  Created by A.J. Raftis on 12/19/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRReportString.h"

#import "AJRReportView.h"
#import "DOMNode+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSObject+Extensions.h>
#import <AJRFoundation/NSString+Extensions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>

@implementation AJRReportString

+ (void)load
{
    [AJRReportElement registerReportElement:self forName:@"string"];
}

- (void)apply
{
    NSString        *key = [[_node attributeForName:@"value"] stringValue];
    
    if (key) {
        id                    value = nil;
        NSMutableArray        *text;
        NSString            *numberFormat = [[_node attributeForName:@"numberformat"] stringValue];
        NSNumberFormatter    *numberFormatter = nil;
        NSString            *dateFormat = [[_node attributeForName:@"dateformat"] stringValue];
        NSDateFormatter        *dateFormatter = nil;
        NSString            *formatterKey = [[_node attributeForName:@"format"] stringValue];
        NSFormatter            *formatter = nil;
        NSString            *escapeHTMLString = [[_node attributeForName:@"escapeHTML"] stringValue];
        NSUInteger            index;
        NSXMLElement        *parent = (NSXMLElement *)[_node parent];
        BOOL                escapeHTML = YES;

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
