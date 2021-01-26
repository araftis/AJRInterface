//
//  AJRCollectionView.m
//  AJRInterface
//
//  Created by A.J. Raftis on 2/11/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRCollectionView.h"

#import <AJRFoundation/AJRFoundation.h>

@interface NSCollectionView (AJRPrivate)
- (void)_sendDelayedAction;
@end

@implementation AJRCollectionView

@synthesize searchString = _searchString;
#if !defined(MAC_OS_X_VERSION_10_5) || MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5
@synthesize delegate = _delegate;
#endif

- (NSTimeInterval)__lastSearchTime
{
    if (__lastSearchTime == 0.0) {
        __lastSearchTime = [[NSDate distantPast] timeIntervalSinceReferenceDate];
    }
    return __lastSearchTime;
}

- (void)_noteSearchTime
{
    __lastSearchTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)_updateSearchForCharacter:(unichar)character
{
    NSTimeInterval    lastSearchTime = [self __lastSearchTime];
    NSString        *searchString = [self searchString];
    NSIndexSet        *indexes = nil;
    
    AJRPrintf(@"DEBUG: search (%.1f): %@", [NSDate timeIntervalSinceReferenceDate] - lastSearchTime, searchString);
    
    if ([NSDate timeIntervalSinceReferenceDate] - lastSearchTime >= 1.0) {
        searchString = AJRFormat(@"%lc", character);
    } else {
        searchString = AJRFormat(@"%@%lc", searchString ? searchString : @"", character);
    }
    
    if ([searchString length]) {
        [self setSearchString:searchString];
        indexes = [(id)[self delegate] collectionView:self indexesForSearchString:searchString];
        AJRPrintf(@"DEBUG: rows = %@", indexes);
    } else {
        [self setSearchString:nil];
    }
    
    [self _noteSearchTime];
    
    if ([indexes count] > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_sendDelayedAction) object:nil];
        if ([self allowsMultipleSelection]) {
            [self setSelectionIndexes:indexes];
        } else {
            [self setSelectionIndexes:[NSIndexSet indexSetWithIndex:[indexes firstIndex]]];
        }
    }
}

- (void)keyDown:(NSEvent *)event
{
    if ([event type] == NSEventTypeKeyDown) {
        NSString    *key = [event charactersIgnoringModifiers];
        
        if ([key isEqualToString:@"\t"]) {
            [[self window] selectNextKeyView:self];
        } else if ([key length] > 0 && [key characterAtIndex:0] == 0x19) {
            [[self window] selectPreviousKeyView:self];
            return;
        }
    }
    [super keyDown:event];
}

@end
