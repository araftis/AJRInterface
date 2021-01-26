//
//  AJRProductController.h
//  AJRInterface
//
//  Created by Alex Raftis on 11/15/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJREnvironment, AJRMarketingContext, AJRQualifier;

const extern NSUInteger AJRDefaultFetchLimit;
const extern NSUInteger AJRNoFetchLimit;

@interface AJRProductController : NSTreeController <NSCoding>
{
    AJREnvironment        *_environment;
    AJRMarketingContext    *_marketingContext;
    AJRQualifier            *_searchQualifier;
    NSString            *_activeSearchID;
    NSString            *_entityName;
    NSUInteger            _fetchLimit;
    NSMutableSet        *_validPartNumbers;
}

@property (nonatomic,retain) AJREnvironment *environment;
@property (nonatomic,retain) AJRMarketingContext *marketingContext;
@property (nonatomic,retain) NSString *entityName;
@property (nonatomic,assign) NSUInteger fetchLimit;

- (void)searchForString:(NSString *)searchString;
- (void)search:(AJRQualifier *)qualifier;

- (IBAction)takeSearchStringFrom:(id)sender;
- (IBAction)takeQualifierFrom:(id)sender;

@end
