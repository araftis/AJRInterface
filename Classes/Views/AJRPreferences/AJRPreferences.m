/*
 AJRPreferences.m
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

#import "AJRPreferences.h"

#import "AJRPreferencesModule.h"
#import "NSAlert+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

static NSMutableDictionary *_modules;
static NSMutableArray *_preferredModuleNames;

@implementation AJRPreferences {
    NSToolbar *_toolbar;
}

#pragma mark - Initialization

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _modules = [[NSMutableDictionary alloc] init];
        _preferredModuleNames = [[NSMutableArray alloc] init];
    });
}

#pragma mark - Creation

+ (id)allocWithZone:(NSZone *)zone {
    static AJRPreferences *SELF = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SELF = [super allocWithZone:zone];
    });
    return SELF;
}

+ (id)sharedInstance {
    return [[self alloc] init];
}

+ (void)registerPreferencesModule:(Class)moduleClass properties:(NSDictionary *)properties {
    @autoreleasepool {
        AJRPreferencesModule *module = [[moduleClass alloc] init];
        NSString *name = [properties objectForKey:@"name"];
        BOOL preferred = [[properties objectForKey:@"preferred"] boolValue];
        
        if ([name hasPrefix:@"_"]) {
            // Ignore these, they're private.
        } else {
            [_modules setObject:module forKey:name];
            if (preferred) {
                [_preferredModuleNames addObject:name];
                [_preferredModuleNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
            }
        }
        
        AJRLogDebug(@"AJRPreferencesModule: %@", moduleClass);
    }
}

- (id)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_displayNeedsRefresh = YES;
    });
    return self;
}

#pragma mark - Utilities

- (void)update {
    NSArray *cells;
    NSInteger x;
    NSArray *names = [self names];
    NSInteger moduleCount = [names count];
    AJRPreferencesModule *module;
    NSButtonCell *cell;
    
    cells = [self.moduleMatrix cells];
    for (x = 0; x < (const NSInteger)[cells count]; x++) {
        cell = [cells objectAtIndex:x];
        if (x < moduleCount) {
            module = [_modules objectForKey:[names objectAtIndex:x]];
            [cell setTitle:[module name]];
            [cell setImage:[module image]];
            [cell setTransparent:NO];
            [cell setTarget:self];
            [cell setAction:@selector(selectModule:)];
            [cell setRepresentedObject:[module name]];
        } else {
            [cell setTransparent:YES];
            [cell setTarget:nil];
            [cell setAction:NULL];
            [cell setRepresentedObject:nil];
        }
    }
    
    self.displayNeedsRefresh = NO;
}

#pragma mark - Running

- (void)run {
    [self panel];
    if (self.displayNeedsRefresh) {
        [self update];
    }
    [self.panel makeKeyAndOrderFront:self];
}

- (void)runWithModuleNamed:(NSString *)aPanelName {
    [self run];
    [self selectModuleNamed:aPanelName];
}

#pragma mark Properties

- (NSPanel *)panel {
    if (!_panel) {
        if (![[NSBundle bundleForClass:[self class]] loadNibNamed:@"AJRPreferencesPanel" owner:self topLevelObjects:nil]) {
            AJRBeginAlertPanel(NSAlertStyleCritical, @"Unable to load AJRPrefrencesPanel.nib", @"OK", nil, nil, nil, ^(NSModalResponse response) {
                [NSApp terminate:self];
            });
        }
    }
    return _panel;
}

#pragma mark - NSNibAwakening

- (void)awakeFromNib {
    [self.allView removeFromSuperview];
    [self.panel setContentView:self.allView];
    
    _toolbar = [[NSToolbar allocWithZone:nil] initWithIdentifier:@"Preferences Window"];
    [_toolbar setDelegate:self];
    [_toolbar setAllowsUserCustomization:YES];
    [self.panel setToolbar:_toolbar];
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item;
    AJRPreferencesModule *module = [_modules objectForKey:itemIdentifier];
    
    item = [[NSToolbarItem allocWithZone:nil] initWithItemIdentifier:itemIdentifier];
    [item setLabel:itemIdentifier];
    [item setPaletteLabel:itemIdentifier];
    [item setAction:@selector(selectModule:)];
    [item setTarget:self];
    
    if ([itemIdentifier isEqualToString:@"Show All"]) {
        [item setToolTip:@"Show all preferences modules."];
        [item setImage:[NSImage imageNamed:@"NSApplicationIcon"]];
    } else {
        [item setToolTip:[module toolTip]];
        [item setImage:[module image]];
    }
    
    return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *items = [NSMutableArray arrayWithObjects:@"Show All", NSToolbarFlexibleSpaceItemIdentifier, nil];
    [items addObjectsFromArray:_preferredModuleNames];
    return items;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *items = [NSMutableArray array];

    [items addObjectsFromArray:[self names]];
    [items addObject:NSToolbarSpaceItemIdentifier];
    [items addObject:NSToolbarFlexibleSpaceItemIdentifier];

    return items;
}

#pragma mark - Actions

- (IBAction)selectModule:(id)sender {
    if ([sender isKindOfClass:[NSToolbarItem class]]) {
        [self selectModuleNamed:[sender itemIdentifier]];
    } else {
        [self selectModuleNamed:[[sender selectedCell] representedObject]];
    }
}

#pragma mark - Modules

- (NSArray *)names {
    return [[_modules allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)selectModuleNamed:(NSString *)name {
    NSView *view;
    NSRect frame;

    frame = [self.panel frame];
    if ([name isEqualToString:@"Show All"]) {
        view = self.allView;
        [self.panel setDelegate:self];
        [self.panel setTitle:@"Preferences — All"];
    } else {
        view = [[_modules objectForKey:name] view];
        [self.panel setDelegate:[_modules objectForKey:name]];
        [self.panel setTitle:AJRFormat(@"Preferences — %@", name)];
    }

    if (view != [self.panel contentView]) {
        NSRect newViewFrame = [view frame];
        NSRect oldViewFrame = [(NSView *)[self.panel contentView] frame];
        float differenceY = newViewFrame.size.height - oldViewFrame.size.height;
        float differenceX;

        if (newViewFrame.size.width < 400) {
            newViewFrame.size.width = 400;
        }
        differenceX = newViewFrame.size.width - oldViewFrame.size.width;

        if (differenceY != 0.0 || differenceX != 0.0) {
            frame.origin.y -= differenceY;
            frame.size.height += differenceY;
            frame.origin.x -= differenceX / 2.0;
            frame.size.width += differenceX;
            [self.panel setContentView:[[NSView alloc] initWithFrame:oldViewFrame]];
            [self.panel setFrame:frame display:YES animate:YES];
            [self.panel setContentView:view];
        }
        [[_modules objectForKey:name] update];
    }

    [self.panel makeFirstResponder:[view nextKeyView]];
}

@end

// MARK: -

@implementation NSResponder (AJRPreferences)

- (IBAction)runPreferencesPanel:(id)sender {
    [[AJRPreferences sharedInstance] run];
}

@end
