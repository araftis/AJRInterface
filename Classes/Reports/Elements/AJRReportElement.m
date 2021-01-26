//
//  AJRReportElement.m
//  AJRInterface
//
//  Created by A.J. Raftis on 12/19/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRReportElement.h"

#import <AJRFoundation/NSString+Extensions.h>

static NSMutableDictionary    *_elements = nil;

@implementation AJRReportElement

+ (void)initialize
{
    if (_elements == nil) {
        _elements = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerReportElement:(Class)element forName:(NSString *)name
{
    [_elements setObject:element forKey:name];
}

+ (Class)nodeClassForNode:(NSXMLElement *)node
{
    NSString    *name = [node name];
    NSString    *elementName = nil;
    
    if ([name hasCaseInsensitivePrefix:@"as:"]) {
        elementName = [[name substringFromIndex:3] lowercaseString];
    } else if ([name caseInsensitiveCompare:@"as"] == NSOrderedSame) {
        elementName = [[node attributeForName:@"name"] stringValue];
    }

    if (elementName) {
        return [_elements objectForKey:elementName];
    }
    
    return Nil;
}

+ (id)elementForNode:(NSXMLElement *)node inReportView:(AJRReportView *)reportView
{
    Class    class = [self nodeClassForNode:node];
    
    return [[class alloc] initWithNode:node inReportView:reportView];
}

- (id)initWithNode:(NSXMLElement *)node inReportView:(AJRReportView *)reportView
{
    if ((self = [super init])) {
        Class        class = [[self class] nodeClassForNode:node];
        if ([self class] != class) {
            return [[class alloc] initWithNode:node inReportView:reportView];
        }
        _reportView = reportView;
        _node = node;
    }
    return self;
}


- (void)apply
{
}

- (void)cleanup
{
}

- (NSUInteger)hash
{
    return [[NSValue valueWithPointer:(__bridge const void *)(self)] hash];
}

- (BOOL)isEqual:(id)other
{
    return other == self;
}

@end
