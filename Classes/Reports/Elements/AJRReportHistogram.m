//
//  AJRReportHistogram.m
//  AJRInterface
//
//  Created by A.J. Raftis on 12/19/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

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

+ (void)load
{
    [AJRReportElement registerReportElement:self forName:@"histogram"];
}


- (void)apply
{
    NSString        *dataKey = [[_node attributeForName:@"key"] stringValue];
    NSDictionary    *data = nil;
    NSInteger        width = [[[_node attributeForName:@"width"] stringValue] integerValue];
    NSInteger        height = [[[_node attributeForName:@"height"] stringValue] integerValue];
    NSString        *SLAKey = [[_node attributeForName:@"sla"] stringValue];
    
    if (!dataKey) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"key\" from histogram element." userInfo:nil];
    }
    
    if (width <= 0) width = 500;
    if (height <= 0) height = 150;
    
    @try {
        data = [[_reportView objects] valueForKeyPath:dataKey];
    } @catch (NSException *exception) { }
    
    if (data != nil) {
        NSWindow            *window;
        AJRHistogramView        *view;
        NSRect                frame = NSMakeRect(0.0, 0.0, width, height);
        
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

- (void)cleanup
{
    if (path) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

@end
