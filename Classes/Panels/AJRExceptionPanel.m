/*
AJRExceptionPanel.m
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

#import "AJRExceptionPanel.h"

#import "AJRReportView.h"
#import "NSBundle+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>

@implementation AJRExceptionPanel

+ (id)exceptionPanelWithException:(NSException *)exception {
    return [[AJRExceptionPanel alloc] initWithException:exception];
}

- (id)initWithException:(NSException *)exception {
    if ((self = [super init])) {
        self.exception = exception;
    }
    return self;
}


@synthesize panel = _panel;
@synthesize titleText = _titleText;
@synthesize messageText = _messageText;
@synthesize exceptionReport = _exceptionReport;
@synthesize exitButton = _exitButton;
@synthesize continueButton = _continueButton;
@synthesize printButton = _printButton;
@synthesize emailButton = _emailButton;
@synthesize exception = _exception;

- (NSInteger)run {
    NSString    *path;
    
    if (_panel == nil) {
        [NSBundle ajr_loadNibNamed:@"AJRExceptionPanel" owner:self];
    }
    [_panel center];

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"AJRExceptionReport" ofType:@"osmreport"];
    if (path) {
        [self.exceptionReport setReportPath:path];
        [self.exceptionReport setRootObject:_exception];
        [self.exceptionReport setEditable:YES];
        AJRPrintf(@"DEBUG: Node: %@", [[[self.exceptionReport mainFrame] DOMDocument] getElementById:@"problemReport"]);
    }
    [self.titleText setStringValue:AJRFormat(@"Uncaught %@", [_exception name])];
    [self.panel makeFirstResponder:self.exceptionReport];
    
    [_panel makeKeyAndOrderFront:self];

    return [NSApp runModalForWindow:_panel];
}

- (IBAction)exitApplication:(id)sender {
    [_panel orderOut:self];
    [NSApp stopModalWithCode:NSAlertFirstButtonReturn];
}

- (IBAction)continueApplication:(id)sender {
    [_panel orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (IBAction)printException:(id)sender {
}

- (IBAction)emailException:(id)sender {
}

@end
