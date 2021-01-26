//
//  AJRArrayController.m
//  AJRInterface
//
//  Created by Alex Raftis on 7/7/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import "AJRArrayController.h"

#import <AJRFoundation/AJRFormat.h>

@interface _AJRArrayControllerContainer : NSObject
{
    NSString        *_keyPath;
    id                _object;
    NSDictionary    *_change;
    void            *_context;
}

- (id)initWithKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary *)change context:(void *)context;

@property (nonatomic,retain) NSString *keyPath;
@property (nonatomic,retain) id object;
@property (nonatomic,retain) NSDictionary *change;
@property (nonatomic,assign) void *context;

@end

@implementation _AJRArrayControllerContainer

- (id)initWithKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ((self = [super init])) {
        self.keyPath = keyPath;
        self.object = object;
        self.change = change;
        self.context = context;
    }
    return self;
}

- (void)dealloc
{
    [_keyPath release];
    [_object release];
    [_change release];
    
    [super dealloc];
}

@synthesize keyPath = _keyPath;
@synthesize object = _object;
@synthesize change = _change;
@synthesize context = _context;

@end


@implementation AJRArrayController

#pragma mark Initialization

- (id)init
{
    if ((self = [super init])) {
        _observedKeyPathsQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    @synchronized (_observedKeyPathsQueue) {
        [_observedKeyPathsQueue release]; _observedKeyPathsQueue = nil;
    }

    [super dealloc];
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([NSThread isMainThread]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        @synchronized (_observedKeyPathsQueue) {
             // If the count is zero, we schedule the main thread to process the observations
            BOOL                        schedule = [_observedKeyPathsQueue count] == 0;
            _AJRArrayControllerContainer    *container;
            
            container = [[_AJRArrayControllerContainer alloc] initWithKeyPath:keyPath object:object change:change context:context];
            [_observedKeyPathsQueue addObject:container];
            [container release];
            
            if (schedule) {
                [self performSelectorOnMainThread:@selector(_processThreadedObservations) withObject:nil waitUntilDone:NO];
            }
        }
    }
}

#pragma mark Processing

- (void)_processThreadedObservations
{
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:AJRFormat(@"Attempt to call %s on something other than the main thread.", __PRETTY_FUNCTION__) userInfo:nil];
    }
    
    @synchronized (_observedKeyPathsQueue) {
        // Process the key paths in the order they were received. This isn't 100%, but it at least
        // means that the object's that post the observer noticiations only have to make sure the
        // will/did changes happen on the same thread.
        for (_AJRArrayControllerContainer *container in _observedKeyPathsQueue) {
            [self observeValueForKeyPath:[container keyPath]
                                ofObject:[container object]
                                  change:[container change]
                                 context:[container context]];
        }
        // Once we've processed, clear the main queue.
        [_observedKeyPathsQueue removeAllObjects];
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        _observedKeyPathsQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
