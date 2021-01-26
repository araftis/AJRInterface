//
//  AJREnvironmentController.m
//  AJRInterface
//
//  Created by Alex Raftis on 11/14/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJREnvironmentController.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJREnvironmentController

- (void)_setup
{
    if (_environmentName == nil) {
        _environmentName = [@"Development" retain];
    }
    [self setAutomaticallyPreparesContent:YES];
    [self setEntityName:@"AJREnvironment"];
}

- (id)init
{
    if ((self = [super init])) {
        [self _setup];
    }
    return self;
}

- (void)dealloc
{
    [_environmentName release];
    
    [super dealloc];
}

- (void)setEnvironment:(AJREnvironment *)environment
{
    [_environmentName release];
    _environmentName = [[environment name] retain];
    [self setSelectedObjects:[NSArray arrayWithObject:environment]];
}

- (AJREnvironment *)environment
{
    AJREnvironment    *environment = [[self selectedObjects] lastObject];
    
    if (environment == nil && _environmentName != nil) {
        environment = [AJREnvironment environmentForName:_environmentName];
        if (environment != nil) {
            [self setEnvironment:environment];
        }
    }
    
    return environment;
}

- (void)setContent:(id)content
{
    if ([content isKindOfClass:[AJREnvironment class]]) {
        [super setContent:[NSArray arrayWithObject:content]];
    } else if ([content isKindOfClass:[NSArray class]]) {
        NSMutableArray    *newContent = [NSMutableArray array];
        for (id object in content) {
            if ([object isKindOfClass:[AJREnvironment class]]) {
                [newContent addObject:object];
            }
        }
        [super setContent:newContent];
    } else {
        [super setContent:[NSArray array]];
    }
}

- (void)prepareContent
{
    [self setContent:[AJREnvironment environments]];
    if (_environmentName) {
        AJREnvironment    *environment = [AJREnvironment environmentForName:_environmentName];
        if (environment) {
            [self setSelectedObjects:[NSArray arrayWithObject:environment]];
        }
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        _environmentName = [[coder decodeObjectForKey:@"selectedEnvironment"] retain];
        [self _setup];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_environmentName forKey:@"selectedEnvironment"];
}

@end
