/*
 AJRReport.m
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

#import "AJRReport.h"

#import "AJRReportView.h"

@implementation AJRReport

- (id)initWithPath:(NSString *)path {
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

- (void)dealloc {
    [_window orderOut:self];
    
}

- (AJRReportView *)reportView {
    return _reportView;
}

- (void)setReportPath:(NSString *)path {
    [_reportView setReportPath:path];
    if ([_reportView isLandscape]) {
        [_window setFrame:(NSRect){{0.0, 0.0}, {11.0 * 72.0, 8.5 * 72.0}} display:NO];
    } else {
        [_window setFrame:(NSRect){{0.0, 0.0}, {8.5 * 72.0, 11.0 * 72.0}} display:NO];
    }
    [_reportView setFrame:[_window frame]];
}

- (NSString *)reportPath {
    return [_reportView reportPath];
}

- (void)setRootObject:(id)object {
    [_reportView setRootObject:object];
}

- (id)rootObject {
    return [_reportView rootObject];
}

- (void)print {
    [self printInWindow:nil];
}

- (void)printInWindow:(NSWindow *)window {
    [_reportView printInWindow:window];
}

- (void)reportView:(AJRReportView *)reportView didFinishPrintingWithSuccess:(BOOL)flag {
}

@end
