/*
 AJRViewController.m
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
//  AJRSubviewController.m
//  Service Browser
//
//  Created by Alex Raftis on 12/10/08.
//  Copyright 2008 Apple, Inc.. All rights reserved.
//

#import "AJRViewController.h"

#import <AJRInterface/AJRXView.h>
#import <Log4Cocoa/Log4Cocoa.h>

@implementation AJRViewController

- (id)initWithViewController:(AJRMultiViewController *)viewController
{
    if ((self = [super init])) {
        self.viewController = viewController;
        self.title = NSStringFromClass([self class]);
        self.nibName = NSStringFromClass([self class]);
    }
    return self;
}

- (void)dealloc
{
    [_nibName release];
    [_title release];
    [_identifier release];
    [_view release];
    [_object release];
    //[_viewController release]; NOT RETAINED
    
    [super dealloc];
}

- (NSString *)nibName
{
    if (_nibName == nil) {
        return NSStringFromClass([self class]);
    }
    return _nibName;
}

- (NSString *)identifier
{
    return [self title];
}

@synthesize nibName = _nibName;
@synthesize title = _title;
@synthesize identifier = _identifier;
@synthesize view = _view;
@synthesize object = _object;
@synthesize viewController = _viewController;

- (NSView *)view
{
    return [self viewWithParentController:nil];
}

- (NSView *)viewWithParentController:(NSController *)parentController;
{
    if (_view == nil) {
        if (![NSBundle loadNibNamed:[self nibName] owner:self]) {
            //NSRunAlertPanel(@"Error", @"Unable to load nib %@", nil, nil, nil, [self nibName]);
            log4Error(@"ERROR: Unable to load nib: %@\n", [self nibName]);
        }
        if (_view == nil) {
            _view = [[AJRXView alloc] initWithFrame:(NSRect){{0.0, 0.0}, {640.0, 480.0}}];
            [_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        }
        [self viewDidLoad];
    }
    return _view;
}

- (void)viewDidLoad
{
}

@end
