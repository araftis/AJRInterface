
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
