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
