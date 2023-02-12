/*
 AJREnvironmentController.m
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
