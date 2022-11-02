/*
 AJRMarketingContextChooser.h
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
//
//  AJRMarketingContextChooser.h
//  AJRInterface
//
//  Created by Alex Raftis on 10/9/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRMarketingContext, AJRStorefront, AJRStorefrontService;

extern NSString *AJRMarketingContextChooserShowDescendentStorefrontsKey;
extern NSString *AJRMarketingContextChooserShowDisabledStorefrontsKey;
extern NSString *AJRMarketingContextChooserShowCustomStorefrontsKey;
extern NSString *AJRMarketingContextChooserStorefrontsFilterKey;
extern NSString *AJRMarketingContextChooserRecentItemsKey;
extern NSString *AJRMarketingContextChooserFavoriteItemsKey;

extern NSString *AJRMarketingContextChooserFavoritesDidChangeNotification;

const extern NSInteger AJRDefaultStorefrontFetchLimit;

typedef enum _AJRMarketingContextPartMask {
    AJRSegmentChooserMask        = 0x0001,
    AJRGeoChooserMask            = 0x0002,
    AJRLanguageChooserMask        = 0x0004,
    AJRChannelChooserMask        = 0x0008,
    AJRStorefrontChooserMask        = 0x0010,
    AJRAllChooserMask            = 0x001F
} AJRMarketingContextPartMask;

@interface AJRMarketingContextChooser : NSPanel 
{
    NSView                    *_nibContentView;
    NSOutlineView            *_geoTable;
    NSOutlineView            *_segmentTable;
    NSOutlineView            *_languageTable;
    NSOutlineView            *_channelTable;
    NSButton                *_geoToggle;
    NSButton                *_segmentToggle;
    NSButton                *_languageToggle;
    NSButton                *_channelToggle;
    NSTextField                *_marketingContextField;
    NSTextField                *_marketingContextShortField;
    NSButton                *_chooseButton;
    NSButton                *_cancelButton;
    NSObjectController        *_marketingContextController;
    NSArrayController        *_storefrontController;
    NSSplitView                *_splitView;
    NSView                    *_tablesContainer;
    NSCollectionView        *_storefrontCollection;
    NSSearchField            *_storefrontsFilterField;
    NSMenu                    *_storefrontsFilterMenu;
    NSPopUpButton            *_favoritesPopUp;
    
    AJRStorefrontService        *_storefrontService;
    AJRMarketingContext        *_marketingContext;
    AJRStorefront            *_storefront;
    NSArray                    *_storefronts;
    NSUInteger                _partsMask;
    NSMutableArray            *_geos;
    NSMutableArray            *_segments;
    NSMutableArray            *_languages;
    NSMutableArray            *_channels;
    BOOL                    _inUse;
    BOOL                    _showDescendentStorefronts;
    BOOL                    _showCustomStorefronts;
    BOOL                    _showDisabledStorefronts;
    BOOL                    _ignoreNextStorefrontSelectionChange;
    NSInteger                _storefrontFetchLimit;
    NSView                    *_accessoryView;
}

+ (id)marketingContextChooser;

- (void)beginSheetForMarketingContext:(AJRMarketingContext *)context modalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo;
- (void)beginSheetForMarketingContext:(AJRMarketingContext *)context
                       modalForWindow:(NSWindow *)docWindow
                        modalDelegate:(id)modalDelegate
                       didEndSelector:(SEL)didEndSelector
                          contextInfo:(void *)contextInfo
                                parts:(AJRMarketingContextPartMask)parts;
- (void)beginSheetForMarketingContext:(AJRMarketingContext *)context
                           storefront:(AJRStorefront *)storefront
                       modalForWindow:(NSWindow *)docWindow
                        modalDelegate:(id)modalDelegate
                       didEndSelector:(SEL)didEndSelector
                          contextInfo:(void *)contextInfo
                                parts:(AJRMarketingContextPartMask)parts;
- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context;
- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context
                                   parts:(AJRMarketingContextPartMask)mask;
- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context
                              storefront:(AJRStorefront *)storefront
                                   parts:(AJRMarketingContextPartMask)mask;
- (NSInteger)runModalForMarketingContext:(AJRMarketingContext *)context
                              storefront:(AJRStorefront *)storefront
                                   parts:(AJRMarketingContextPartMask)partsMask
                                delegate:(id)delegate;

@property (nonatomic,retain) IBOutlet NSView *nibContentView;
@property (nonatomic,retain) IBOutlet NSTableView *geoTable;
@property (nonatomic,retain) IBOutlet NSTableView *segmentTable;
@property (nonatomic,retain) IBOutlet NSTableView *languageTable;
@property (nonatomic,retain) IBOutlet NSTableView *channelTable;
@property (nonatomic,retain) IBOutlet NSButton *geoToggle;
@property (nonatomic,retain) IBOutlet NSButton *segmentToggle;
@property (nonatomic,retain) IBOutlet NSButton *languageToggle;
@property (nonatomic,retain) IBOutlet NSButton *channelToggle;
@property (nonatomic,retain) IBOutlet NSTextField *marketingContextField;
@property (nonatomic,retain) IBOutlet NSTextField *marketingContextShortField;
@property (nonatomic,retain) IBOutlet NSButton *chooseButton;
@property (nonatomic,retain) IBOutlet NSButton *cancelButton;
@property (nonatomic,retain) IBOutlet NSObjectController *marketingContextController;
@property (nonatomic,retain) IBOutlet NSArrayController *storefrontController;
@property (nonatomic,retain) IBOutlet NSSplitView *splitView;
@property (nonatomic,retain) IBOutlet NSView *tablesContainer;
@property (nonatomic,retain) IBOutlet NSCollectionView *storefrontCollection;
@property (nonatomic,retain) IBOutlet NSSearchField *storefrontsFilterField;
@property (nonatomic,retain) IBOutlet NSMenu *storefrontsFilterMenu;
@property (nonatomic,retain) IBOutlet NSPopUpButton *favoritesPopUp;
@property (nonatomic,retain) AJRMarketingContext *marketingContext;
@property (nonatomic,retain) AJRStorefront *storefront;
@property (nonatomic,retain) NSArray *storefronts;
@property (readonly) AJRStorefrontService *storefrontService;
@property (nonatomic,assign) BOOL showDescendentStorefronts;
@property (nonatomic,assign) BOOL showCustomStorefronts;
@property (nonatomic,assign) BOOL showDisabledStorefronts;
@property (nonatomic,assign) NSInteger storefrontFetchLimit;
@property (nonatomic,assign) NSUInteger partsMask;
@property (nonatomic,retain) NSView *accessoryView;

- (IBAction)choose:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)selectGeo:(id)sender;
- (IBAction)selectSegment:(id)sender;
- (IBAction)selectLanguage:(id)sender;
- (IBAction)selectChannel:(id)sender;
- (IBAction)selectStorefront:(id)sender;

- (IBAction)toggleSegmentOutline:(id)sender;
- (IBAction)toggleGeoOutline:(id)sender;
- (IBAction)toggleLanguageOutline:(id)sender;
- (IBAction)toggleChannelOutline:(id)sender;

- (IBAction)filterStorefronts:(id)sender;
- (IBAction)toggleDescendentStorefronts:(id)sender;
- (IBAction)toggleDisabledStorefronts:(id)sender;
- (IBAction)toggleCustomStorefronts:(id)sender;

+ (NSString *)favoritesKeyForMarketingContext:(AJRMarketingContext *)marketingContext 
                                andStorefront:(AJRStorefront *)storefront;
+ (NSArray *)favorites;
+ (BOOL)isFavoriteStorefront:(AJRStorefront *)storefront;
+ (BOOL)isFavoriteMarketingContext:(AJRMarketingContext *)marketingContext;
+ (BOOL)addStorefrontToFavorites:(AJRStorefront *)storefront;
+ (BOOL)addMarketingContextToFavorites:(AJRMarketingContext *)marketingContext;
+ (BOOL)removeStorefrontFromFavorites:(AJRStorefront *)storefront;
+ (BOOL)removeMarketingContextFromFavorites:(AJRMarketingContext *)marketingContext;

@end


@interface NSObject (AJRMarketingContextChooserDelegate)

- (NSArray *)marketingContextChooser:(AJRMarketingContextChooser *)chooser
           needsStorefrontsFromArray:(NSArray *)storefronts;

- (NSArray *)marketingContextChooserNeedsSegments:(AJRMarketingContextChooser *)chooser;
- (NSArray *)marketingContextChooserNeedsGeos:(AJRMarketingContextChooser *)chooser;
- (NSArray *)marketingContextChooserNeedsLanguages:(AJRMarketingContextChooser *)chooser;
- (NSArray *)marketingContextChooserNeedsChannels:(AJRMarketingContextChooser *)chooser;

@end
