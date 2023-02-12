/*
 AJRReportRepetition.m
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

#import "AJRReportRepetition.h"

#import "AJRReportView.h"
#import "DOMNode+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>

@implementation AJRReportRepetition

+ (void)load {
    [AJRReportElement registerReportElement:self forName:@"repetition"];
}


- (void)_iterateArray:(NSArray *)array {
    NSUInteger max = [array count];
    
    if (_sortOrderings) {
        array = [array sortedArrayUsingDescriptors:_sortOrderings];
    }
    
    for (_index = 0; _index < max; _index++) {
        id                object = [array objectAtIndex:_index];
        
        if (_indexName) {
            [[_reportView objects] setValue:[NSNumber numberWithUnsignedInteger:_index] forKey:_indexName];
        }
        if (_objectName) {
            [[_reportView objects] setValue:object forKey:_objectName];
        }
        
        for (NSUInteger x = 0; x < [_elements count]; x++) {
            NSXMLElement    *child = [_elements objectAtIndex:x];
            NSXMLElement    *clone = [child copy];
            
            if (_beforeNode) {
                NSInteger    index = [[_parent children] indexOfObjectIdenticalTo:_beforeNode];
                [_parent insertChild:clone atIndex:index];
            } else {
                [_parent addChild:clone];
            }
            [_reportView updateNode:clone];
        }
    }
}

- (void)_iterateDictionary:(NSDictionary *)dictionary {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *key in dictionary) {
        id object = [dictionary objectForKey:key];
        if ([object isKindOfClass:[NSDictionary class]]) {
            object = [object mutableCopy];
            [object setObject:key forKey:@"_key"];
        }
        [array addObject:object];
    }
    
    [self _iterateArray:array];

}

- (void)_buildSortOrderings:(NSString *)sort {
    NSArray *parts = [sort componentsSeparatedByString:@","];

    _sortOrderings = [[NSMutableArray alloc] init];
    for (NSString *part in parts) {
        NSRange range = [part rangeOfString:@":"];
        NSString *key, *order;
        NSSortDescriptor *descriptor;
        
        if (range.location == NSNotFound) {
            key = part;
            order = @"ajrc";
        } else {
            key = [part substringToIndex:range.location];
            order = [part substringFromIndex:range.location + range.length];
        }
        
        descriptor = [[NSSortDescriptor alloc] initWithKey:key 
                                                 ascending:[order isEqualToString:@"ajrc"]
                                                  selector:@selector(caseInsensitiveCompare:)];
        [_sortOrderings addObject:descriptor];
    }
}

- (void)apply {
    NSString *key = [[_node attributeForName:@"list"] stringValue];
    id rawValue;
    NSString *sort;

    _objectName = [[_node attributeForName:@"item"] stringValue];
    _indexName = [[_node attributeForName:@"index"] stringValue];
    if (key == nil) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"list\" from repetition element." userInfo:nil];
    }
    
    if (_objectName == nil) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"item\" from repetition element." userInfo:nil];
    }

    sort = [[_node attributeForName:@"sort"] stringValue];
    if (sort) {
        [self _buildSortOrderings:sort];
    }
    
    _list = [[_reportView objects] valueForKeyPath:key];
    _index = 0;
    _parent = (NSXMLElement *)[_node parent];
    _insertIndex = [[_parent children] indexOfObjectIdenticalTo:_node];
    if (_insertIndex + 1 < [[_parent children] count]) {
        _beforeNode = (NSXMLElement *)[[_parent children] objectAtIndex:_insertIndex + 1];
    }

    _elements = [[NSMutableArray alloc] initWithArray:[_node children] copyItems:YES];

    // Finally, we can remove the node from its parent.
    [_parent removeChildAtIndex:_insertIndex];
    
    rawValue = [[_reportView objects] valueForKeyPath:key];
    if ([rawValue isKindOfClass:[NSArray class]]) {
        [self _iterateArray:rawValue];
    } else if ([rawValue isKindOfClass:[NSDictionary class]]) {
        [self _iterateDictionary:rawValue];
    } else if (rawValue) {
        AJRPrintf(@"WARNING: Don't know how to iterate %C\n", rawValue);
    }
}

@end
