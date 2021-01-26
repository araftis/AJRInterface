//
//  AJRReportRepetition.m
//  AJRInterface
//
//  Created by A.J. Raftis on 12/19/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRReportRepetition.h"

#import "AJRReportView.h"
#import "DOMNode+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>

@implementation AJRReportRepetition

+ (void)load
{
    [AJRReportElement registerReportElement:self forName:@"repetition"];
}


- (void)_iterateArray:(NSArray *)array
{
    NSUInteger    max = [array count];
    
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

- (void)_iterateDictionary:(NSDictionary *)dictionary
{
    NSMutableArray    *array = [[NSMutableArray alloc] init];
    
    for (NSString *key in dictionary) {
        id        object = [dictionary objectForKey:key];
        if ([object isKindOfClass:[NSDictionary class]]) {
            object = [object mutableCopy];
            [object setObject:key forKey:@"_key"];
        }
        [array addObject:object];
    }
    
    [self _iterateArray:array];

}

- (void)_buildSortOrderings:(NSString *)sort
{
    NSArray    *parts = [sort componentsSeparatedByString:@","];
    
    _sortOrderings = [[NSMutableArray alloc] init];
    for (NSString *part in parts) {
        NSRange                range = [part rangeOfString:@":"];
        NSString            *key, *order;
        NSSortDescriptor    *descriptor;
        
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

- (void)apply
{
    NSString    *key = [[_node attributeForName:@"list"] stringValue];
    id            rawValue;
    NSString    *sort;

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
