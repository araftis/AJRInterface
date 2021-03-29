/*
AJROptionalAlertPanel.m
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

#import "AJROptionalAlertPanel.h"

#import <AJRFoundation/AJRFunctions.h>

@implementation AJROptionalAlertPanel

- (id)init
{
    if ((self = [super init])) {
        if (!panel) {
            if (![[NSBundle bundleForClass:[self class]] loadNibNamed:@"AJROptionalAlertPanel" owner:self topLevelObjects:NULL]) {
                AJRPrintf(@"Error loading AJROptionalAlertPanel.nib");
                return nil;
            }
        }
    }
    return self;
}

- (void)computeMaxWidth
{
    float diff;
    float width;
    
    width = [[panel screen] visibleFrame].size.width;
    width = floor(width * 0.9);
    diff = origContentRect.size.width - origTextFrame.size.width;
    if (width + diff < 1024.0) {
        maxWidth = width - diff;
    } else {
        maxWidth = 1024.0;
    }
}

- (void)awakeFromNib
{
    NSSize maxSize;
    
    [panel setTitle:[[NSProcessInfo processInfo] processName]];
    origTextFrame = [messageText frame];
    origContentRect = [(NSView *)[panel contentView] frame];
    [self computeMaxWidth];
    maxSize.width = maxWidth;
    maxSize.height = 400.0;
    [messageText setMaxSize:maxSize];
    [messageText setMinSize:origTextFrame.size];
    [messageText setVerticallyResizable:YES];
    [messageText setHorizontallyResizable:NO];
    [messageText setEditable:NO];
    [[messageText textContainer] setLineFragmentPadding:0.0];
    buttonSpacing = [alternateButton frame].origin.x - [defaultButton frame].origin.x - [defaultButton frame].size.width;
    buttonMargin = [(NSView *)[panel contentView] frame].size.width - [otherButton frame].origin.x - [otherButton frame].size.width;
    buttonY = [defaultButton frame].origin.y;
    minButtonWidth = [defaultButton frame].size.width;
    buttonHeight = [defaultButton frame].size.height;
}

+ (id)sharedInstance
{
    return [[self alloc] init];
}

- (void)setDefaultsName:(NSString*)theDefaultsName
{
    if (theDefaultsName != defaultsName) {
        defaultsName = theDefaultsName;
    }
}

- (void)resizePanel
{
    NSRect frame = [messageText frame];
    NSSize windowSize;
    
    windowSize.width = frame.size.width + (origContentRect.size.width - origTextFrame.size.width);
    windowSize.height = frame.size.height + (origContentRect.size.height - origTextFrame.size.height);
    [panel setContentSize:windowSize];
}

- (void)resizeButton:(NSButton*)button
{
    NSRect frame;
    
    [button sizeToFit];
    frame = [button frame];
    if ([button frame].size.width < minButtonWidth) {
        frame.size.width = minButtonWidth;
    }
    frame.size.height = buttonHeight;
    [button setFrame:frame];
}

- (void)tileButtons
{
    float defaultX;
    float alternateX;
    float otherX;
    NSRect frame;
    
    [self resizeButton:defaultButton];
    [self resizeButton:alternateButton];
    [self resizeButton:otherButton];
    otherX = [(NSView *)[panel contentView] frame].size.width - [otherButton frame].size.width - buttonMargin;
    alternateX = otherX - [alternateButton frame].size.width - buttonSpacing;
    defaultX = alternateX - [defaultButton frame].size.width - buttonSpacing;
    frame = [otherButton frame];
    if ([[otherButton cell] isTransparent]) {
        float dist = [otherButton frame].size.width + buttonSpacing;
        
        alternateX += dist;
        defaultX += dist;
        frame.origin.y = -200.0;
    } else {
        frame.origin.x = otherX;
        frame.origin.y = buttonY;
    }
    [otherButton setFrame:frame];
    frame = [alternateButton frame];
    if ([[alternateButton cell] isTransparent]) {
        defaultX += [alternateButton frame].size.width + buttonSpacing;
        frame.origin.y = -200.0;
    } else {
        frame.origin.x = alternateX;
        frame.origin.y = buttonY;
    }
    [alternateButton setFrame:frame];
    frame = [defaultButton frame];
    frame.origin.x = defaultX;
    [defaultButton setFrame:frame];
}

- (float)minTextFrameWidth
{
    float buttonsWidth = [defaultButton frame].size.width;
    float diff;
    
    if (![[alternateButton cell] isTransparent]) {
        buttonsWidth += [alternateButton frame].size.width;
    }
    if (![[otherButton cell] isTransparent]) {
        buttonsWidth += [otherButton frame].size.width;
    }
    diff = buttonsWidth - (3.0 * minButtonWidth);
    if (diff < 0.0) {
        diff = 0.0;
    }
    return origTextFrame.size.width + diff;
}

- (void)tile
{
    NSRect frame = origTextFrame;
    float width;
    
    [self tileButtons];
    frame.size.width = maxWidth;
    [messageText setFrame:frame];
    [self resizePanel];
    [messageText setString:[messageText string]];
    [messageText sizeToFit];
    [messageText setString:[messageText string]];
    [self resizePanel];
    frame.size = [messageText frame].size;
    width = [[messageText textStorage] size].width;
    if (width < 1024) {
        float minWidth = [self minTextFrameWidth];
        
        frame.size.width = width;
        if (frame.size.width < minWidth) {
            frame.size.width = minWidth;
        }
    }
    [messageText setFrame:frame];
    [self resizePanel];
}

- (NSInteger)runModalWithTitle:(NSString*)title message:(NSString*)message defaultReturnValue:(NSInteger)defaultReturnValue defaultsName:(NSString*)theDefaultsName defaultButton:(NSString*)defaultButtonTitle alternateButton:(NSString*)alternateButtonTitle otherButton:(NSString*)otherButtonTitle
{
    NSInteger modalReturn;
    
    [self setDefaultsName:theDefaultsName];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"AJROptionalAlertPanel Disabled %@", defaultsName]] intValue]) {
        return defaultReturnValue;
    }
    [messageText setString:message];
    [optionButton setState:NO];
    if (defaultButtonTitle) {
        [defaultButton setTitle:defaultButtonTitle];
        if (alternateButtonTitle) {
            [alternateButton setTitle:alternateButtonTitle];
            [alternateButton setEnabled:YES];
            [[alternateButton cell] setTransparent:NO];
        } else {
            [alternateButton setEnabled:NO];
            [[alternateButton cell] setTransparent:YES];
        }
        if (otherButtonTitle) {
            [otherButton setTitle:otherButtonTitle];
            [otherButton setEnabled:YES];
            [[otherButton cell] setTransparent:NO];
        } else {
            [otherButton setEnabled:NO];
            [[otherButton cell] setTransparent:YES];
        }
    }
    else
    {
        [defaultButton setTitle:@"OK"];
    }
    [self tile];
    modalReturn = [NSApp runModalForWindow:panel];
    [panel orderOut:self];
    return modalReturn;
}

- (IBAction)defaultButtonPushed:(id)sender
{
    [NSApp stopModalWithCode:NSAlertFirstButtonReturn];
}

- (IBAction)alternateButtonPushed:(id)sender
{
    [NSApp stopModalWithCode:NSAlertSecondButtonReturn];
}

- (IBAction)otherButtonPushed:(id)sender;
{
    [NSApp stopModalWithCode:NSAlertThirdButtonReturn];
}

- (IBAction)optionButtonPushed:(id)sender
{
    NSString* userDefaultsKey = [NSString stringWithFormat:@"AJROptionalAlertPanel Disabled %@", defaultsName];
    
    if ([sender state]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:userDefaultsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (BOOL)windowShouldProcessEscape:(id)sender
{
    if (sender == panel) {
        if ([[alternateButton cell] isTransparent]) {
            return YES;
        } else {
            [NSApp stopModalWithCode:NSAlertSecondButtonReturn];
            return NO;
        }
    } else {
        return YES;
    }
}

@end
