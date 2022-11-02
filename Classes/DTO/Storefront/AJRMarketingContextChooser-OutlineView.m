/*
 AJRMarketingContextChooser-OutlineView.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import <AJRInterface/AJRMarketingContextChooser.h>

#import <AJRFoundation/AJRFoundation.h>
#import <Log4Cocoa/Log4Cocoa.h>

@implementation AJRMarketingContextChooser (OutlineView)

#pragma mark NSOutlineDataSource

- (void)_getButton:(NSButton **)button rootNode:(AJRNode **)node andNodes:(NSArray **)nodes forOutlineView:(NSOutlineView *)outlineView
{
    if (outlineView == _segmentTable) {
        *button = _segmentToggle;
        *node = [[self storefrontService] segmentForCode:@"all"];
        *nodes = _segments;
    } else if (outlineView == _geoTable) {
        *button = _geoToggle;
        *node = [[self storefrontService] geoForCode:@"ww"];
        *nodes = _geos;
    } else if (outlineView == _languageTable) {
        *button = _languageToggle;
        *node = [[self storefrontService] languageForCode:@"any"];
        *nodes = _languages;
    } else if (outlineView == _channelTable) {
        *button = _channelToggle;
        *node = [[self storefrontService] channelForCode:@"common"];
        *nodes = _channels;
    } else {
        *button = nil;
        *nodes = nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    NSButton        *button;
    AJRNode            *node;
    NSArray            *nodes;
    
    [self _getButton:&button rootNode:&node andNodes:&nodes forOutlineView:outlineView];
    
    if ([button state]) {
        if (item == nil) return YES;
        return [[item children] count] != 0;
    }
    
    if (item == nil) return YES;
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSButton        *button;
    AJRNode            *node;
    NSArray            *nodes;
    
    [self _getButton:&button rootNode:&node andNodes:&nodes forOutlineView:outlineView];
    
    if ([button state]) {
        if (item == nil) {
            return 1;
        }
        return [[item children] count];
    }
    
    if (item == nil) return [nodes count];
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    NSButton        *button;
    AJRNode            *node;
    NSArray            *nodes;
    
    [self _getButton:&button rootNode:&node andNodes:&nodes forOutlineView:outlineView];
    
    if ([button state]) {
        if (item == nil) {
            return node;
        }
        return [[item children] objectAtIndex:index];
    }
    
    if (item == nil) {
        return [nodes objectAtIndex:index];
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSButton        *button;
    AJRNode            *node;
    NSArray            *nodes;
    
    [self _getButton:&button rootNode:&node andNodes:&nodes forOutlineView:outlineView];
    
    if ([[item key] isEqualToString:@"all"]) {
        return AJRFormat(@"All (%d segments)", [nodes count]);
    } else if ([[item key] isEqualToString:@"ww"]) {
        return AJRFormat(@"World Wide (%d geos)", [nodes count]);
    } else if ([[item key] isEqualToString:@"any"]) {
        return AJRFormat(@"Any (%d languages)", [nodes count]);
    } else if ([[item key] isEqualToString:@"common"]) {
        return AJRFormat(@"Common (%d channels)", [nodes count]);
    }
    
    return [item displayString];
}

#pragma mark NSTableViewDelegate

- (NSIndexSet *)tableView:(NSTableView *)tableView rowsForSearchString:(NSString *)searchString
{
    NSButton            *button;
    AJRNode                *node;
    NSArray                *nodes;
    NSMutableIndexSet    *indexes = [[NSMutableIndexSet alloc] init];
    
    [self _getButton:&button rootNode:&node andNodes:&nodes forOutlineView:(NSOutlineView *)tableView];
    
    for (AJRNode *node in nodes) {
        NSString    *key = [node key];
        NSString    *displayString = [node displayString];
        
        if ([key caseInsensitiveCompare:searchString] == NSOrderedSame ||
            [displayString caseInsensitiveCompare:searchString] == NSOrderedSame) {
            NSUInteger    row = [(NSOutlineView *)tableView rowForItem:node];
            
            if (row != NSNotFound) {
                [indexes removeAllIndexes];
                [indexes addIndex:[(NSOutlineView *)tableView rowForItem:node]];
                log4Debug(@"exact match %@ in %@", searchString, node);
                break;
            }
        }
        if ([key hasCaseInsensitivePrefix:searchString] || [displayString hasCaseInsensitivePrefix:searchString]) {
            NSUInteger    row = [(NSOutlineView *)tableView rowForItem:node];
            if (row != NSNotFound) {
                log4Debug(@"match %@ in %@", searchString, node);
                [indexes addIndex:row];
            }
        }
    }
    
    return [indexes autorelease];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
    [[outlineView window] makeFirstResponder:outlineView];
    return NO;
}

@end
