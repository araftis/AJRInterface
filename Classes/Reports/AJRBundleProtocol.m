/*
 AJRBundleProtocol.m
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

#import "AJRBundleProtocol.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRBundleProtocol

+ (void)load {
    [NSURLProtocol registerClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //AJRPrintf(@"%C: %S: %@\n", self, _cmd, request);
    return [[[request URL] scheme] isEqualToString:@"bundle"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    AJRPrintf(@"%C: %@\n", self, [request URL]);
    if ([[[request URL] scheme] isEqualToString:@"bundle"]) {
        NSMutableURLRequest *new = [request mutableCopy];
        NSURL *url = [request URL];
        NSString *bundleName = [url host];
        NSBundle *bundle;
        
        if ([bundleName isEqualToString:@"Main"]) {
            bundle = [NSBundle mainBundle];
        } else {
            bundle = [NSBundle bundleWithName:bundleName];
        }
        if (bundle) {
            NSArray        *components = [[url path] pathComponents];
            
            //AJRPrintf(@"%C: components: %@\n", self, components);
            if ([components count] >= 3 && [[components objectAtIndex:1] isEqualToString:@"infoDictionary"]) {
                [new setURL:url];
            } else {
                NSString    *basePath = [[url path] lastPathComponent];
                NSString    *path = [bundle pathForResource:[basePath stringByDeletingPathExtension] ofType:[basePath pathExtension]];
                if (path == nil) {
//                    AJRPrintf(@"WARNING: Unable to find path for URL: %@", url);
                } else {
//                    AJRPrintf(@"%C: map %@ -> %@\n", self, url, [NSURL fileURLWithPath:path]);
                    if (path) {
                        [new setURL:[NSURL fileURLWithPath:path]];
                    }
                }
            }
        }
        
        return new;
    }
    
    return request;
}

+ (NSString *)MIMETypeForFilename:(NSString *)filename {
    NSString *extension = [filename pathExtension];
    
    if (extension == nil) {
        return @"text/plain";
    } else if ([extension isEqualToString:@"jpg"]) {
        return @"image/jpeg";
    } else if ([extension isEqualToString:@"gif"]) {
        return @"image/gif";
    } else if ([extension isEqualToString:@"tif"]) {
        return @"image/tiff";
    } else if ([extension isEqualToString:@"tiff"]) {
        return @"image/tiff";
    } else if ([extension isEqualToString:@"png"]) {
        return @"image/png";
    } else if ([extension isEqualToString:@"pict"]) {
        return @"image/pict";
    } else if ([extension isEqualToString:@"icns"]) {
        return @"image/icns";
    } else if ([extension isEqualToString:@"html"]) {
        return @"text/html";
    } else if ([extension isEqualToString:@"txt"]) {
        return @"text/plain";
    } else if ([extension isEqualToString:@"rtf"]) {
        return @"text/rtf";
    } else if ([extension isEqualToString:@"css"]) {
        return @"text/css";
    } else if ([extension isEqualToString:@"pdf"]) {
        return @"image/pdf";
    }
    
    return @"text/plain";
}

- (NSString *)MIMETypeForFilename:(NSString *)filename {
    return [[self class] MIMETypeForFilename:filename];
}

- (void)startLoading {
    NSURLRequest *request = [[self class] canonicalRequestForRequest:[self request]];
    NSURL *fileURL = [request URL];
    id <NSURLProtocolClient> client = [self client];
    NSData *data;
    NSError *error = nil;
    NSArray *components = [[[request URL] path] pathComponents];
    
    if ([components count] >= 3 && [[components objectAtIndex:1] isEqualToString:@"infoDictionary"]) {
        NSString *bundleName = [[request URL] host];
        NSBundle *bundle = [NSBundle bundleWithName:bundleName];
        NSString *value = [[bundle infoDictionary] objectForKey:[components objectAtIndex:2]];
        
        if (value) {
            NSURLResponse *response;
            
            data = [[value description] dataUsingEncoding:NSUTF8StringEncoding];
            
            response = [[NSURLResponse alloc] initWithURL:[request URL]
                                                 MIMEType:@"text/plain" 
                                    expectedContentLength:[data length] 
                                         textEncodingName:@"utf8"];
            
            /* turn off caching for this response data */ 
            [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            
            /* set the data in the response to our jfif data */ 
            [client URLProtocol:self didLoadData:data];
            
            /* notify that we completed loading */
            [client URLProtocolDidFinishLoading:self];
            
            /* we can release our copy */
        } else {
            [client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"AJRNetworkDomain" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:AJRFormat(@"Unable to find key in infoDictionary of bundle %@", bundleName), NSLocalizedDescriptionKey, nil]]];
        }
    } else {
        data = [[NSData alloc] initWithContentsOfFile:[fileURL path] options:NSUncachedRead error:&error];
        
        if (error) {
            [client URLProtocol:self didFailWithError:error];
        } else {
            /* create the response record, set the mime type to jpeg */
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] 
                                                                MIMEType:[self MIMETypeForFilename:[fileURL path]] 
                                                   expectedContentLength:[data length] 
                                                        textEncodingName:nil];
            
            /* turn off caching for this response data */ 
            [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            
            /* set the data in the response to our jfif data */ 
            [client URLProtocol:self didLoadData:data];
            
            /* notify that we completed loading */
            [client URLProtocolDidFinishLoading:self];
            
            /* we can release our copy */
        }
    }
}

- (void)stopLoading {
}

@end
