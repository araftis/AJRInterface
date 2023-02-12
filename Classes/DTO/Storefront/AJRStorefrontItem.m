/*
 AJRStorefrontItem.m
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
//  AJRStorefrontItem.m
//  AJRInterface
//
//  Created by Alex Raftis on 2/6/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import "AJRStorefrontItem.h"

#import "AJRBorder.h"
#import "AJRBox.h"
#import "AJRGeo-UI.h"
#import "AJRLineBorder.h"
#import "AJRMarketingContextChooser.h"
#import "AJRSolidFill.h"
#import "NSWindow-Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <QuartzCore/QuartzCore.h>

@implementation AJRStorefrontItem

- (id)init
{
    if ((self = [super init])) {
        self.textColor = [NSColor blackColor];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_alternateView release];
    [_primaryView release];
    [_toggleFavoritesButton release];
    [_textColor release];
    
    [super dealloc];
}

@synthesize alternateView = _alternateView;
@synthesize textColor = _textColor;
@synthesize toggleFavoritesButton = _toggleFavoritesButton;

- (void)_observeWindow:(NSWindow *)window
{
    if ([self isSelected]) {
        if (window == nil) window = [[self view] window];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotification:) name:NSWindowDidBecomeKeyNotification object:window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotification:) name:NSWindowDidBecomeMainNotification object:window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotification:) name:NSWindowDidResignKeyNotification object:window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotification:) name:NSWindowDidResignMainNotification object:window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotification:) name:AJRWindowDidChangeFirstResponderNotification object:window];
    }
}

- (NSColor *)_computedtTextColor
{
    NSView            *view = [self view];
    NSWindow        *window = [view window];
    
    if ([self isSelected] && 
        [window firstResponder] == [self collectionView] &&
        [window isKeyWindow] &&
        [NSApp isActive]) {
        return [NSColor whiteColor];
    } else {
        return [NSColor blackColor];
    }
}

- (NSView *)view
{
    NSView        *view = [super view];
    
    if (_primaryView == nil) {
        _primaryView = [[(AJRBox *)view contentView] retain];
        [self performSelector:@selector(_observeWindow:) withObject:nil afterDelay:0.1];
    }
    
    return view;
}

- (void)_updateFillColors
{
    AJRSolidFill        *fill = (AJRSolidFill *)[(AJRBox *)[self view] contentFill];

    if ([self isSelected]) {
        [fill setColor:[NSColor alternateSelectedControlColor]];
        [fill setUnfocusedColor:[NSColor secondarySelectedControlColor]];
        self.textColor = [self _computedtTextColor];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [fill setColor:[NSColor whiteColor]];
        [fill setUnfocusedColor:[NSColor whiteColor]];
        self.textColor = [NSColor blackColor];
    }
}

- (void)setSelected:(BOOL)flag
{
    AJRBox            *view;
    
    [super setSelected:flag];
    
    view = (AJRBox *)[self view];

    if (!flag && [view contentView] != _primaryView) {
        [view animateSetContentView:_primaryView];
    }
        
    if (flag) {
        NSWindow    *window = [[self view] window];
        
        [self _updateFillColors];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotificationBefore:) name:NSApplicationWillBecomeActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotificationBefore:) name:NSApplicationWillResignActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotificationAfter:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayForNotificationAfter:) name:NSApplicationDidResignActiveNotification object:NSApp];
        
        //if (window) {
            [self _observeWindow:window];
        //}
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self _updateFillColors];
    }
    [view setNeedsDisplay:YES];
}

- (void)displayForNotification:(NSNotification *)notification
{
    [[self view] setNeedsDisplay:YES];
    [self _updateFillColors];
    self.textColor = [self _computedtTextColor];
}

- (void)displayForNotificationBefore:(NSNotification *)notification
{
    [[self view] setNeedsDisplay:YES];
    self.textColor = [self _computedtTextColor];
    [self willChangeValueForKey:@"textColor"];
}

- (void)displayForNotificationAfter:(NSNotification *)notification
{
    [[self view] setNeedsDisplay:YES];
    self.textColor = [self _computedtTextColor];
    [self didChangeValueForKey:@"textColor"];
}

+ (NSSet *)keyPathsForValuesAffectingTextColor
{
    return [NSSet setWithObjects:@"selected", @"application.active", nil];
}

- (NSApplication *)application
{
    return NSApp;
}

- (void)_updateFavoritesButtonText
{
    AJRStorefront    *storefront = [self representedObject];
    
    if ([AJRMarketingContextChooser isFavoriteStorefront:storefront]) {
        [_toggleFavoritesButton setTitle:@"Remove from Favorites"];
    } else {
        [_toggleFavoritesButton setTitle:@"Add to Favorites"];
    }
}

- (IBAction)toggleSettings:(id)sender
{
    AJRBox        *view = (AJRBox *)[self view];
    
    //AJRPrintf(@"%C: toggle settings\n", self);
    
    // Make sure our collection is now the focused view
    [[[self collectionView] window] makeFirstResponder:[self collectionView]];
    
    if (_alternateView == nil) {
        [NSBundle loadNibNamed:@"AJRStorefrontItemAltView" owner:self];
    }

    if ([view contentView] == _alternateView) {
        [view animateSetContentView:_primaryView];
    } else {
        [view animateSetContentView:_alternateView];
        [self _updateFavoritesButtonText];
    }
}

- (IBAction)toggleFavorites:(id)sender
{
    AJRStorefront    *storefront = [self representedObject];
    
    if ([AJRMarketingContextChooser isFavoriteStorefront:storefront]) {
        [AJRMarketingContextChooser removeStorefrontFromFavorites:storefront];
    } else {
        [AJRMarketingContextChooser addStorefrontToFavorites:storefront];
    }
    
    [self _updateFavoritesButtonText];
}

@end
