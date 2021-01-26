//
//  AJRReport.m
//  AJRInterface
//
//  Created by A.J. Raftis on 12/18/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRReport.h"

#import "AJRReportView.h"

@implementation AJRReport

- (id)initWithPath:(NSString *)path
{
    if ((self = [super init])) {
        NSRect        frame = (NSRect){{0.0, 0.0}, { 8.5 * 72.0, 11.0 * 72.0 }};
        _window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:NSWindowStyleMaskBorderless
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
        _reportView = [[AJRReportView alloc] initWithFrame:frame];
        [_reportView setDelegate:self];
        [[_window contentView] addSubview:_reportView];
        
        //[_window orderFront:self];
        
        [self setReportPath:path];
    }
    return self;
}

- (void)dealloc
{
    [_window orderOut:self];
    
}

- (AJRReportView *)reportView
{
    return _reportView;
}

- (void)setReportPath:(NSString *)path
{
    [_reportView setReportPath:path];
    if ([_reportView isLandscape]) {
        [_window setFrame:(NSRect){{0.0, 0.0}, {11.0 * 72.0, 8.5 * 72.0}} display:NO];
    } else {
        [_window setFrame:(NSRect){{0.0, 0.0}, {8.5 * 72.0, 11.0 * 72.0}} display:NO];
    }
    [_reportView setFrame:[_window frame]];
}

- (NSString *)reportPath
{
    return [_reportView reportPath];
}

- (void)setRootObject:(id)object
{
    [_reportView setRootObject:object];
}

- (id)rootObject
{
    return [_reportView rootObject];
}

- (void)print
{
    [self printInWindow:nil];
}

- (void)printInWindow:(NSWindow *)window
{
    [_reportView printInWindow:window];
}

- (void)reportView:(AJRReportView *)reportView didFinishPrintingWithSuccess:(BOOL)flag
{
}

@end
