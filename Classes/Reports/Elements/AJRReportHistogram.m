/*
 AJRReportHistogram.m
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

#import "AJRReportHistogram.h"

#import "AJRHistogramView.h"
#import "AJRReportView.h"
#import "DOMNode+Extensions.h"
#import "NSBitmapImageRep+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSFileManager+Extensions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>
#import <WebKit/WebKit.h>

@implementation AJRReportHistogram

+ (void)load {
    [AJRReportElement registerReportElement:self forName:@"histogram"];
}


- (void)apply {
    NSString *dataKey = [[_node attributeForName:@"key"] stringValue];
    NSDictionary *data = nil;
    NSInteger width = [[[_node attributeForName:@"width"] stringValue] integerValue];
    NSInteger height = [[[_node attributeForName:@"height"] stringValue] integerValue];
    NSString *SLAKey = [[_node attributeForName:@"sla"] stringValue];
    
    if (!dataKey) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"key\" from histogram element." userInfo:nil];
    }
    
    if (width <= 0) width = 500;
    if (height <= 0) height = 150;
    
    @try {
        data = [[_reportView objects] valueForKeyPath:dataKey];
    } @catch (NSException *exception) { }
    
    if (data != nil) {
        NSWindow *window;
        AJRHistogramView *view;
        NSRect frame = NSMakeRect(0.0, 0.0, width, height);
        
        window = [[NSWindow alloc] initWithContentRect:frame
                                             styleMask:NSWindowStyleMaskBorderless
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
        view = [[AJRHistogramView alloc] initWithFrame:frame];
        [[window contentView] addSubview:view];
        
        [view setStatistics:data];
        if (SLAKey) {
            @try {
                [view setSLA:[[[_reportView objects] valueForKeyPath:SLAKey] integerValue]];
            } @catch (NSException *exception) { }
        }
        path = [[NSFileManager defaultManager] temporaryFilenameForTemplate:@"/tmp/Report.XXXXXX.pdf"];
        if ([[view dataWithPDFInsideRect:frame] writeToFile:path atomically:NO]) {
            NSXMLElement    *element = (NSXMLElement *)[NSXMLNode elementWithName:@"img"];
            [element addAttribute:AJRFormat(@"%d", width) forName:@"width"];
            [element addAttribute:AJRFormat(@"%d", height) forName:@"height"];
            [element addAttribute:[[NSURL fileURLWithPath:path] absoluteString] forName:@"src"];
            [(NSXMLElement *)[_node parent] replaceChild:_node withNode:element];
        }
        
    }
}

- (void)cleanup {
    if (path) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

@end
