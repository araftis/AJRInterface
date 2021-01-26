//
//  AJRBundleProtocol.h
//  OnlineStoreManager
//
//  Created by A.J. Raftis on 12/1/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRBundleProtocol : NSURLProtocol
{
}

+ (NSString *)MIMETypeForFilename:(NSString *)filename;

@end
