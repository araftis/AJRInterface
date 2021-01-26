//
//  AJRWebView.h
//  AJRInterface
//
//  Created by AJ Raftis on 1/24/19.
//

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

@interface AJRWebView : WKWebView <NSDraggingDestination>

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
