/*
 AJRMarketingContextChooser.m
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
//  AJRMarketingContextChooser.m
//  AJRInterface
//
//  Created by Alex Raftis on 10/9/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRMarketingContextChooser.h"

#import "AJRMCTablesViewP.h"

#import <AJRFoundation/AJRFoundation.h>
#import <Log4Cocoa/Log4Cocoa.h>

static AJRMarketingContextChooser    *chooser = nil;

const NSInteger AJRDefaultStorefrontFetchLimit = 200;

@interface NSCollectionView (Private)

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_6
#warning Be sure validate this method to make sure it's still valid past 10.6.
#endif
- (void)_scrollSelectionToVisible;

@end


@interface AJRMarketingContextChooser () 

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize;
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize initial:(BOOL)initial;

@end

#pragma mark Default Keys

NSString *AJRMarketingContextChooserShowDescendentStorefrontsKey = @"AJRMarketingContextChooser showDescendentStorefronts";
NSString *AJRMarketingContextChooserShowDisabledStorefrontsKey = @"AJRMarketingContextChooser showDisabledStorefronts";
NSString *AJRMarketingContextChooserShowCustomStorefrontsKey = @"AJRMarketingContextChooser showCustomStorefronts";
NSString *AJRMarketingContextChooserStorefrontsFilterKey = @"AJRMarketingContextChooser storefrontsFilterKey";
NSString *AJRMarketingContextChooserRecentItemsKey = @"AJRMarketingContextChooser recentItems";
NSString *AJRMarketingContextChooserFavoriteItemsKey = @"AJRMarketingContextChooser favoriteItemsKey";

NSString *AJRMarketingContextChooserFavoritesDidChangeNotification = @"AJRMarketingContextChooserFavoritesDidChangeNotification";


#pragma mark Comparators

static NSComparisonResult CompareSegments(AJRSegment *left, AJRSegment *right, AJRMarketingContextChooser *chooser)
{
    NSString    *leftName = [left segmentName];
    NSString    *rightName = [right segmentName];
    
    if ([leftName isEqualToString:@"All"] && [rightName isEqualToString:@"All"]) {
        return NSOrderedSame;
    } else if ([leftName isEqualToString:@"All"] && ![rightName isEqualToString:@"All"]) {
        return NSOrderedAscending;
    } else if (![leftName isEqualToString:@"All"] && [rightName isEqualToString:@"All"]) {
        return NSOrderedDescending;
    }
    return [leftName caseInsensitiveCompare:rightName];
}

static NSComparisonResult CompareGeos(AJRGeo *left, AJRGeo *right, AJRMarketingContextChooser *chooser)
{
    NSString    *leftName = [left regionName];
    NSString    *rightName = [right regionName];
    
    if ([leftName isEqualToString:@"World"] && [rightName isEqualToString:@"World"]) {
        return NSOrderedSame;
    } else if ([leftName isEqualToString:@"World"] && ![rightName isEqualToString:@"World"]) {
        return NSOrderedAscending;
    } else if (![leftName isEqualToString:@"World"] && [rightName isEqualToString:@"World"]) {
        return NSOrderedDescending;
    }
    return [leftName caseInsensitiveCompare:rightName];
}

static NSComparisonResult CompareLanguages(AJRLanguage *left, AJRLanguage *right, AJRMarketingContextChooser *chooser)
{
    NSString    *leftName = [left englishLanguageName];
    NSString    *rightName = [right englishLanguageName];
    
    if ([leftName isEqualToString:@"Not Language Specific"] && [rightName isEqualToString:@"Not Language Specific"]) {
        return NSOrderedSame;
    } else if ([leftName isEqualToString:@"Not Language Specific"] && ![rightName isEqualToString:@"Not Language Specific"]) {
        return NSOrderedAscending;
    } else if (![leftName isEqualToString:@"Not Language Specific"] && [rightName isEqualToString:@"Not Language Specific"]) {
        return NSOrderedDescending;
    }
    return [leftName caseInsensitiveCompare:rightName];
}

static NSComparisonResult CompareChannels(AJRChannel *left, AJRChannel *right, AJRMarketingContextChooser *chooser)
{
    NSString    *leftName = [left channelName];
    NSString    *rightName = [right channelName];
    
    if ([leftName isEqualToString:@"Common"] && [rightName isEqualToString:@"Common"]) {
        return NSOrderedSame;
    } else if ([leftName isEqualToString:@"Common"] && ![rightName isEqualToString:@"Common"]) {
        return NSOrderedAscending;
    } else if (![leftName isEqualToString:@"Common"] && [rightName isEqualToString:@"Common"]) {
        return NSOrderedDescending;
    }
    return [leftName caseInsensitiveCompare:rightName];
}

static NSComparisonResult CompareStores(AJRStorefront *left, AJRStorefront *right, AJRMarketingContextChooser *chooser)
{
    NSString    *leftName = [left storeName];
    NSString    *rightName = [right storeName];
    
    return [leftName caseInsensitiveCompare:rightName];
}


@implementation AJRMarketingContextChooser

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], AJRMarketingContextChooserShowDescendentStorefrontsKey,
      [NSNumber numberWithBool:YES], AJRMarketingContextChooserShowDisabledStorefrontsKey,
      [NSNumber numberWithBool:YES], AJRMarketingContextChooserShowCustomStorefrontsKey,
      @"", AJRMarketingContextChooserStorefrontsFilterKey,
      [NSArray arrayWithObject:@"US:consumer:en-us:common:10078"], AJRMarketingContextChooserFavoriteItemsKey,
      nil]];
}

#pragma mark Creation

+ (id)marketingContextChooser
{
    if (chooser == nil) {
        chooser = [[AJRMarketingContextChooser alloc] init];
    } else if (chooser->_inUse) {
        return [[[AJRMarketingContextChooser alloc] init] autorelease];
    }
    
    // Set the chooser back to a clean state
    chooser->_inUse = YES;
    [chooser setTitle:@"Choose a Marketing Context"];
    [[chooser cancelButton] setTitle:@"Cancel"];
    [[chooser chooseButton] setTitle:@"Choose"];
    [chooser setAccessoryView:nil];
    
    return chooser;
}

- (id)init
{
    if (_nibContentView == nil && (self = [super initWithContentRect:(NSRect){{0,0},{652,398}} styleMask:NSTitledWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO])) {
        if ([NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self]) {
            NSUserDefaults    *defaults = [NSUserDefaults standardUserDefaults];
            [self setReleasedWhenClosed:NO];
            [self setAutorecalculatesKeyViewLoop:NO];
            [self setMinSize:(NSSize){500.0, 300.0}];
            _showDescendentStorefronts = [defaults boolForKey:AJRMarketingContextChooserShowDescendentStorefrontsKey];
            _showDisabledStorefronts = [defaults boolForKey:AJRMarketingContextChooserShowDisabledStorefrontsKey];
            _showCustomStorefronts = [defaults boolForKey:AJRMarketingContextChooserShowCustomStorefrontsKey];
            _inUse = YES;
            _storefrontFetchLimit = AJRDefaultStorefrontFetchLimit;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesDidChange:) name:AJRMarketingContextChooserFavoritesDidChangeNotification object:[AJRMarketingContextChooser class]];
            return self;
        }
        [self release];
        return nil;
    }
    return self;
}

#pragma mark Private Initialization

- (void)fixKeyLoop
{
    [self setAutorecalculatesKeyViewLoop:NO];
    [_segmentTable setNextKeyView:_geoTable];
    [_geoTable setNextKeyView:_languageTable];
    [_languageTable setNextKeyView:_channelTable];
    [_channelTable setNextKeyView:_storefrontsFilterField];
    [_storefrontsFilterField setNextKeyView:_storefrontCollection];
    [_storefrontCollection setNextKeyView:_chooseButton];
    [_chooseButton setNextKeyView:_cancelButton];
    [_cancelButton setNextKeyView:_segmentTable];
}

- (void)awakeFromNib
{
    NSRect    frame = [_nibContentView frame];
    
    [self setContentSize:frame.size];
    [self setContentView:_nibContentView];
    
    [_storefrontsFilterField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:AJRMarketingContextChooserStorefrontsFilterKey]];

    [self performSelector:@selector(fixKeyLoop) withObject:nil afterDelay:0.1];
    [self makeFirstResponder:self.segmentTable];
    
    [self bind:@"selectedStorefronts" toObject:_storefrontController withKeyPath:@"selectedObjects" options:nil];
}

- (void)updateMarketingContext
{
//    [_marketingContextField setStringValue:[self.marketingContext longDescription]];
//    [_marketingContextShortField setStringValue:[self.marketingContext description]];

    [_geoTable reloadData];
    [_segmentTable reloadData];
    [_languageTable reloadData];
    [_channelTable reloadData];
    
    [_geoTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_geoTable rowForItem:[_marketingContext geo]]] byExtendingSelection:NO];
    [_segmentTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_segmentTable rowForItem:[_marketingContext segment]]] byExtendingSelection:NO];
    [_languageTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_languageTable rowForItem:[_marketingContext language]]] byExtendingSelection:NO];
    [_channelTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_channelTable rowForItem:[_marketingContext channel]]] byExtendingSelection:NO];
    
    [_geoTable scrollRowToVisible:[_geoTable selectedRow]];
    [_segmentTable scrollRowToVisible:[_segmentTable selectedRow]];
    [_languageTable scrollRowToVisible:[_languageTable selectedRow]];
    [_channelTable scrollRowToVisible:[_channelTable selectedRow]];
}

- (void)_getMarketingContext:(AJRMarketingContext **)marketingContext
               andStorefront:(AJRStorefront **)storefront
                        from:(NSString *)key
{
    NSArray        *parts = [key componentsSeparatedByString:@":"];
    NSString    *geoCode = [parts objectAtIndex:0];
    NSString    *segmentCode = [parts objectAtIndex:1];
    NSString    *languageCode = [parts objectAtIndex:2];
    NSString    *channelCode = [parts objectAtIndex:3];
    NSInteger    storefrontID = [[parts objectAtIndex:4] integerValue];
    
    if (marketingContext) {
        *marketingContext = [[self storefrontService] marketingContextWithGeoCode:geoCode segmentCode:segmentCode languageCode:languageCode channelCode:channelCode];
    }
    if (storefront) {
        if (storefrontID >= 0) {
            *storefront = [[self storefrontService] storefrontForStorefrontID:storefrontID];
        } else {
            *storefront = nil;
        }
    }
}

- (void)_addItemsInArray:(NSArray *)array toPopUp:(NSPopUpButton *)popUp withTitle:(NSString *)title
{
    NSMenu    *menu = [popUp menu];
    
    [popUp addItemWithTitle:title];
    [[[popUp itemArray] lastObject] setEnabled:NO];
    [[[popUp itemArray] lastObject] setTag:2000];
    [[[popUp itemArray] lastObject] setTarget:self];
    [[[popUp itemArray] lastObject] setAction:@selector(selectFavorite:)];
    
    for (NSString *item in array) {
        AJRMarketingContext    *marketingContext = nil;
        AJRStorefront        *storefront = nil;
        
        [self _getMarketingContext:&marketingContext andStorefront:&storefront from:item];
        
        if (marketingContext && storefront) {
            NSMenuItem    *item = [[NSMenuItem alloc] initWithTitle:AJRFormat(@"%@ — %@", [marketingContext longDescription], [storefront storeName]) action:@selector(selectFavorite:) keyEquivalent:@""];
            [item setTarget:self];
            [item setRepresentedObject:[NSDictionary dictionaryWithObjectsAndKeys:marketingContext, @"marketingContext", storefront, @"storefront", nil]];
            [menu addItem:item];
        } else if (marketingContext) {
            NSMenuItem    *item = [[NSMenuItem alloc] initWithTitle:[marketingContext longDescription]
                                                          action:@selector(selectFavorite:)
                                                   keyEquivalent:@""];
            [item setTarget:self];
            [item setRepresentedObject:[NSDictionary dictionaryWithObjectsAndKeys:marketingContext, @"marketingContext", nil]];
            [menu addItem:item];
        } else if (storefront) {
            NSMenuItem    *item = [[NSMenuItem alloc] initWithTitle:[storefront storeName]
                                                          action:@selector(selectFavorite:)
                                                   keyEquivalent:@""];
            [item setTarget:self];
            [item setRepresentedObject:[NSDictionary dictionaryWithObjectsAndKeys:storefront, @"storefront", nil]];
            [menu addItem:item];
        }
    }
}

- (void)_setupRecentItemsMenu
{
    NSArray        *recentItems;
    NSArray        *favoriteItems;
    
    recentItems = [[NSUserDefaults standardUserDefaults] arrayForKey:AJRMarketingContextChooserRecentItemsKey];
    favoriteItems = [[NSUserDefaults standardUserDefaults] arrayForKey:AJRMarketingContextChooserFavoriteItemsKey];
    
    while ([_favoritesPopUp numberOfItems] > 1) {
        [_favoritesPopUp removeItemAtIndex:[_favoritesPopUp numberOfItems] - 1];
    }
    
    if ([favoriteItems count]) {
        [self _addItemsInArray:favoriteItems toPopUp:_favoritesPopUp withTitle:@"Favorites"];
    }

    if ([recentItems count]) {
        if ([favoriteItems count]) {
            [[_favoritesPopUp menu] addItem:[NSMenuItem separatorItem]];
        }
        [self _addItemsInArray:recentItems toPopUp:_favoritesPopUp withTitle:@"Recent Choices"];
    }
}

- (void)favoritesDidChange:(NSNotification *)notification
{
    [self _setupRecentItemsMenu];
}

- (void)_initialSetupForMarketingContext:(AJRMarketingContext *)marketingContext
                              storefront:(AJRStorefront *)storefront
                                   parts:(AJRMarketingContextPartMask)partsMask
                           modalDelegate:(id)delegate
{
    _delegate = delegate;
    
    _partsMask = partsMask;
    
    [_storefrontService release];
    _storefrontService = [[marketingContext.environment storefrontService] retain];
    
    [_geos release];
    if ([[self delegate] respondsToSelector:@selector(marketingContextChooserNeedsGeos:)]) {
        _geos = [[(id)[self delegate] marketingContextChooserNeedsGeos:self] mutableCopy];
    } else {
        _geos = [[_storefrontService geos] mutableCopy];
    }
    [_segments release];
    if ([[self delegate] respondsToSelector:@selector(marketingContextChooserNeedsGeos:)]) {
        _segments = [[(id)[self delegate] marketingContextChooserNeedsSegments:self] mutableCopy];
    } else {
        _segments = [[_storefrontService segments] mutableCopy];
    }
    [_languages release];
    if ([[self delegate] respondsToSelector:@selector(marketingContextChooserNeedsGeos:)]) {
        _languages = [[(id)[self delegate] marketingContextChooserNeedsLanguages:self] mutableCopy];
    } else {
        _languages = [[_storefrontService languages] mutableCopy];
    }
    [_channels release];
    if ([[self delegate] respondsToSelector:@selector(marketingContextChooserNeedsGeos:)]) {
        _channels = [[(id)[self delegate] marketingContextChooserNeedsChannels:self] mutableCopy];
    } else {
        _channels = [[_storefrontService channels] mutableCopy];
    }
    
    [[_segmentTable window] makeFirstResponder:_segmentTable];

    self.storefront = storefront;
    _ignoreNextStorefrontSelectionChange = YES;
    self.marketingContext = marketingContext;
    
    [self splitView:_splitView resizeSubviewsWithOldSize:[_splitView frame].size initial:YES];
    
    [self _setupRecentItemsMenu];
}

#pragma mark Running

- (void)beginSheetForMarketingContext:(AJRMarketingContext *)context modalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo
{
    [self beginSheetForMarketingContext:context
                         modalForWindow:docWindow
                          modalDelegate:modalDelegate
                         didEndSelector:didEndSelector
                            contextInfo:contextInfo 
                                  parts:AJRAllChooserMask];
}

- (void)beginSheetForMarketingContext:(AJRMarketingContext *)context
                       modalForWindow:(NSWindow *)docWindow
                        modalDelegate:(id)modalDelegate
                       didEndSelector:(SEL)didEndSelector
                          contextInfo:(void *)contextInfo
                                parts:(AJRMarketingContextPartMask)partsMask
{
    [self beginSheetForMarketingContext:context
                             storefront:nil
                         modalForWindow:docWindow 
                          modalDelegate:modalDelegate
                         didEndSelector:didEndSelector
                            contextInfo:contextInfo
                                  parts:partsMask];
}

- (void)beginSheetForMarketingContext:(AJRMarketingContext *)context
                           storefront:(AJRStorefront *)storefront
                       modalForWindow:(NSWindow *)docWindow
                        modalDelegate:(id)modalDelegate
                       didEndSelector:(SEL)didEndSelector
                          contextInfo:(void *)contextInfo
                                parts:(AJRMarketingContextPartMask)partsMask
{
    [self _initialSetupForMarketingContext:context storefront:storefront parts:partsMask modalDelegate:modalDelegate];
    
    [self updateMarketingContext];

    [NSApp beginSheet:self modalForWindow:docWindow modalDelegate:modalDelegate didEndSelector:didEndSelector contextInfo:contextInfo];
}

- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context
{
    return [self runModalForMarketingContext:context parts:AJRAllChooserMask];
}

- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context 
                                   parts:(AJRMarketingContextPartMask)partsMask
{
    return [self runModalForMarketingContext:context storefront:nil parts:partsMask];
}

- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context
                              storefront:(AJRStorefront *)storefront
                                   parts:(AJRMarketingContextPartMask)partsMask
{
    return [self runModalForMarketingContext:context storefront:storefront parts:partsMask delegate:nil];
}

- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context
                              storefront:(AJRStorefront *)storefront
                                   parts:(AJRMarketingContextPartMask)partsMask
                                delegate:(id)delegate
{
    NSInteger    response;

    [self _initialSetupForMarketingContext:context storefront:storefront parts:partsMask modalDelegate:delegate];
    
    [self center];
    [self makeKeyAndOrderFront:self];
    [self updateMarketingContext];
    
    response = [NSApp runModalForWindow:self];
    
    [self orderOut:self];
    _inUse = NO;
    
    return response;
}

- (void)dealloc
{
    if (chooser == self) {
        [_marketingContext release]; _marketingContext = nil;
        [_storefrontService release]; _storefrontService = nil;
        [self retain];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_nibContentView release];
    [_geoTable release];
    [_segmentTable release];
    [_languageTable release];
    [_channelTable release];
    [_segmentToggle release];
    [_geoToggle release];
    [_languageToggle release];
    [_channelToggle release];
    [_marketingContextField release];
    [_marketingContextShortField release];
    [_chooseButton release];
    [_cancelButton release];
    [_storefrontsFilterField release];
    [_storefrontsFilterMenu release];
    [_favoritesPopUp release];
    [_marketingContext release];
    [_storefront release];
    [_storefrontService release];
    [_accessoryView release];
    [_marketingContextController release];
    [_splitView release];
    [_tablesContainer release];
    [_storefrontCollection release];
    [_storefrontController release];
    [_storefronts release];

    [super dealloc];
}

#pragma mark Properties

@synthesize nibContentView = _nibContentView;
@synthesize geoTable = _geoTable;
@synthesize segmentTable = _segmentTable;
@synthesize languageTable = _languageTable;
@synthesize channelTable = _channelTable;
@synthesize geoToggle = _geoToggle;
@synthesize segmentToggle = _segmentToggle;
@synthesize languageToggle = _languageToggle;
@synthesize channelToggle = _channelToggle;
@synthesize marketingContextField = _marketingContextField;
@synthesize marketingContextShortField = _marketingContextShortField;
@synthesize chooseButton = _chooseButton;
@synthesize cancelButton = _cancelButton;
@synthesize storefrontsFilterField = _storefrontsFilterField;
@synthesize storefrontsFilterMenu = _storefrontsFilterMenu;
@synthesize favoritesPopUp = _favoritesPopUp;
@synthesize marketingContext = _marketingContext;
@synthesize storefront = _storefront;
@synthesize storefronts = _storefronts;
@synthesize storefrontService = _storefrontService;
@synthesize splitView = _splitView;
@synthesize tablesContainer = _tablesContainer;
@synthesize accessoryView = _accessoryView;
@synthesize storefrontCollection = _storefrontCollection;
@synthesize marketingContextController = _marketingContextController;
@synthesize storefrontController = _storefrontController;
@synthesize partsMask = _partsMask;
@synthesize showDescendentStorefronts = _showDescendentStorefronts;
@synthesize showCustomStorefronts = _showCustomStorefronts;
@synthesize showDisabledStorefronts = _showDisabledStorefronts;
@synthesize storefrontFetchLimit = _storefrontFetchLimit;

- (void)setPartsMask:(NSUInteger)partsMask
{
    if (_partsMask != partsMask) {
        _partsMask = partsMask;
        [self splitView:_splitView resizeSubviewsWithOldSize:[_splitView frame].size initial:YES];
        [(AJRMCTablesView *)_tablesContainer tileWithAnimation:YES];
    }
}

- (void)setStorefront:(AJRStorefront *)storefront
{
    if (_storefront != storefront) {
        [_storefront release];
        _storefront = [storefront retain];
        if (_partsMask & AJRStorefrontChooserMask) {
            [self.chooseButton setEnabled:self.storefront != nil];
        }
    }
}

- (NSArray *)_filterStorefronts:(NSArray *)storefronts
{
    NSMutableArray    *filteredStorefronts;
    NSString        *nameFilter;
    
    if ([storefronts count] == 0) {
        // Just to quiet a warning, we won't actually try to manipulate this array below.
        filteredStorefronts = (NSMutableArray *)storefronts;
    } else {
        filteredStorefronts = [[NSMutableArray alloc] init];
    
        nameFilter = [self.storefrontsFilterField stringValue];
        for (AJRStorefront *storefront in storefronts) {
            BOOL        include = YES;
            NSInteger    storefrontID = [nameFilter integerValue];
            
            if ([nameFilter length] && [[storefront storeName] rangeOfString:nameFilter options:NSCaseInsensitiveSearch].location == NSNotFound) {
                include = NO;
            }
            if (storefrontID != 0) {
                include = [storefront storeFrontID] == storefrontID;
            }
            if (include && !_showDisabledStorefronts && ![storefront isActive]) {
                include = NO;
            }
            if (include && !_showCustomStorefronts && [storefront isCustomStore]) {
                include = NO;
            }
            if (include) {
                [filteredStorefronts addObject:storefront];
            }
        }
        [filteredStorefronts autorelease];
    }
    
    if ([filteredStorefronts count] == 0) {
        self.storefront = nil;
    } else {
        if (![filteredStorefronts containsObject:self.storefront]) {
            self.storefront = nil;
        }
    }
        
    return filteredStorefronts;
}

- (void)_updateStorefrontSelection
{
    if ([_storefronts count]) {
        // This means we've actually fetched stores, so we want to try and match the selection to our storefront.
        NSUInteger    index = 0;
        
        if (_storefront) {
            index = [_storefronts indexOfObjectIdenticalTo:_storefront];
            if (index == NSNotFound) {
                index = 0;
            }
        }
        [_storefrontController setSelectionIndex:index];
        // Stupid, but this method is private.
        [_storefrontCollection performSelector:@selector(_scrollSelectionToVisible) withObject:nil afterDelay:0.1];
        self.storefront = [[_storefrontController selectedObjects] lastObject];
    } else {
        _ignoreNextStorefrontSelectionChange = YES;
        self.storefront = nil;
    }
}

- (void)_updateStorefronts
{
    NSArray        *storefronts = nil;

    if (_partsMask & AJRStorefrontChooserMask) {
        storefronts = _showDescendentStorefronts ? [_marketingContext storefrontsWithDescendents] : [_marketingContext storefronts];
        
        storefronts = [self _filterStorefronts:storefronts];
        
        storefronts = [storefronts sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))CompareStores context:self];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(marketingContextChooser:needsStorefrontsFromArray:)]) {
            storefronts = [(id)self.delegate marketingContextChooser:self needsStorefrontsFromArray:storefronts];
        }
        
        if (_storefrontFetchLimit > 0 && [storefronts count] > _storefrontFetchLimit) {
            storefronts = [storefronts subarrayWithRange:NSMakeRange(0, _storefrontFetchLimit)];
        }
    } else {
        storefronts = [NSArray array];
    }
    
    [self setStorefronts:storefronts];

    [self _updateStorefrontSelection];
}

- (void)setMarketingContext:(AJRMarketingContext *)context
{
    if (_marketingContext != context) {
        if (_marketingContext != nil) {
            @try {
                [_marketingContext removeObserver:self forKeyPath:@"storefrontsWithDescendents"];
            } @catch (NSException *exception) { }
            @try {
                [_marketingContext removeObserver:self forKeyPath:@"storefronts"];
            } @catch (NSException *exception) { }
        }
        
        [_marketingContext release];
        _marketingContext = [context retain];
        [_marketingContext addObserver:self forKeyPath:@"storefrontsWithDescendents" options:0 context:NULL];
        [_marketingContext addObserver:self forKeyPath:@"storefronts" options:0 context:NULL];
        [self _updateStorefronts];

        [_geos sortUsingFunction:(NSInteger (*)(id, id, void *))CompareGeos context:self];
        [_segments sortUsingFunction:(NSInteger (*)(id, id, void *))CompareSegments context:self];
        [_languages sortUsingFunction:(NSInteger (*)(id, id, void *))CompareLanguages context:self];
        [_channels sortUsingFunction:(NSInteger (*)(id, id, void *))CompareChannels context:self];
    }
}

- (NSArray *)selectedStorefronts
{
    if (_storefront) {
        return [NSArray arrayWithObject:_storefront];
    }
    return [NSArray array];
}

- (void)setSelectedStorefronts:(NSArray *)selection
{
    log4Debug(@"storefront selection changed: %@", selection);
    if (!_ignoreNextStorefrontSelectionChange) {
        self.storefront = [selection count] ? [selection objectAtIndex:0] : nil;
    } else {
        _ignoreNextStorefrontSelectionChange = NO;
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"storefrontsWithDescendents"] || [keyPath isEqualToString:@"storefronts"]) {
        [self _updateStorefronts];
    } else if ([keyPath isEqualToString:@"selectedObjects"]) {
        [self selectStorefront:object];
    }
}

#pragma mark Actions

- (IBAction)choose:(id)sender
{
    NSMutableArray        *recentItems;
    NSString            *key;
    
    if (_marketingContext != nil) {
        @try {
            [_marketingContext removeObserver:self forKeyPath:@"storefrontsWithDescendents"];
        } @catch (NSException *exception) { }
        @try {
            [_marketingContext removeObserver:self forKeyPath:@"storefronts"];
        } @catch (NSException *exception) { }
    }
    
    self.storefront = [[self.storefrontController selectedObjects] lastObject];
    
    recentItems = [[[NSUserDefaults standardUserDefaults] arrayForKey:AJRMarketingContextChooserRecentItemsKey] mutableCopy];
    if (recentItems == nil) {
        recentItems = [[NSMutableArray alloc] init];
    }
    key = [[self class] favoritesKeyForMarketingContext:_marketingContext andStorefront:_storefront];
    // Remove the key if it's already there.
    [recentItems removeObject:key];
    // Put the key at the head of the list.
    [recentItems insertObject:key atIndex:0];
    // Make sure the list isn't too large
    while ([recentItems count] > 10) {
        [recentItems removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:recentItems forKey:AJRMarketingContextChooserRecentItemsKey];
    [recentItems release];
        
    if ([self isSheet]) {
        [NSApp endSheet:self returnCode:NSOKButton];
        _inUse = NO;
        [self orderOut:self];
    } else {
        [NSApp stopModalWithCode:NSOKButton];
    }
}

- (IBAction)cancel:(id)sender
{
    if (_marketingContext != nil) {
        @try {
            [_marketingContext removeObserver:self forKeyPath:@"storefrontsWithDescendents"];
        } @catch (NSException *exception) { }
        @try {
            [_marketingContext removeObserver:self forKeyPath:@"storefronts"];
        } @catch (NSException *exception) { }
    }
    
    if ([self isSheet]) {
        [NSApp endSheet:self returnCode:NSCancelButton];
        _inUse = NO;
        [self orderOut:self];
    } else {
        [NSApp stopModalWithCode:NSCancelButton];
    }
}

- (IBAction)selectGeo:(id)sender
{
    NSInteger    row = [sender selectedRow];
    
    if (row >= 0) {
        AJRMarketingContext    *old = [_marketingContext retain];
        AJRGeo                *geo = [_geoTable itemAtRow:row];
        self.marketingContext = [_storefrontService marketingContextWithGeo:geo
                                                                    segment:[old segment] 
                                                                   language:[old language] 
                                                                    channel:[old channel]];
        [old release];
    }
    [self updateMarketingContext];
}

- (IBAction)selectSegment:(id)sender
{
    NSInteger    row = [sender selectedRow];
    
    if (row >= 0) {
        AJRMarketingContext    *old = [_marketingContext retain];
        AJRSegment            *segment = [_segmentTable itemAtRow:row];
        self.marketingContext = [_storefrontService marketingContextWithGeo:[old geo]
                                                                    segment:segment
                                                                   language:[old language] 
                                                                    channel:[old channel]];
        [old release];
    }
    [self updateMarketingContext];
}

- (IBAction)selectLanguage:(id)sender
{
    NSInteger    row = [sender selectedRow];
    
    if (row >= 0) {
        AJRMarketingContext    *old = [_marketingContext retain];
        AJRLanguage            *language = [_languageTable itemAtRow:row];
        self.marketingContext = [_storefrontService marketingContextWithGeo:[old geo]
                                                                    segment:[old segment] 
                                                                   language:language 
                                                                    channel:[old channel]];
        [old release];
    }
    [self updateMarketingContext];
}

- (IBAction)selectChannel:(id)sender
{
    NSInteger    row = [sender selectedRow];
    
    if (row >= 0) {
        AJRMarketingContext    *old = [_marketingContext retain];
        AJRChannel            *channel = [_channelTable itemAtRow:row];
        self.marketingContext = [_storefrontService marketingContextWithGeo:[old geo]
                                                                    segment:[old segment] 
                                                                   language:[old language] 
                                                                    channel:channel];
        [old release];
    }
    [self updateMarketingContext];
}

- (IBAction)selectStorefront:(id)sender
{
    self.storefront = [[_storefrontController selectedObjects] lastObject];
}

- (id)findObjectForKey:(NSString *)key value:(id)value inList:(NSArray *)list
{
    NSRange        range = (NSRange){0, [value length]};
    
    // First, try exact matches.
    for (id listValue in list) {
        if ([[listValue valueForKey:key] compare:value options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return listValue;
        }
        if ([[listValue key] compare:value options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return listValue;
        }
    }
    // If that fails, try partial matches. These may not produce the expected results.
    for (id listValue in list) {
        if ([[listValue valueForKey:key] compare:value options:NSCaseInsensitiveSearch range:range] == NSOrderedSame) {
            return listValue;
        }
        if ([[listValue key] compare:value options:NSCaseInsensitiveSearch range:range] == NSOrderedSame) {
            return listValue;
        }
    }
    return nil;
}

- (BOOL)isCurrentEventReturn
{
    NSEvent    *event = [NSApp currentEvent];
    
    if ([event type] == NSKeyDown) {
        if ([[event characters] isEqualToString:@"\r"]) {
            return YES;
        }
    }
    return NO;
}

- (void)setAccessoryView:(NSView *)accessoryView
{
    if (_accessoryView != accessoryView) {
        if (_accessoryView) {
            NSRect        accessoryFrame = [_accessoryView frame];
            NSRect        splitFrame;
            NSRect        contentFrame = [[self contentView] frame];

            // Remove the accessory view.
            [_accessoryView removeFromSuperview];
            
            // Resize the tab view to occupy the space removed.
            splitFrame = [self.splitView frame];
            splitFrame.size.height += accessoryFrame.size.height;
            splitFrame.origin.y -= accessoryFrame.size.height;
            [self.splitView setFrame:splitFrame];
            
            // And then reduce the panel's (our) size.
            contentFrame.size.height -= accessoryFrame.size.height;
            [self setContentSize:contentFrame.size];
        }
        [_accessoryView release];
        _accessoryView = [accessoryView retain];
        if (_accessoryView) {
            NSRect        accessoryFrame = [_accessoryView frame];
            NSRect        contentFrame = [[self contentView] frame];
            NSRect        splitFrame;
            
            [accessoryView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];

            // Resize our content view.
            contentFrame.size.height += accessoryFrame.size.height;
            [self setContentSize:contentFrame.size];
            
            // Compute the location and initial of the accessory view...
            accessoryFrame.origin.y = 45.0;
            accessoryFrame.size.width = contentFrame.size.width;
            [accessoryView setFrame:accessoryFrame];
            // And add it into our view hierarchy.
            [[self contentView] addSubview:_accessoryView];
            
            // Now, adjust the location and size of the tab view.
            splitFrame = [self.splitView frame];
            splitFrame.size.height -= accessoryFrame.size.height;
            splitFrame.origin.y += accessoryFrame.size.height;
            [self.splitView setFrame:splitFrame];
        }
    }
}

- (IBAction)toggleSegmentOutline:(id)sender
{
    [_segmentTable reloadData];
    if ([sender state]) {
        [_segmentTable expandItem:[[self storefrontService] segmentForCode:@"all"] expandChildren:YES];
    }
    [_segmentTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_segmentTable rowForItem:[_marketingContext segment]]] byExtendingSelection:NO];
    [_segmentTable scrollRowToVisible:[_segmentTable selectedRow]];
}

- (IBAction)toggleGeoOutline:(id)sender
{
    [_geoTable reloadData];
    if ([sender state]) {
        [_geoTable expandItem:[[self storefrontService] geoForCode:@"ww"] expandChildren:YES];
    }
    [_geoTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_geoTable rowForItem:[_marketingContext geo]]] byExtendingSelection:NO];
    [_geoTable scrollRowToVisible:[_geoTable selectedRow]];
}

- (IBAction)toggleLanguageOutline:(id)sender
{
    [_languageTable reloadData];
    if ([sender state]) {
        [_languageTable expandItem:[[self storefrontService] languageForCode:@"any"] expandChildren:YES];
    }
    [_languageTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_languageTable rowForItem:[_marketingContext language]]] byExtendingSelection:NO];
    [_languageTable scrollRowToVisible:[_languageTable selectedRow]];
}

- (IBAction)toggleChannelOutline:(id)sender
{
    [_channelTable reloadData];
    if ([sender state]) {
        [_channelTable expandItem:[[self storefrontService] channelForCode:@"common"] expandChildren:YES];
    }
    [_channelTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[_channelTable rowForItem:[_marketingContext channel]]] byExtendingSelection:NO];
    [_channelTable scrollRowToVisible:[_channelTable selectedRow]];
}

#pragma mark NSSearchField Actions

- (IBAction)filterStorefronts:(id)sender
{
    log4Debug(@"filter: %@", self, [sender stringValue]);
    [[NSUserDefaults standardUserDefaults] setObject:[sender stringValue] forKey:AJRMarketingContextChooserStorefrontsFilterKey];
    [self _updateStorefronts];
}

- (IBAction)toggleDescendentStorefronts:(id)sender
{
    _showDescendentStorefronts = _showDescendentStorefronts == NO;
    [[NSUserDefaults standardUserDefaults] setBool:_showDescendentStorefronts forKey:AJRMarketingContextChooserShowDescendentStorefrontsKey];
    [self _updateStorefronts];
}

- (IBAction)toggleDisabledStorefronts:(id)sender
{
    _showDisabledStorefronts = _showDisabledStorefronts == NO;
    [[NSUserDefaults standardUserDefaults] setBool:_showDisabledStorefronts forKey:AJRMarketingContextChooserShowDisabledStorefrontsKey];
    [self _updateStorefronts];
}

- (IBAction)toggleCustomStorefronts:(id)sender
{
    _showCustomStorefronts = _showCustomStorefronts == NO;
    [[NSUserDefaults standardUserDefaults] setBool:_showCustomStorefronts forKey:AJRMarketingContextChooserShowCustomStorefrontsKey];
    [self _updateStorefronts];
}

- (IBAction)selectFavorite:(id)sender
{
    AJRMarketingContext    *marketingContext = [[sender representedObject] objectForKey:@"marketingContext"];
    AJRStorefront        *storefront = [[sender representedObject] objectForKey:@"storefront"];
    
    if (marketingContext == nil && storefront != nil) {
        marketingContext = [storefront marketingContext];
    }
    
    log4Debug(@"Select: %@ / %@", marketingContext, storefront);
    
    if (marketingContext) {
        self.marketingContext = marketingContext;
    }
    if (storefront) {
        self.storefront = storefront;
    }
    [self _updateStorefrontSelection];
}

#pragma mark NSMenuValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    switch ([menuItem tag]) {
        case 10000:
            [menuItem setTitle:AJRFormat(@"%@ Descendent Stores", _showDescendentStorefronts ? @"Hide" : @"Show")];
            return YES;
        case 10001:
            [menuItem setTitle:AJRFormat(@"%@ Disabled Stores", _showDisabledStorefronts ? @"Hide" : @"Show")];
            return YES;
        case 10002:
            [menuItem setTitle:AJRFormat(@"%@ Custom Stores", _showCustomStorefronts ? @"Hide" : @"Show")];
            return YES;
        case 2000:
            return NO;
    }
    return YES;
}

#pragma mark Favorites Management

+ (NSString *)favoritesKeyForMarketingContext:(AJRMarketingContext *)marketingContext 
                                andStorefront:(AJRStorefront *)storefront
{
    return AJRFormat(@"%@:%@:%@:%@:%d", 
                    [marketingContext geo] ? [[marketingContext geo] geoCode] : @"ww",
                    [marketingContext segment] ? [[marketingContext segment] segmentCode] : @"all",
                    [marketingContext language] ? [[marketingContext language] languageCode] : @"any",
                    [marketingContext channel] ? [[marketingContext channel] channelCode] : @"common",
                    storefront ? [storefront storeFrontID] : -1);
}

+ (NSArray *)favorites
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:AJRMarketingContextChooserFavoriteItemsKey];
}

+ (BOOL)isFavoriteStorefront:(AJRStorefront *)storefront
{
    return [[self favorites] containsObject:[self favoritesKeyForMarketingContext:[storefront marketingContext] andStorefront:storefront]];
}

+ (BOOL)isFavoriteMarketingContext:(AJRMarketingContext *)marketingContext
{
    return [[self favorites] containsObject:[self favoritesKeyForMarketingContext:marketingContext andStorefront:nil]];
}

+ (BOOL)_addToFavorites:(NSString *)key
{
    NSArray        *favorites = [self favorites];

    if ([favorites containsObject:key]) {
        return NO;
    }
    
    favorites = [favorites mutableCopy];
    [(NSMutableArray *)favorites addObject:key];
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:AJRMarketingContextChooserFavoriteItemsKey];
    [favorites release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMarketingContextChooserFavoritesDidChangeNotification object:self];
    
    return YES;
}

+ (BOOL)addStorefrontToFavorites:(AJRStorefront *)storefront
{
    return [self _addToFavorites:[self favoritesKeyForMarketingContext:[storefront marketingContext] andStorefront:storefront]];
}

+ (BOOL)addMarketingContextToFavorites:(AJRMarketingContext *)marketingContext
{
    return [self _addToFavorites:[self favoritesKeyForMarketingContext:marketingContext andStorefront:nil]];
}

+ (BOOL)_removeFromFavorites:(NSString *)key
{
    NSArray        *favorites = [self favorites];
    
    if (![favorites containsObject:key]) {
        return NO;
    }
    
    favorites = [favorites mutableCopy];
    [(NSMutableArray *)favorites removeObject:key];
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:AJRMarketingContextChooserFavoriteItemsKey];
    [favorites release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMarketingContextChooserFavoritesDidChangeNotification object:self];
    
    return YES;
}

+ (BOOL)removeStorefrontFromFavorites:(AJRStorefront *)storefront
{
    return [self _removeFromFavorites:[self favoritesKeyForMarketingContext:[storefront marketingContext] andStorefront:storefront]];
}

+ (BOOL)removeMarketingContextFromFavorites:(AJRMarketingContext *)marketingContext
{
    return [self _removeFromFavorites:[self favoritesKeyForMarketingContext:marketingContext andStorefront:nil]];
}

#pragma mark NSSplitViewDelegate

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [self splitView:sender resizeSubviewsWithOldSize:oldSize initial:NO];
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize initial:(BOOL)initial
{
    if (self.partsMask & AJRStorefrontChooserMask) {
        NSRect        rect = [_splitView bounds];
        NSRect        tablesRect = [_tablesContainer frame];
        NSRect        collectionRect = [[[_splitView subviews] lastObject] frame];
        
        if (initial && (tablesRect.size.width > 199.0)) {
            collectionRect.origin.x = 200.0;
            collectionRect.size.width = rect.size.width - collectionRect.origin.x;
            tablesRect.size.width = 199.0;
        }

        collectionRect.origin.x = tablesRect.origin.x + tablesRect.size.width + 1.0;
        collectionRect.origin.y = 0.0;
        collectionRect.size.width = rect.size.width - collectionRect.origin.x;
        collectionRect.size.height = rect.size.height;
        tablesRect.origin.x = 0.0;
        tablesRect.origin.y = 0.0;
        tablesRect.size.height = rect.size.height;
        if (collectionRect.size.width < 100) {
            collectionRect.size.width = 100;
            collectionRect.origin.x = rect.size.width - collectionRect.size.width + 1.0;
            
            tablesRect.size.width = rect.size.width - collectionRect.size.width;
            if (tablesRect.size.width < 0) {
                tablesRect.size.width = 0.0;
                collectionRect.origin.y = 0.0;
                collectionRect.size.width = rect.size.width;
            }
        }
        
        [_tablesContainer setFrame:tablesRect];
        [[[_splitView subviews] lastObject] setFrame:collectionRect];
    } else {
        NSRect        rect = [_splitView bounds];
        NSRect        tablesRect = [_tablesContainer frame];
        NSRect        collectionRect = [[[_splitView subviews] lastObject] frame];
    
        collectionRect.origin.x = rect.size.width;
        collectionRect.origin.y = 0.0;
        collectionRect.size.width = 0.0;
        collectionRect.size.height = rect.size.height;
        tablesRect.origin.y = 0.0;
        tablesRect.size.width = rect.size.width - 1.0;
        tablesRect.size.height = rect.size.height;
        
        [_tablesContainer setFrame:tablesRect];
        [[[_splitView subviews] lastObject] setFrame:collectionRect];
    }
}

#pragma mark Bindings

+ (NSSet *)keyPathsForValuesAffectingLongDescription
{
    return [NSMutableSet setWithObjects:@"marketingContext", nil];
}

- (NSString *)longDescription
{
    NSMutableString    *description = [NSMutableString string];
    
    if (_partsMask & AJRSegmentChooserMask) {
        [description appendString:[[[self marketingContext] segment] segmentName]];
    }
    if (_partsMask & AJRGeoChooserMask) {
        if ([description length]) [description appendString:@":"];
        [description appendString:[[[self marketingContext] geo] regionName]];
    }
    if (_partsMask & AJRLanguageChooserMask) {
        if ([description length]) [description appendString:@":"];
        [description appendString:[[[self marketingContext] language] englishLanguageName]];
    }
    if (_partsMask & AJRChannelChooserMask) {
        if ([description length]) [description appendString:@":"];
        [description appendString:[[[self marketingContext] channel] channelName]];
    }
    
    return description;
}

+ (NSSet *)keyPathsForValuesAffectingShortDescription
{
    return [NSMutableSet setWithObjects:@"marketingContext", nil];
}

- (NSString *)shortDescription
{
    NSMutableString    *description = [NSMutableString string];
    
    if (_partsMask & AJRSegmentChooserMask) {
        [description appendString:[[[self marketingContext] segment] segmentCode]];
    }
    if (_partsMask & AJRGeoChooserMask) {
        if ([description length]) [description appendString:@":"];
        [description appendString:[[[self marketingContext] geo] geoCode]];
    }
    if (_partsMask & AJRLanguageChooserMask) {
        if ([description length]) [description appendString:@":"];
        [description appendString:[[[self marketingContext] language] languageCode]];
    }
    if (_partsMask & AJRChannelChooserMask) {
        if ([description length]) [description appendString:@":"];
        [description appendString:[[[self marketingContext] channel] channelCode]];
    }
    
    return description;
}

@end
