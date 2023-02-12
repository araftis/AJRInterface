/*
 AJRWebView.h
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

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRWebSelectionBehavior) {
    AJRWebSelectionBehaviorNone,
    AJRWebSelectionBehaviorFirst,
    AJRWebSelectionBehaviorLast,
};

extern NSString * const MMWebElementKey;
extern NSString * const MMWebDocumentKey;

@class AJRWebView, AJRForwardingSearchField;

@protocol AJRWebViewUIDelegate <NSObject>

- (NSArray<NSMenuItem *> *)webView:(AJRWebView *)sender contextMenuItemsForElement:(NSDictionary *)elementInformation defaultMenuItems:(NSArray<NSMenuItem *> *)defaultMenuItems;

@end

@interface AJRWebView : WKWebView <NSDraggingDestination, NSMenuItemValidation>

@property (nullable,nonatomic,weak) id <AJRWebViewUIDelegate> delegate;
@property (nonatomic,class,readonly) NSImage *defaultFavoriteIcon;
@property (null_resettable,nonatomic,readonly) NSImage *favoriteIcon;

#pragma mark - Favorite Icon Caching

+ (nullable NSImage *)favoriteIconForHostName:(NSString *)hostName;
+ (void)setFavoriteIcon:(NSImage *)image forHostName:(NSString *)hostName;
+ (nullable NSImage *)favoriteIconForURL:(NSURL *)url;

#pragma mark - JavaScript

- (id)evaluateJavaScript:(NSString *)javaScriptString error:(NSError * __nullable * __nullable)error;

/*! Returns the contents of the web view as an NSXMLDocument, so that you can traverse the DOM. */
@property (nonatomic,readonly) NSXMLDocument *document;

- (NSString *)selectedText;
- (BOOL)hasSelection;

#pragma mark - Find

@property (nonatomic,readonly) BOOL isSearchBarVisible;

- (IBAction)showSearchBar:(nullable id)sender;
- (IBAction)hideSearchBar:(nullable id)sender;
- (IBAction)navigateSearch:(nullable NSSegmentedControl *)sender;

- (IBAction)takeSearchFrom:(nullable id)searchField;
- (IBAction)findNext:(nullable id)sender;
- (IBAction)findPrevious:(nullable id)sender;
- (IBAction)performFindPanelAction:(nullable id)sender;

@property (nonatomic,readonly) NSInteger numberOfSearchResults;
/** Triggers a new search (clearing the previous search) and selects text within the document based on behavior. */
- (void)searchForText:(NSString *)text withSelectionBehavior:(AJRWebSelectionBehavior)behavior;

#pragma mark - Navigation

- (IBAction)takeURLFrom:(nullable id)sender;

// An observable mirror of self.backForwardList.currentItem.
@property (nullable,nonatomic,readonly) WKBackForwardListItem *currentItem;

@property (nullable,nonatomic,strong) NSURL *homeURL;
- (nullable WKNavigation *)goHome;
- (IBAction)goHome:(id)sender;

#pragma mark - Web State

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder;
- (WKNavigation *)restoreStateWithCoder:(NSCoder *)coder andNavigate:(BOOL)flag;

- (NSData *)restorableStateData;
- (WKNavigation *)restoreFromStateData:(NSData *)data andNavigate:(BOOL)flag;

#pragma mark - Zoom

- (IBAction)resetMagnification:(id)sender;
- (IBAction)increaseMagnification:(id)sender;
- (IBAction)decreaseMagnification:(id)sender;

@end

NS_ASSUME_NONNULL_END
