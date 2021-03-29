/*
AJRReportView.m
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

#import "AJRReportView.h"

#import "AJRBundleProtocol.h"
#import "AJRReportElement.h"
#import "NSAlert+Extensions.h"

#import <AJRFoundation/NSFileManager+Extensions.h>
#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSBundle+Extensions.h>
#import <AJRFoundation/NSData+Base64.h>
#import <AJRFoundation/NSDictionary+Extensions.h>
#import <AJRFoundation/NSRunLoop+Extensions.h>
#import <AJRFoundation/NSString+Extensions.h>
#import <AJRFoundation/NSXMLElement+Extensions.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

@implementation AJRReportView {
	NSMutableSet *_elements;
	NSXMLDocument *_document;
	NSString *_temporaryFilename;
	
	BOOL _loading;
	BOOL _hasParsed;
}

+ (void)initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"WebKitShouldPrintBackgroundsPreferenceKey":[NSNumber numberWithInt:1]}];
    [self exposeBinding:@"rootObject"];
}

- (void)_setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDidFinish:) name:WebViewProgressFinishedNotification object:self];
    _objects = [[NSMutableDictionary alloc] init];
    // Let's put some defaults into the objects array
    [_objects setObject:[NSDate date] forKey:@"today"];
    _elements = [[NSMutableSet alloc] init];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _setup];
    }
    return self;
}

- (void)resetDocument {
    if (_reportBundle) {
        NSString *name = [[[_reportBundle bundlePath] lastPathComponent] stringByDeletingPathExtension];
        NSString *htmlPath = [_reportBundle pathForResource:name ofType:@"html"];
        
        if (htmlPath) {
            NSError        *error = nil;
            
            _document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:htmlPath] options:0 error:&error];
            if (error) {
                AJRRunAlertPanel(@"Error", @"Failed to parse report: %@", nil, nil, nil, [error localizedDescription]);
                // We should have gotten back a document, but in case we did, make sure we don't keep it.
                 _document = nil;
            } else {
                _hasParsed = NO;
            }
        }
    }
    [[self mainFrame] loadHTMLString:@"<html></html>" baseURL:nil];
}

- (void)setReportBundle:(NSBundle *)bundle {
    if (bundle != _reportBundle) {
        _reportBundle = bundle;
        _reportName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension];

        [self resetDocument];
        [self update];
    }
}

- (void)setReportName:(NSString *)name {
    if (_reportName != name) {
        NSString    *path;
        
        _reportName = name;
        
        path = [NSBundle pathForResource:_reportName ofType:@"osmreport"];
        if (path != nil) {
            self.reportBundle = [[NSBundle alloc] initWithPath:path];
        } else {
            // We don't just call setReportBundle:, because if the bundle can't be found, we still
            // want to store the name. This may frequently happen when using IB to create report
            // views, since the bundle won't be present in IB, but only later once the application 
            // is running.
             _reportBundle = nil;
        }
    }
}

- (void)setReportPath:(NSString *)path {
    if (_reportBundle) {
        _reportBundle = nil;
    }
    
    self.reportBundle = [[NSBundle alloc] initWithPath:path];
    
    [self resetDocument];
}

- (NSString *)reportPath {
    return [_reportBundle bundlePath];
}

- (void)setRootObject:(id)rootObject {
    @synchronized (self) {
        if ([rootObject isKindOfClass:[NSArray class]]) {
            // This happens when rootObject is bound via bindings
            rootObject = [(NSArray *)rootObject lastObject];
        }
        if (self.rootObject != rootObject) {
            if (rootObject == nil) {
                [_objects removeObjectForKey:@"root"];
            } else {
                [_objects setObject:rootObject forKey:@"root"];
            }
            if (_hasParsed) {
                [self resetDocument];
            }
            [self update];
        }
    }
}

- (id)rootObject {
    return [_objects objectForKey:@"root"];
}

- (void)loadDidFinish:(NSNotification *)notification {
    _loading = NO;
}

- (void)waitForLoad {
    while (_loading) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
    }
}

- (void)updateNodes:(NSArray *)children {
    for (NSXMLNode *child in children) {
        [self updateNode:child];
    }
}

- (void)updateNode:(NSXMLNode *)node {
    //AJRPrintf(@"%C: %@ (%d/%C)\n", self, [node name], [node kind], node);
    if (node && [node name] && ([[node name] hasCaseInsensitivePrefix:@"as:"] || [[node name] caseInsensitiveCompare:@"as"] == NSOrderedSame)) {
        AJRReportElement    *element = [AJRReportElement elementForNode:(NSXMLElement *)node inReportView:self];
        if (element) {
            [_elements addObject:element];
            [element apply];
        } else {
            AJRPrintf(@"WARNING: Unknown element %@", [node name]);
        }
    } else if ([node isKindOfClass:[NSXMLElement class]]) {
        NSXMLElement    *element = (NSXMLElement *)node;
        NSString        *key = [[element attributeForName:@"as:rowkey"] stringValue];
        if (key) {
            NSInteger    index = [[[self objects] valueForKey:key] integerValue];
            if (index % 2 == 0) {
                [element addAttribute:@"even" forName:@"class"];
            } else {
                [element addAttribute:@"odd" forName:@"class"];
            }
            [element removeAttributeForName:@"as:rowkey"];
        }
    }

    [self updateNodes:[node children]];
}

- (void)_loadHTMLOnMainThread:(NSString *)htmlString {
    id rootObject = [self rootObject];
    if ([rootObject respondsToSelector:@selector(baseURL)]) {
        self.baseURL = [rootObject baseURL];
    }
    [[self mainFrame] loadHTMLString:htmlString baseURL:_baseURL];
}

- (void)update {
    if (_reportBundle && [_objects objectForKey:@"root"]) {
        @synchronized (self) {
            [self updateNode:_document];
            _loading = YES;
            if (![NSThread isMainThread]) {
                [self performSelectorOnMainThread:@selector(_loadHTMLOnMainThread:) withObject:[self htmlString] waitUntilDone:NO];
            } else {
                [self _loadHTMLOnMainThread:[self htmlString]];
            }
            [self waitForLoad];
            _hasParsed = YES;
        }
    }
}

- (BOOL)isLandscape {
    return [[[_reportBundle infoDictionary] stringForKey:@"Orientation" defaultValue:@"Portrait"] isEqualToString:@"Landscape"];
}

- (CGFloat)topMargin {
    return [[_reportBundle infoDictionary] floatForKey:@"TopMargin" defaultValue:36.0];
}

- (CGFloat)bottomMargin {
    return [[_reportBundle infoDictionary] floatForKey:@"BottomMargin" defaultValue:36.0];
}

- (CGFloat)leftMargin {
    return [[_reportBundle infoDictionary] floatForKey:@"LeftMargin" defaultValue:36.0];
}

- (CGFloat)rightMargin {
    return [[_reportBundle infoDictionary] floatForKey:@"RightMargin" defaultValue:36.0];
}

- (void)print {
    [self printInWindow:nil];
}

- (void)printDocument:(id)sender {
    [self printInWindow:[self window]];
}

- (void)printInWindow:(NSWindow *)window {
    NSView            *printView = [[[self mainFrame] frameView] documentView];
    // Customize the NSPrintInfo to get things looking a bit better. For more details and options see: http://developer.apple.com/documentation/Cocoa/Reference/ApplicationKit/Classes/NSPrintInfo_Class/Reference/Reference.html 
    NSPrintInfo        *printInfo = [NSPrintInfo sharedPrintInfo];
    
    if ([self isLandscape]) {
        [printInfo setOrientation:NSPaperOrientationLandscape];
    }
    [printInfo setVerticallyCentered:NO]; // Don't vertically center the content on the page
    [printInfo setHorizontalPagination:NSFitPagination]; // Fit content horizontally onto a single page width
    [printInfo setTopMargin:[self topMargin]];
    [printInfo setBottomMargin:[self bottomMargin]];
    [printInfo setLeftMargin:[self leftMargin]];
    [printInfo setRightMargin:[self rightMargin]];
    
    // Create a NSPrintOperation for the document view and open the print dialog
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView];
    [printOperation setJobTitle:[[_reportBundle infoDictionary] objectForKey:@"CFBundleName"]];
    [printOperation runOperationModalForWindow:window 
                                      delegate:self
                                didRunSelector:@selector(printOperationDidRun:success:contextInfo:)
                                   contextInfo:nil];
}

- (void)printOperationDidRun:(NSPrintOperation *)operation success:(BOOL)success contextInfo:(void *)contextInfo {
    if ([_delegate respondsToSelector:@selector(reportView:didFinishPrintingWithSuccess:)]) {
        [_delegate reportView:self didFinishPrintingWithSuccess:success];
        [_elements makeObjectsPerformSelector:@selector(cleanup)];
        [_elements removeAllObjects];
    }
}

- (NSDictionary *)_imageResourceForNode:(NSXMLElement *)node withCID:(NSString *)CID {
    NSMutableDictionary *resource = [NSMutableDictionary dictionary];
    NSString *src = [[node attributeForName:@"src"] stringValue];
    
    if (src) {
        NSURL *URL = [NSURL URLWithString:src];
        NSString *myCID = AJRFormat(@"%@/%@", CID, [src lastPathComponent]);
        NSString *newURL = AJRFormat(@"cid:%@", myCID);
        
        AJRPrintf(@"DEBUG: src = %@ -> %@", src, newURL);
        [resource setObject:newURL forKey:@"newURL"];
        [resource setObject:URL forKey:@"originalURL"];
        [resource setObject:myCID forKey:@"CID"];
        [node addAttribute:newURL forName:@"src"];
    }
    
    return resource;
}

- (NSDictionary *)_linkResourceForNode:(NSXMLElement *)node withCID:(NSString *)CID {
    NSMutableDictionary    *resource = [NSMutableDictionary dictionary];
    NSString            *href = [[node attributeForName:@"href"] stringValue];
    
    if (href) {
        NSURL        *URL = [NSURL URLWithString:href];
        NSString    *myCID = AJRFormat(@"%@/%@", CID, [href lastPathComponent]);
        NSString    *newURL = AJRFormat(@"cid:%@", myCID);
        
        AJRPrintf(@"DEBUG: href = %@ -> %@", href, newURL);
        [resource setObject:newURL forKey:@"newURL"];
        [resource setObject:URL forKey:@"originalURL"];
        [resource setObject:myCID forKey:@"CID"];
        [node addAttribute:newURL forName:@"href"];
    }
    
    return resource;
}

- (void)_addResourcesInNode:(NSXMLNode *)node toArray:(NSMutableArray *)resources withCID:(NSString *)CID {
    NSString *name = [node name];
    
    if ([name isEqualToString:@"img"]) {
        [resources addObject:[self _imageResourceForNode:(NSXMLElement *)node withCID:CID]];
    } else if ([name isEqualToString:@"link"]) {
        [resources addObject:[self _linkResourceForNode:(NSXMLElement *)node withCID:CID]];
    }
    
    for (NSXMLElement *child in [node children]) {
        [self _addResourcesInNode:child toArray:resources withCID:CID];
    }
}

- (NSArray *)_resourcesInDocument:(NSXMLDocument *)document withCID:(NSString *)CID {
    NSMutableArray *resources = [[NSMutableArray alloc] init];
    
    [self _addResourcesInNode:document toArray:resources withCID:CID];
    
    return resources;;
}

- (NSString *)mimeMessageBody {
    NSXMLDocument *newDocument = [_document copy];
    NSMutableString *messageBody = [[NSMutableString alloc] init];
    NSArray *resources;
    NSString *boundary = AJRFormat(@"OSM-%d", [NSDate timeIntervalSinceReferenceDate]);
    NSString *CID = [[NSProcessInfo processInfo] globallyUniqueString];
    
    resources = [self _resourcesInDocument:newDocument withCID:CID];
    
    // Append the header
    [messageBody appendFormat:@"Content-Type: multipart/related; boundary=%@; type=text/html\n", boundary];
    
    // Append the document
    [messageBody appendString:@"\n"];
    [messageBody appendFormat:@"--%@\n", boundary];
    [messageBody appendString:@"Content-Type: text/html; charset=UTF-8\n"];
    [messageBody appendString:@"Content-Transfer-Encoding: 8bit\n"];
    [messageBody appendString:@"\n"];
    [messageBody appendFormat:@"%@\n", [newDocument XMLStringWithOptions:0]];
    
    // Append the resources
    for (NSDictionary *resource in resources) {
        @autoreleasepool {
            NSURL                *originalURL = [resource objectForKey:@"originalURL"];
            NSString            *newURL = [resource objectForKey:@"newURL"];
            NSString            *resourceCID = [resource objectForKey:@"CID"];
            NSData                *data = nil;
            
            if (newURL) {
                data = [[NSData alloc] initWithContentsOfURL:originalURL];
                if (data) {
                    NSString    *filename = [[originalURL path] lastPathComponent];
                    [messageBody appendFormat:@"--%@\n", boundary];
                    [messageBody appendFormat:@"Content-Disposition: inline; filename=%@\n", filename];
                    [messageBody appendString:@"Content-Transfer-Encoding: base64\n"];
                    [messageBody appendFormat:@"Content-Type: %@; name=%@\n", [AJRBundleProtocol MIMETypeForFilename:filename], filename];
                    [messageBody appendFormat:@"Content-Id: <%@>\n", resourceCID];
                    [messageBody appendString:@"\n"];
                    [messageBody appendString:[data ajr_base64EncodedStringWithLineBreakAtPosition:20]];
                    [messageBody appendString:@"\n\n"];
                }
            }
        
        }
    }
    
    // Append the footer
    [messageBody appendFormat:@"--%@--\n", boundary];
    
    
    return messageBody;
}

- (ProcessSerialNumber)findProcessSerialNumberForMail {
    NSArray *applications = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSDictionary *application in applications) {
        if ([[application objectForKey:@"NSApplicationBundleIdentifier"] isEqualToString:@"com.apple.mail"]) {
            return (ProcessSerialNumber){(UInt32)[[application objectForKey:@"NSApplicationProcessSerialNumberHigh"] longValue], (UInt32)[[application objectForKey:@"NSApplicationProcessSerialNumberLow"] longValue]};
        }
    }
    
    return (ProcessSerialNumber){0, 0};
}

- (void)emailReportFrom:(NSString *)sender to:(NSString *)recipient subject:(NSString *)subject via:(NSString *)smtpHost
{
//    NSMutableString        *message = [[NSMutableString alloc] init];
//    NSString            *filename;
//    
//    [message appendFormat:@"From: %@\n", sender];
//    [message appendFormat:@"To: %@\n", recipient];
//    [message appendFormat:@"Subject: %@\n", subject];
//    [message appendString:[self mimeMessageBody]];
//    
//    filename = [[NSFileManager defaultManager] temporaryFilenameForTemplate:@"/tmp/Message.XXXXXX.mime"];
//    [message writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
//
//    [message release];
    NSAppleEventDescriptor *descriptor;
    NSAppleEventDescriptor *event;
    WebArchive *archive;
    NSData *archiveData;
    ProcessSerialNumber PSN = [self findProcessSerialNumberForMail];
    NSAppleEventDescriptor *address;
    
    archive = [[[self mainFrame] DOMDocument] webArchive];
    archiveData = [archive data];
    [archiveData writeToFile:[[NSFileManager defaultManager] temporaryFilenameForTemplate:@"/tmp/Message.XXXXXX.webarchive"] options:NSAtomicWrite error:NULL];
    
    address = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&PSN length:sizeof(PSN)];
    descriptor = [NSAppleEventDescriptor descriptorWithDescriptorType:typeObjectSpecifier data:archiveData];
    event = [NSAppleEventDescriptor appleEventWithEventClass:'mail' eventID:'mlpg' targetDescriptor:nil returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
    [event setParamDescriptor:descriptor forKeyword:keyDirectObject];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.apple.mail" options:0 additionalEventParamDescriptor:event launchIdentifier:nil];
}

- (NSString *)htmlString {
    if (_document) {
        return [_document XMLStringWithOptions:0];
    } else {
        return @"<html></html>";
    }
}

#pragma mark NSKeyValueBindingCreation

- (Class)valueClassForBinding:(NSString *)binding {
    if ([binding isEqualToString:@"rootObject"]) {
        return [NSObject class];
    }
    return [super valueClassForBinding:binding];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self _setup];
        [self setReportName:[coder decodeObjectForKey:@"reportName"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.reportName forKey:@"reportName"];
}

@end

#pragma clang diagnostic pop
