/*
AJRProductController.m
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
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
//  AJRProductController.m
//  AJRInterface
//
//  Created by Alex Raftis on 11/15/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRProductController.h"

#import <AJRFoundation/AJRFoundation.h>
#import <Log4Cocoa/Log4Cocoa.h>

const NSUInteger AJRDefaultFetchLimit = 200;
const NSUInteger AJRNoFetchLimit = NSNotFound;

@implementation AJRProductController

- (id)init
{
    if ((self = [super init])) {
        [self setChildrenKeyPath:@"children"];
        [self setEntityName:@"Product"];
        [self setFetchLimit:AJRDefaultFetchLimit];
    }
    return self;
}

- (void)dealloc
{
    [_environment release];
    [_searchQualifier release];
    [_activeSearchID release];
    [_entityName release];
    [_marketingContext release];
    [_validPartNumbers release];
    
    [super dealloc];
}

@synthesize environment = _environment;
@synthesize marketingContext = _marketingContext;
@synthesize entityName = _entityName;
@synthesize fetchLimit = _fetchLimit;

- (void)setMarketingContext:(AJRMarketingContext *)marketingContext
{
    if (_marketingContext != marketingContext) {
        [_marketingContext release];
        _marketingContext = [marketingContext retain];
        @synchronized (self) {
            [_validPartNumbers release]; _validPartNumbers = nil;
        }
    }
}

- (NSSet *)validPartNumbers
{
    NSArray        *newValidPartNumbers = nil;
    
    if (_validPartNumbers == nil && _marketingContext != nil) {
        newValidPartNumbers = [[self.environment productAssortmentService] getAssortmentPartNumbersForContext:_marketingContext];
    }

    if (newValidPartNumbers) {
        @synchronized (self) {
            [_validPartNumbers release];
            _validPartNumbers = [[NSMutableSet alloc] initWithArray:newValidPartNumbers];
        }
    }
    
    return _validPartNumbers;
}

- (void)_completeSearch:(NSDictionary *)parameters
{
    AJRQualifier        *qualifier = [[parameters objectForKey:@"qualifier"] retain];
    NSString        *searchID = [[parameters objectForKey:@"searchID"] retain];
    NSMutableArray    *tempResults = [[parameters objectForKey:@"searchResults"] mutableCopy];
    
    @try {
        @synchronized (self) {
            // We're only going to do the actually update if our search ID is
            // equal to the active search ID. That way, only the last search
            // entered by the user will actually be displayed.
            if ([searchID isEqualToString:_activeSearchID]) {
                NSMutableArray    *finalResults;
                NSSet            *validPartNumbers = [[self validPartNumbers] retain];
                
                //AJRProduct        *product;
                
                log4Debug(@"displaying search \"%@\" with ID %@", qualifier, searchID);
                
                // Get the sticky results out of the main list and into the top
                log4Debug(@"    arranging search results");
                // Not doing anything here for the moment, may never.
                
                log4Debug(@"    setting products in controller");
                if (validPartNumbers) {
                    finalResults = [[NSMutableArray alloc] init];
                    for (AJRProduct *product in tempResults) {
                        if ([validPartNumbers containsObject:[product partNumber]]) {
                            [finalResults addObject:product];
                        }
                    }
                } else {
                    finalResults = [tempResults retain];
                }
                [self setContent:finalResults];
                [finalResults release];
                
                // Not doing this for the moment. We should check our qualifier, see if we match against part numbers, and if we do, then see if we can find a product with that part number. If we can, then we should select it.
                //AJRPrintf(@"%@:    finding product in results\n", self);
                //product = [self findProduct:searchString inArray:_searchResults];
                
                // And since the search completed, we can clean up
                [_activeSearchID release]; _activeSearchID = nil;
            } else {
                log4Debug(@"discarding search \"%@\" with ID %@", qualifier, searchID);
            }
        }
    } @finally {
        [qualifier release];
        [searchID release];
        [tempResults release];
        [parameters release];
    }
}

- (void)_doSearch:(NSDictionary *)parameters
{
    NSAutoreleasePool    *pool = [[NSAutoreleasePool alloc] init];
    AJRQualifier            *qualifier = nil;
    NSString            *searchID = nil;
    NSArray                *tempResults = nil;
    NSMutableDictionary    *newParameters;
    
    newParameters = [parameters mutableCopy];
    [parameters release];
    qualifier = [[newParameters objectForKey:@"qualifier"] retain];
    searchID = [[newParameters objectForKey:@"searchID"] retain];
    
    @try {
        if (qualifier) {
            log4Info(@"search: %@", qualifier);
            
            tempResults = [[AJRProductFinder finderForEnvironment:self.environment] basicSearch:[qualifier description]];
            if (tempResults == nil) {
                tempResults = [NSArray array];
            }
            [newParameters setObject:tempResults forKey:@"searchResults"];
        }
        
        [self performSelectorOnMainThread:@selector(_completeSearch:) withObject:newParameters waitUntilDone:YES];
    } @catch (NSException *exception) {
        log4Warn(@"An exception occurred while doing a search: %@", exception);
    } @finally {
        [qualifier release];
        [searchID release];
        [pool drain];
    }
}

- (void)searchForString:(NSString *)searchString
{
    NSMutableArray    *qualifiers = [NSMutableArray array];
    
    if ([searchString length] == 0) {
        return;
    }
    
    [qualifiers addObject:[AJRKeyValueQualifier qualifierWithKey:@"partNumber" operation:AJRQualifierCaseInsensitiveLike value:[NSString stringWithFormat:@"%@*", searchString]]];
    [qualifiers addObject:[AJRKeyValueQualifier qualifierWithKey:@"name" operation:AJRQualifierCaseInsensitiveLike value:[NSString stringWithFormat:@"*%@*", searchString]]];
    [self search:[AJROrQualifier qualifierWithArray:qualifiers]];
}

- (void)search:(AJRQualifier *)qualifier
{
    @synchronized (self) {
        NSMutableDictionary        *parameters = [[NSMutableDictionary alloc] init];
        
        [_activeSearchID release];
        _activeSearchID = [[[NSProcessInfo processInfo] globallyUniqueString] retain];
        
        [parameters setValue:qualifier forKey:@"qualifier"];
        [parameters setValue:_activeSearchID forKey:@"searchID"];
        [parameters setValue:_entityName forKey:@"entityName"];
        [parameters setValue:[NSNumber numberWithUnsignedInteger:_fetchLimit] forKey:@"entityName"];
        [NSThread detachNewThreadSelector:@selector(_doSearch:) toTarget:self withObject:parameters];
    }
}

- (IBAction)takeSearchStringFrom:(id)sender
{
    [self searchForString:[sender stringValue]];
}

- (IBAction)takeQualifierFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(qualifier)]) {
        [self search:[sender qualifier]];
    } else if ([sender respondsToSelector:@selector(stringValue)]) {
        NSString    *raw = [sender stringValue];
        AJRQualifier    *qualifier = nil;
        
        @try {
            qualifier = [AJRQualifier qualifierWithQualifierFormat:raw];
            [self search:qualifier];
        } @catch (NSException *exception) {
            log4Error(@"Couldn't parse qualifier %@: %@", raw, exception);
        }
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        NSString    *environmentName = [coder decodeObjectForKey:@"environmentName"];
        if (environmentName) {
            self.environment = [AJREnvironment environmentForName:environmentName];
        } else {
            self.environment = [AJREnvironment environmentForName:@"Development"];
        }
        _searchQualifier = [[coder decodeObjectForKey:@"searchQualifier"] retain];
        _entityName = [[coder decodeObjectForKey:@"entityName"] retain];
        if (_entityName == nil) {
            _entityName = [@"Product" retain];
        }
        if ([coder containsValueForKey:@"fetchLimit"]) {
            _fetchLimit = [coder decodeIntegerForKey:@"fetchLimit"];
        } else {
            _fetchLimit = AJRDefaultFetchLimit;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:[self.environment name] forKey:@"environmentName"];
    [coder encodeObject:_searchQualifier forKey:@"searchQualifier"];
    [coder encodeObject:_entityName forKey:@"entityName"];
    [coder encodeInteger:_fetchLimit forKey:@"fetchLimit"];
}

@end
