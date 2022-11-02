/*
 AJRReportImage.m
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

#import "AJRReportImage.h"

#import "AJRReportView.h"
#import "DOMNode+Extensions.h"
#import "NSImage+Extensions.h"
#import "NSBitmapImageRep+Extensions.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSFileManager+Extensions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>

@implementation AJRReportImage

+ (void)load {
    [AJRReportElement registerReportElement:self forName:@"image"];
}


- (void)apply {
    NSString *key = [[_node attributeForName:@"image"] stringValue];
    NSInteger width = [[[_node attributeForName:@"width"] stringValue] integerValue];
    NSInteger height = [[[_node attributeForName:@"height"] stringValue] integerValue];
    NSImage *image;
    NSData *data;
    NSString *extension = nil;
    
    if (key == nil) {
        @throw [NSException exceptionWithName:@"ReportException" reason:@"Missing \"key\" from conditional element." userInfo:nil];
    }
    
    image = [[_reportView objects] valueForKeyPath:key];
    if ([image isKindOfClass:[NSImage class]]) {
        data = [image ajr_PNGRepresentation];
        if (width < 0) width = [(NSImage *)image size].width;
        if (height < 0) height = [(NSImage *)image size].height;
        extension = @"png";
    } else if ([image isKindOfClass:[NSBitmapImageRep class]]) {
        data = [(NSBitmapImageRep *)image PNGRepresentation];
        if (width < 0) width = [(NSBitmapImageRep *)image pixelsWide];
        if (height < 0) height = [(NSBitmapImageRep *)image pixelsHigh];
    }
    
    if (data && extension) {
        _path = [[NSFileManager defaultManager] temporaryFilenameForTemplate:[@"Report.XXXXXX" stringByAppendingPathExtension:extension]];

        if ([data writeToFile:_path atomically:NO]) {
            NSXMLElement    *element = (NSXMLElement *)[NSXMLNode elementWithName:@"img"];
            [element addAttribute:AJRFormat(@"%d", width) forName:@"width"];
            [element addAttribute:AJRFormat(@"%d", height) forName:@"height"];
            [element addAttribute:[[NSURL fileURLWithPath:_path] absoluteString] forName:@"src"];
            [(NSXMLElement *)[_node parent] replaceChild:element withNode:_node];
        }
    }
}

- (void)cleanup {
    if (_path) {
        [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
    }
}

@end
