/*
AJRCollectionView.m
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

- (NSTimeInterval)__lastSearchTime {
    if (__lastSearchTime == 0.0) {
        __lastSearchTime = [[NSDate distantPast] timeIntervalSinceReferenceDate];
    }
    return __lastSearchTime;
}

- (void)_noteSearchTime {
    __lastSearchTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)_updateSearchForCharacter:(unichar)character {
    NSTimeInterval lastSearchTime = [self __lastSearchTime];
    NSString *searchString = [self searchString];
    NSIndexSet *indexes = nil;
    
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

- (void)keyDown:(NSEvent *)event {
    if ([event type] == NSEventTypeKeyDown) {
        NSString *key = [event charactersIgnoringModifiers];
        
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
