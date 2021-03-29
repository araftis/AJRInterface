/*
AJRCalendarDateChooser.m
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

#import "AJRCalendarDateChooser.h"

#import "NSBundle+Extensions.h"

@implementation AJRCalendarDateChooser

#pragma mark Creation

- (id)init
{
    if ((self = [super init])) {
        [NSBundle ajr_loadNibNamed:@"AJRCalendarDateChooser" owner:self];
        _date = [[NSDate alloc] init];
    }
    return self;
}

#pragma mark Destruction


#pragma mark Running

- (void)beginDateChooserForDate:(NSDate *)date modalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo
{
    self.date = date;
    [self beginDateChooserModalForWindow:docWindow modalDelegate:modalDelegate didEndSelector:didEndSelector contextInfo:contextInfo];
}

- (void)beginDateChooserModalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo
{
    _modalDelegate = modalDelegate;
    _didEndSelector = didEndSelector;
    _contextInfo = contextInfo;
    
    [docWindow beginSheet:_panel completionHandler:^(NSModalResponse returnCode) {
        [self sheetDidEnd:self->_panel returnCode:returnCode contextInfo:self->_contextInfo];
    }];
}

typedef void (*AJRModalCallback)(id self, SEL _cmd, id sender, NSInteger returnCode, void *contextInfo);

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (_didEndSelector) {
        AJRModalCallback callBack = (AJRModalCallback)[[_modalDelegate class] instanceMethodForSelector:_didEndSelector];
        if (callBack) {
            callBack(_modalDelegate, _didEndSelector, self, returnCode, _contextInfo);
        }
    }    
}

#pragma mark Actions

- (void)_finishWithResponseCode:(NSInteger)responseCode
{
    [_panel makeFirstResponder:nil];
    [_panel orderOut:self];
    [NSApp endSheet:_panel returnCode:responseCode];
     _modalDelegate = nil;
}

- (IBAction)show:(id)sender
{
    [self _finishWithResponseCode:NSModalResponseOK];
}

- (IBAction)cancel:(id)sender
{
    [self _finishWithResponseCode:NSModalResponseCancel];
}

@end


@implementation _AJRCalendarDateChooserPanel

@synthesize chooser = _chooser;

- (void)sendEvent:(NSEvent *)event
{
    if ([event type] == NSEventTypeKeyDown) {
        unichar    character;
        
        if ([[event characters] length] >= 1) {
            character = [[event characters] characterAtIndex:0];
            if (character == '\e') {
                [_chooser cancel:self];
                return;
            } else if (character == '\r' || character == '\n') {
                [_chooser show:self];
                return;
            }
        }
    }
    [super sendEvent:event];
}

@end
