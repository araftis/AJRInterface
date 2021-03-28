
#import <Cocoa/Cocoa.h>

@interface AJRBundleProtocol : NSURLProtocol

+ (NSString *)MIMETypeForFilename:(NSString *)filename;

@end
