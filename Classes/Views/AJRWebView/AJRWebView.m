/*
 AJRWebView.m
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

#import "AJRWebView.h"

#import "AJRImages.h"
#import "AJRWindow.h"
#import "NSEvent+Extensions.h"
#import "NSImage+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterface/AJRInterface-Swift.h>
#import <WebKit/WebKit.h>

NSString * const MMWebElementKey = @"WebElementDOMNode";
NSString * const MMWebDocumentKey = @"MMWebDocumentKey";

// Yes, these are evil semi-globals, but they should be safe, because we're only going to access them via the main thread.
static AJRWebView *_activeWebView = nil;
static NSXMLDocument *_HTMLDocument = nil;
static NSXMLElement *_clickedElement = nil;

@interface _WKSessionState : NSObject

- (instancetype)initWithData:(NSData *)data;

@property (nonatomic, readonly, copy) NSData *data;

@end

@interface WKWebView (WKPrivate)

@property (nonatomic, readonly) _WKSessionState *_sessionState;
- (WKNavigation *)_restoreSessionState:(_WKSessionState *)sessionState andNavigate:(BOOL)navigate;
- (_WKSessionState *)_sessionStateWithFilter:(BOOL (^)(WKBackForwardListItem *item))filter;

@end

@interface NSControl (PrivateAdditions)

- (NSURL *)URLValue;

@end

@interface AJRNavigationDelegateProxy : NSObject <WKNavigationDelegate>

- (instancetype)initWithDelegate:(id <WKNavigationDelegate>)delegate;

@property (nonatomic,readonly) id <WKNavigationDelegate> delegate;

@end

@interface NSMenu (AJRMenuSwizzle)

@end

@implementation NSMenu (AJRMenuSwizzle)

+ (void)ajr_popUpContextMenu:(NSMenu*)menu withEvent:(NSEvent*)event forView:(NSView*)view {
	if (_activeWebView && _activeWebView == view && _HTMLDocument && _clickedElement && [[_activeWebView delegate] respondsToSelector:@selector(webView:contextMenuItemsForElement:defaultMenuItems:)]) {
		NSArray *defaultItems = [menu itemArray];
		NSDictionary *dictionary = @{MMWebElementKey:_clickedElement,
									 MMWebDocumentKey:_HTMLDocument,
									 };
		NSArray *additionalItems;
		
		@try {
			additionalItems = [[_activeWebView delegate] webView:_activeWebView contextMenuItemsForElement:dictionary defaultMenuItems:defaultItems];
		} @catch (NSException *localException) {
		} @finally {
			// Clear our globals as soon as possible
			_activeWebView = nil;
			_HTMLDocument = nil;
			_clickedElement = nil;
		}
		if (additionalItems) {
			NSMenu *newMenu = [menu copy];
			[newMenu insertItem:[NSMenuItem separatorItem] atIndex:0];
			for (NSMenuItem *item in [additionalItems reverseObjectEnumerator]) {
				[newMenu insertItem:item atIndex:0];
			}
			[self ajr_popUpContextMenu:newMenu withEvent:event forView:view];
		} else {
			[self ajr_popUpContextMenu:menu withEvent:event forView:view];
		}
	} else {
		[self ajr_popUpContextMenu:menu withEvent:event forView:view];
	}
}

@end

@interface AJRWebView ()

@property (nonatomic,strong) IBOutlet NSView *searchAccessory;
@property (nonatomic,strong) IBOutlet AJRForwardingSearchField *searchText;
@property (nonatomic,strong) IBOutlet NSSegmentedControl *searchNavigation;
@property (nonatomic,strong) IBOutlet NSTextField *searchMessage;
@property (nonatomic,strong) IBOutlet NSButton *searchButton;

@end

@implementation AJRWebView {
    AJRNavigationDelegateProxy *_navigationDelegateProxy; // We have to maintain a strong reference to our proxy.
    NSImage *_favoriteIcon;
    CGFloat _searchHeight;
    NSInteger _searchPasteboardChangeCount;
    NSTimer *_searchPasteboardTimer;
    
    NSTimer *_currentItemTimer;
    WKBackForwardListItem *_currentItem;
}

#pragma mark - Cache Favorite Icons

static NSCache *_favoriteIconCache;

+ (NSCache<NSString *, NSImage *> *)favoriteIconCache {
    if (_favoriteIconCache == nil) {
        _favoriteIconCache = [[NSCache alloc] init];
        [_favoriteIconCache setCountLimit:100];
    }
    return _favoriteIconCache;
}

+ (NSImage *)favoriteIconForHostName:(NSString *)hostName {
    return [[self favoriteIconCache] objectForKey:hostName];
}

+ (void)setFavoriteIcon:(NSImage *)image forHostName:(NSString *)hostName {
    if (image) {
        NSSize size = [image size];
        NSUInteger cost = (NSInteger)size.width * (NSInteger)size.height;
        [[self favoriteIconCache] setObject:image forKey:hostName cost:cost];
    }
}

+ (NSImage *)favoriteIconForURL:(NSURL *)url {
    NSString *host = url.host;
    if (host) {
        return [self favoriteIconForHostName:host];
    }
    return nil;
}

#pragma mark - Initialization

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AJRSwizzleClassMethods(objc_getClass("NSMenu"), @selector(popUpContextMenu:withEvent:forView:), objc_getClass("NSMenu"), @selector(ajr_popUpContextMenu:withEvent:forView:));
    });
}

#pragma mark - Creation

- (void)ajr_commonInit {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"AJRWebViewSearch" withExtension:@"js"];
    if (URL) {
        NSString *rawScript = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
        if (rawScript) {
            WKUserScript *script = [[WKUserScript alloc] initWithSource:rawScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
            [[[self configuration] userContentController] addUserScript:script];
        }
    } else {
        AJRLogWarning(@"Failed to find AJRWebViewSearch.js");
    }
    
    _currentItem = self.backForwardList.currentItem;
    __weak AJRWebView *weakSelf = self;
    _currentItemTimer = [NSTimer timerWithTimeInterval:0.25 repeats:YES block:^(NSTimer * _Nonnull timer) {
        AJRWebView *strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf->_currentItem != strongSelf.backForwardList.currentItem) {
                [self willChangeValueForKey:@"currentItem"];
                strongSelf->_currentItem = strongSelf.backForwardList.currentItem;
                [self didChangeValueForKey:@"currentItem"];
            }
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:_currentItemTimer forMode:NSDefaultRunLoopMode];
    
    [self registerForDraggedTypes:@[NSPasteboardTypeURL]];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if ((self = [super initWithFrame:frame configuration:configuration])) {
        [self ajr_commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self ajr_commonInit];
    }
    return self;
}

- (void)dealloc {
    [_currentItemTimer invalidate];
}

#pragma mark - JavaScript

- (id)evaluateJavaScript:(NSString *)javaScriptString error:(NSError **)error {
	id <AJRSemaphore> semaphore = [[AJRBasicSemaphore alloc] init];
	__block NSError *localError;
	__block id result;

	dispatch_async(dispatch_get_main_queue(), ^{
		[self evaluateJavaScript:javaScriptString completionHandler:^(id value, NSError *error) {
			localError = error;
			result = value;
			[semaphore signal];
		}];
	});
	[[NSRunLoop currentRunLoop] spinRunLoopInMode:NSDefaultRunLoopMode waitingForSemaphore:semaphore];

	if (localError && error == NULL) {
        AJRLogWarning(@"Issue while evaluating java script:\n%@\nerror: %@", javaScriptString, [localError localizedDescription]);
	}
	
	return AJRAssertOrPropagateError(result, error, localError);
}

- (NSString *)stringByClearingScriptElements:(NSString *)input {
	NSMutableString *result = [NSMutableString string];
	NSRange searchRange = (NSRange){0, [input length]};
	NSRange foundRange;
	
	while ((foundRange = [input rangeOfString:@"<script" options:NSCaseInsensitiveSearch range:searchRange]).location != NSNotFound) {
		[result appendString:[input substringWithRange:(NSRange){searchRange.location, foundRange.location - searchRange.location}]];
		searchRange.location = foundRange.location + foundRange.length;
		searchRange.length = [input length] - searchRange.location;
		NSRange closeRange = [input rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:searchRange];
		if (closeRange.length) {
			searchRange.location = closeRange.location + closeRange.length;
			searchRange.length = [input length] - searchRange.location;
		}
	}
	if (searchRange.location < [input length]) {
		[result appendString:[input substringFromIndex:searchRange.location]];
	}
	return result;
}

#pragma mark - DOM

- (NSXMLElement *)elementAtLocation:(NSPoint)where document:(NSXMLDocument **)documentOut {
	NSError *localError;
	__block NSXMLElement *foundElement = nil;

	// First, tag the element under where with the __ajr-canary attribute.
	NSString *result = [self evaluateJavaScript:AJRFormat(@"var element = document.elementFromPoint(%d, %d); element.setAttribute('id', '__ajr:' + element.id); document.documentElement.outerHTML", (int)where.x, (int)where.y) error:&localError];
	if (!result && localError) {
		AJRLogError(@"Error while evaluating JavaScript: %@", [localError localizedDescription]);
	} else if (result) {
		// OK, we got the element, so get the full document.
		// NOTE: Scripts at imdb.com were causing parsing issues, so just strip them out, since we don't care about them for our purposes, anyways.
		NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:[self stringByClearingScriptElements:result] options:NSXMLDocumentTidyHTML error:&localError];
		
		if (document) {
			[document enumerateDescendantsUsingBlock:^(NSXMLNode *node, BOOL *done) {
				NSXMLElement *possibleElement = AJRObjectIfKindOfClass(node, NSXMLElement);
				if (possibleElement && [[[possibleElement attributeForName:@"id"] stringValue] hasPrefix:@"__ajr:"]) {
					foundElement = possibleElement;
					*done = YES;
				}
			}];
			AJRSetOutParameter(documentOut, document);
		} else if (localError) {
			AJRLogWarning(@"Failed to parse HTML: %@", [localError localizedDescription]);
		}
		
		if (foundElement) {
			NSString *remove = [[(NSXMLElement *)foundElement attributeForName:@"id"] stringValue];
			localError = nil;
			if ([remove isEqualToString:@"__ajr:"]) {
				[foundElement removeAttributeForName:@"id"];
				result = [self evaluateJavaScript:AJRFormat(@"var element = document.elementFromPoint(%d, %d); element.removeAttribute('id'); element.outerHTML", (int)where.x, (int)where.y) error:&localError];
			} else if ([remove hasPrefix:@"__ajr:"]) {
				result = [self evaluateJavaScript:AJRFormat(@"var element = document.elementFromPoint(%d, %d); element.setAttribute('id', '%@'); element.outerHTML", (int)where.x, (int)where.y, [remove substringFromIndex:5]) error:&localError];
				[[foundElement attributeForName:@"id"] setStringValue:[remove substringFromIndex:5]];
			}
			if (localError) {
				AJRLogWarning(@"Error while resetting canary: %@", [localError localizedDescription]);
			}
		}
	}
	
	return foundElement;
}

- (NSXMLDocument *)document {
	__block NSXMLDocument *document = nil;
	NSError *localError;
	NSString *raw = [self evaluateJavaScript:@"document.documentElement.outerHTML" error:&localError];

	if (raw && !localError) {
		document = [[NSXMLDocument alloc] initWithXMLString:raw options:NSXMLDocumentTidyHTML error:&localError];
	}
	
	return document;
}

#pragma mark - Selection

- (BOOL)hasSelection {
	NSError *localError;
	NSString *result = [self evaluateJavaScript:@"!document.getSelection().isCollapsed" error:&localError];
	return result ? [result boolValue] : NO;
}

- (NSString *)selectedText {
	return [self evaluateJavaScript:@"document.getSelection().toString()" error:NULL];
}

#pragma mark - Properties

+ (NSImage *)defaultFavoriteIcon {
    static NSImage *defaultIcon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultIcon = [AJRImages imageNamed:@"AJRWebGenericLocation" forClass:[AJRWebView class]];
    });
    return defaultIcon;
}

- (void)setFavoriteIcon:(NSImage *)favoriteIcon {
    _favoriteIcon = favoriteIcon;
}

- (NSImage *)favoriteIcon {
    return _favoriteIcon ?: [[self class] defaultFavoriteIcon];
}

#pragma mark - First Responder

- (void)rightMouseDown:(NSEvent *)event {
	NSPoint where = [event ajr_locationInView:self];
	NSXMLDocument *document = nil;
	NSXMLElement *element = nil;
	
	element = [self elementAtLocation:where document:&document];
	if (element) {
		AJRPrintf(@"element: %@\n", element);
	}
	
	if (document && element) {
		_activeWebView = self;
		_HTMLDocument = document;
		_clickedElement = element;
	}
	[super rightMouseDown:event];
}

#pragma mark - Actions

- (IBAction)takeURLFrom:(id)sender {
    if ([sender respondsToSelector:@selector(URLValue)]) {
        [self loadRequest:[NSURLRequest requestWithURL:[sender URLValue]]];
    }
}

#pragma mark - Search

- (IBAction)navigateSearch:(NSSegmentedControl *)sender {
    if ([sender selectedSegment] == 0) {
        [self findPrevious:sender];
    } else if ([sender selectedSegment] == 1) {
        [self findNext:sender];
    }
}

- (void)addStringToSearchPasteboard:(NSString *)string {
    NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSPasteboardNameFind];
    if ([string length] == 0) {
        [pBoard clearContents];
    } else {
        [pBoard declareTypes:@[NSPasteboardTypeString] owner:self];
        [pBoard setString:string forType:NSPasteboardTypeString];
    }
    _searchPasteboardChangeCount = [pBoard changeCount];
}

- (void)addSelectionToSearchPasteboard {
    [self addStringToSearchPasteboard:[self selectedText]];
}

- (IBAction)takeSearchFrom:(id)searchField {
    [self addStringToSearchPasteboard:[searchField stringValue]];
    [self findNextByForcingNewSearch:YES];
}

- (NSView *)flippedView {
    if (_searchAccessory == nil) {
        return [self.subviews firstObject];
    }
    for (NSView *view in self.subviews) {
        if (view != _searchAccessory) {
            return view;
        }
    }
    return nil;
}

- (BOOL)isSearchBarVisible {
    return _searchAccessory && _searchAccessory.superview != nil;
}

- (IBAction)showSearchBar:(id)sender {
    if (_searchAccessory == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [bundle loadNibNamed:@"AJRWebFindBar" owner:self topLevelObjects:nil];
        _searchHeight = _searchAccessory.frame.size.height;
        _searchText.receivingView = self;
    }
    
    if ([_searchAccessory superview] == nil) {
        [self addSubview:_searchAccessory];
        [[self window] makeFirstResponder:_searchText];
        
        if (_searchPasteboardTimer) {
            [_searchPasteboardTimer invalidate];
        }
        _searchPasteboardChangeCount = -1;
        _searchPasteboardTimer = [NSTimer timerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSInteger newChangeCount = [[NSPasteboard pasteboardWithName:NSPasteboardNameFind] changeCount];
            if (newChangeCount != self->_searchPasteboardChangeCount) {
                NSPasteboard *searchPBoard = [NSPasteboard pasteboardWithName:NSPasteboardNameFind];
                NSString *string = [searchPBoard stringForType:NSPasteboardTypeString];
                if (string) {
                    if (![self->_searchText.stringValue isEqualToString:string]) {
                        self->_searchText.stringValue = string;
                    }
                    [self findNextByForcingNewSearch:YES];
                } else {
                    self->_searchText.stringValue = @"";
                    [self->_searchMessage setStringValue:@""];
                    [self removeFindHighlights];
                }
                self->_searchPasteboardChangeCount = newChangeCount;
            }
        }];
        // Force an initial update
        [_searchPasteboardTimer fire];
        [[NSRunLoop currentRunLoop] addTimer:_searchPasteboardTimer forMode:NSDefaultRunLoopMode];

        // Register with out window, potentially, to intercept some events and keys.
        AJRWindow *window = AJRObjectIfKindOfClass(self.window, AJRWindow);
        if (window) {
            [window addTargetBypassTo:self forAction:@selector(performFindPanelAction:)];
            [window addKeyBypassTo:self forKeyCode:53 withModifiers:0];
        }

        [self setNeedsLayout:YES];
    }
    
    // And, no matter what happens, focus the search bar.
    [self.window makeFirstResponder:_searchText];
}

- (IBAction)hideSearchBar:(id)sender {
    if (self.isSearchBarVisible) {
        [self removeFindHighlights];
        [_searchAccessory removeFromSuperview];
        [self setNeedsLayout:YES];
        [_searchPasteboardTimer invalidate];
        _searchPasteboardTimer = nil;

        AJRWindow *window = AJRObjectIfKindOfClass(self.window, AJRWindow);
        if (window) {
            [window removeTargetBypassForAction:@selector(performFindPanelAction:)];
            [window removeKeyBypassForKeyCode:53 withModifiers:0];
        }
        
        // And make ourself the first responder
        [self.window makeFirstResponder:self];
    }
}

- (void)searchForText:(NSString *)text withSelectionBehavior:(AJRWebSelectionBehavior)behavior {
    [self evaluateJavaScript:AJRFormat(@"_AJRHighlightAllOccurencesOfString('%@', %@)", text, self.isSearchBarVisible ? @"true" : @"false") error:NULL];
    
    NSNumber *result = [self evaluateJavaScript:@"_AJRSearchResultCount" error:NULL];
    if ([result integerValue] == 0) {
        [_searchMessage setStringValue:[self valueForKeyPath:@"translator.Not Found"]];
    } else if ([result integerValue] == 1) {
        [_searchMessage setStringValue:AJRFormat([self valueForKeyPath:@"translator.Match"], (int)[result integerValue])];
    } else {
        [_searchMessage setStringValue:AJRFormat([self valueForKeyPath:@"translator.Matches"], (int)[result integerValue])];
    }
    
    if ([result integerValue] > 0) {
        switch (behavior) {
            case AJRWebSelectionBehaviorNone:
                break;
            case AJRWebSelectionBehaviorFirst:
                [self evaluateJavaScript:@"_AJRSelectSearchedText(0);" error:NULL];
                break;
            case AJRWebSelectionBehaviorLast:
                [self evaluateJavaScript:AJRFormat(@"_AJRSelectSearchedText(%d);", (int)[result integerValue] - 1) error:NULL];
                break;
        }
    }
}

- (NSString *)_textToFind {
    NSString *string;
    
    if (self.isSearchBarVisible) {
        string = _searchText.stringValue;
    } else {
        NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSPasteboardNameFind];
        string = [pBoard stringForType:NSPasteboardTypeString];
    }
    
    return string;
}

- (NSInteger)numberOfSearchResults {
    return [[self evaluateJavaScript:@"_AJRSearchResultCount" error:NULL] intValue];
}

- (void)findNextByForcingNewSearch:(BOOL)flag {
    NSString *textToFind = [self _textToFind];
    
    if ([self numberOfSearchResults] == 0) {
        // Force a research, because we don't currently have a search.
        flag = YES;
    }
    
    if (textToFind.length == 0) {
        [self removeFindHighlights];
    } else if (flag) {
        [self searchForText:textToFind withSelectionBehavior:AJRWebSelectionBehaviorFirst];
    } else {
        if (![[self evaluateJavaScript:@"_AJRSelectNext()" error:NULL] boolValue]) {
            NSBeep();
        }
    }
}

- (IBAction)findNext:(id)sender {
    [self findNextByForcingNewSearch:NO];
}

- (void)findPreviousByForcingNewSearch:(BOOL)flag {
    NSString *textToFind = [self _textToFind];
    
    if ([self numberOfSearchResults] == 0) {
        // Force a research, because we don't currently have a search.
        flag = YES;
    }
    
    if (textToFind.length == 0) {
        [self removeFindHighlights];
    } else if (flag) {
        [self searchForText:textToFind withSelectionBehavior:AJRWebSelectionBehaviorLast];
    } else {
        AJRPrintf(@"previous: %@\n", [self evaluateJavaScript:@"_AJRSelectPrevious()" error:NULL]);
    }
}

- (IBAction)findPrevious:(id)sender {
    [self findPreviousByForcingNewSearch:NO];
}

- (IBAction)performFindPanelAction:(id)sender {
    switch ([sender tag]) {
        case NSFindPanelActionShowFindPanel:
            [self showSearchBar:self];
            break;
        case NSFindPanelActionNext:
            [self findNext:sender];
            break;
        case NSFindPanelActionPrevious:
            [self findPrevious:sender];
            break;
        case NSFindPanelActionSetFindString:
            [self addSelectionToSearchPasteboard];
            break;
    }
}

- (void)removeFindHighlights {
    [self evaluateJavaScript:@"_AJRRemoveAllHighlights()" error:NULL];
    [_searchMessage setStringValue:@""];
}

- (BOOL)keyDownInWindow:(NSEvent *)event {
    if ([event keyCode] == 53
        && ([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == 0
        && [_searchAccessory superview] != nil) {
        [self hideSearchBar:nil];
        return true;
    }
    return false;
}

#pragma mark - NSView - Layout

- (void)layout {
    NSView *flipped = [self flippedView];
    
    if (flipped) {
        //AJRPrintf(@"flipped: %@, search: %@\n", flipped, _searchAccessory);
        if (_searchAccessory && _searchAccessory.superview != nil) {
            NSRect bounds = [self bounds];
            NSRect searchRect = bounds;
            NSRect flippedRect = bounds;
            
            searchRect.size.height = _searchHeight;
            searchRect.origin.y = 0.0;
            _searchAccessory.frame = searchRect;
            
            flippedRect.size.height -= _searchHeight;
            flippedRect.origin.y += _searchHeight;
            flipped.frame = flippedRect;
        } else {
            [flipped setFrame:[self bounds]];
        }
    } else {
        [super layout];
    }
}

// These basically workaround a "bug" in WKWebView, because the superclass always things it's flipped view is going to have the same coordinate system as itself, but when we insert the search bar, we break that assumption. As such, the methods method "fix" that assumption by having the flipped view do the translation.
- (NSPoint)convertPoint:(NSPoint)point fromView:(nullable NSView *)view {
    return [[self flippedView] convertPoint:point fromView:view];
}

//- (NSPoint)convertPoint:(NSPoint)point toView:(nullable NSView *)view {
//    return [[self flippedView] convertPoint:point toView:view];
//}

- (NSRect)convertRect:(NSRect)rect toView:(nullable NSView *)view {
    return [[self flippedView] convertRect:rect toView:view];
}

- (NSRect)convertRect:(NSRect)rect fromView:(nullable NSView *)view {
    return [[self flippedView] convertRect:rect fromView:view];
}

#pragma mark - Loading Content

// These are all overridden just to hide the search bar if it's visible.

- (WKNavigation *)loadRequest:(NSURLRequest *)request {
    [self hideSearchBar:nil];
    return [super loadRequest:request];
}

- (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [self hideSearchBar:nil];
    return [super loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    [self hideSearchBar:nil];
    return [super loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL {
    [self hideSearchBar:nil];
    return [super loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

#pragma mark - Navigation

- (void)setHomeURL:(NSURL *)homeURL {
    [[NSUserDefaults standardUserDefaults] setURL:homeURL forKey:@"homeURL"];
}

- (NSURL *)homeURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:@"homeURL"];
}

- (void)setNavigationDelegate:(id <WKNavigationDelegate>)navigationDelegate {
    if (navigationDelegate) {
        _navigationDelegateProxy = [[AJRNavigationDelegateProxy alloc] initWithDelegate:navigationDelegate];
        [super setNavigationDelegate:_navigationDelegateProxy];
    } else {
        [super setNavigationDelegate:nil];
    }
}

- (WKNavigation *)goHome {
    NSURL *homeURL = [self homeURL];
    
    if (homeURL) {
        return [self loadRequest:[NSURLRequest requestWithURL:homeURL]];
    }
    
    return nil;
}

- (IBAction)goHome:(id)sender {
    [self goHome];
}

- (WKBackForwardListItem *)currentItem {
    return _currentItem;
}

#pragma mark - Web State

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    NSData *data = [[self _sessionState] data];
    if (data) {
        [coder encodeObject:data forKey:@"webState"];
        
        // Encode appropriate favorite icons, so that our menus look pretty.
        NSMutableDictionary<NSString *, NSImage *> *images = [NSMutableDictionary dictionary];
        for (WKBackForwardListItem *item in self.backForwardList.backList) {
            NSString *hostName = item.URL.host;
            if (hostName != nil) {
                [images setObjectIfNotNil:[AJRWebView favoriteIconForHostName:hostName] forKey:hostName];
            }
        }
        for (WKBackForwardListItem *item in self.backForwardList.forwardList) {
            NSString *hostName = item.URL.host;
            if (hostName != nil) {
                [images setObjectIfNotNil:[AJRWebView favoriteIconForHostName:hostName] forKey:hostName];
            }
        }
        [coder encodeObject:images forKey:@"webFavoriteIcons"];
    }
}

- (WKNavigation *)restoreStateWithCoder:(NSCoder *)coder andNavigate:(BOOL)flag {
    WKNavigation *navigation = nil;
    NSData *data = [coder decodeObjectForKey:@"webState"];
    
    if (data) {
        _WKSessionState *sessionState = [[_WKSessionState alloc] initWithData:data];
        if (sessionState) {
            navigation = [self _restoreSessionState:sessionState andNavigate:YES];
        }
    }
    
    NSDictionary<NSString *, NSImage *> *images = [coder decodeObjectForKey:@"webFavoriteIcons"];
    if (images) {
        [images enumerateKeysAndObjectsUsingBlock:^(NSString *host, NSImage *image, BOOL *stop) {
            [AJRWebView setFavoriteIcon:image forHostName:host];
        }];
    }
    
    return navigation;
}

- (NSData *)restorableStateData {
    NSKeyedArchiver *keyedArchiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [self encodeRestorableStateWithCoder:keyedArchiver];
    [keyedArchiver finishEncoding];
    return [keyedArchiver encodedData];
}

- (WKNavigation *)restoreFromStateData:(NSData *)data andNavigate:(BOOL)flag {
    WKNavigation *navigation = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:NULL];
    
    if (unarchiver) {
        navigation = [self restoreStateWithCoder:unarchiver andNavigate:flag];
        [unarchiver finishDecoding];
    }
    
    return navigation;
}

#pragma mark - Zoom

- (IBAction)resetMagnification:(id)sender {
    self.magnification = 1.0;
}

- (IBAction)increaseMagnification:(id)sender {
    CGFloat magnification = self.magnification + 0.25;
    if (magnification > 4.0) {
        magnification = 4.0;
    }
    self.magnification = magnification;
}

- (IBAction)decreaseMagnification:(id)sender {
    CGFloat magnification = self.magnification - 0.25;
    if (magnification < 0.25) {
        magnification = 0.25;
    }
    self.magnification = magnification;
}

#pragma mark - NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL action = [menuItem action];
    
    if (action == @selector(resetMagnification:)) {
        return self.magnification != 1.0;
    } else if (action == @selector(increaseMagnification:)) {
        return self.magnification < 4.0;
    } else if (action == @selector(decreaseMagnification:)) {
        return self.magnification > 0.25;
    } else if (action == @selector(stopLoading:)) {
        return self.isLoading;
    } else if (action == @selector(hideSearchBar:)) {
        return _searchAccessory.superview != nil;
    }
    
    return YES;
}

#pragma mark - NSDraggingDestination

typedef NSDragOperation (*AJRDraggingEnteredIMP)(id, SEL, id);

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if ([[[sender draggingPasteboard] types] containsObject:NSPasteboardTypeURL]) {
        return NSDragOperationCopy;
    }
    
    // These hoops to jump through are here, because WKWebView implements these methods, but doesn't declare them, and since they're not strictly speaking public, we can't depend on them being there in the future.
    AJRDraggingEnteredIMP superImp = (AJRDraggingEnteredIMP)[[[self class] superclass] instanceMethodForSelector:@selector(draggingEntered:)];
    if (superImp) {
        return superImp(self, _cmd, sender);
    }
    return NSDragOperationNone;
}

typedef NSDragOperation (*AJRDraggingUpdatedIMP)(id, SEL, id);

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    if (NSMouseInRect([self convertPoint:[sender draggingLocation] fromView:nil], [self bounds], NO)) {
        return NSDragOperationCopy;
    }
    
    AJRDraggingUpdatedIMP superImp = (AJRDraggingUpdatedIMP)[[[self class] superclass] instanceMethodForSelector:@selector(draggingUpdated:)];
    if (superImp) {
        return superImp(self, _cmd, sender);
    }
    
    return NSDragOperationNone;
}

typedef BOOL (*AJRPerformDragOperationIMP)(id, SEL, id);

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    if (NSMouseInRect([self convertPoint:[sender draggingLocation] fromView:nil], [self bounds], NO)) {
        NSURL *URL = [NSURL URLWithString:[[sender draggingPasteboard] stringForType:NSPasteboardTypeURL]];
        if (URL) {
            [self loadRequest:[NSURLRequest requestWithURL:URL]];
        }
    }

    AJRPerformDragOperationIMP superImp = (AJRPerformDragOperationIMP)[[[self class] superclass] instanceMethodForSelector:@selector(performDragOperation:)];
    if (superImp) {
        return superImp(self, _cmd, sender);
    }
    
    return NO;
}

#pragma mark - Debugging

- (void)beginGestureWithEvent:(NSEvent *)event {
    AJRLogDebug(@"-[%C %S]: %@\n", self, _cmd, event);
    [super beginGestureWithEvent:event];
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    AJRLogDebug(@"-[%C %S]: %@\n", self, _cmd, event);
    [super touchesBeganWithEvent:event];
}

- (void)scrollWheel:(NSEvent *)event {
    //AJRLogDebug(@"-[%C %S]: %@\n", self, _cmd, event);
    [super scrollWheel:event];
}

- (NSSize)convertSize:(NSSize)size fromView:(nullable NSView *)view {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertSize:size fromView:view];
}

- (NSSize)convertSize:(NSSize)size toView:(nullable NSView *)view {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertSize:size toView:view];
}

- (NSPoint)convertPointToBacking:(NSPoint)point {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertPointToBacking:point];
}

- (NSPoint)convertPointFromBacking:(NSPoint)point {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertPointFromBacking:point];
}

- (NSSize)convertSizeToBacking:(NSSize)size {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertSizeToBacking:size];
}

- (NSSize)convertSizeFromBacking:(NSSize)size {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertSizeFromBacking:size];
}

- (NSRect)convertRectToBacking:(NSRect)rect {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertRectToBacking:rect];
}

- (NSRect)convertRectFromBacking:(NSRect)rect {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertRectFromBacking:rect];
}

- (NSPoint)convertPointToLayer:(NSPoint)point {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertPointToLayer:point];
}

- (NSPoint)convertPointFromLayer:(NSPoint)point {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertPointFromLayer:point];
}

- (NSSize)convertSizeToLayer:(NSSize)size {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertSizeToLayer:size];
}

- (NSSize)convertSizeFromLayer:(NSSize)size {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertSizeFromLayer:size];
}

- (NSRect)convertRectToLayer:(NSRect)rect {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertRectToLayer:rect];
}

- (NSRect)convertRectFromLayer:(NSRect)rect {
    AJRLogDebug(@"-[%C %S]\n", self, _cmd);
    return [super convertRectFromLayer:rect];
}

@end

#pragma mark -

@implementation AJRNavigationDelegateProxy {
    __weak id <WKNavigationDelegate> _delegate;
    NSURL *_provisionalURL;
}

- (instancetype)initWithDelegate:(id <WKNavigationDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_delegate respondsToSelector:aSelector] || [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return self;
    }
    if ([_delegate respondsToSelector:aSelector]) {
        return _delegate;
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    _provisionalURL = [webView URL];
    NSImage *cachedIcon = nil;
    if (_provisionalURL.host != nil && (cachedIcon = [AJRWebView favoriteIconForHostName:_provisionalURL.host]) != nil) {
        [AJRObjectIfKindOfClass(webView, AJRWebView) setFavoriteIcon:cachedIcon];
    } else {
        [AJRObjectIfKindOfClass(webView, AJRWebView) setFavoriteIcon:nil];
    }
    if ([_delegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [_delegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSURL *faviconURL = [NSURL URLWithString:AJRFormat(@"https://%@/favicon.ico", webView.URL.host)];
    __weak WKWebView *weakWebView = webView;
    [NSImage ajr_imageWithContentsOfURL:faviconURL completionHandler:^(NSImage *image) {
        WKWebView *strongWebView = weakWebView;
        if (strongWebView != nil) {
            [image setSize:(NSSize){16.0, 16.0}];
            [AJRObjectIfKindOfClass(strongWebView, AJRWebView) setFavoriteIcon:image];
            if (faviconURL.host != nil) {
                [AJRWebView setFavoriteIcon:image forHostName:faviconURL.host];
            }
        }
    }];
    
    if ([_delegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [_delegate webView:webView didFinishNavigation:navigation];
    }
    _provisionalURL = nil;
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p: fowarding to: %@>", self, self, _delegate);
}

@end
