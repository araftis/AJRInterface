
#import <AppKit/AppKit.h>

@interface NSBitmapImageRep (AJRInterfaceExtensions)

- (NSData *)JPEGRepresentation;
- (NSData *)JPEGRepresentationWithQuality:(float)quality;
- (NSData *)GIFRepresentation;
- (NSData *)GIFRepresentationWithDitheredTransparency:(BOOL)flag;
- (NSData *)BMPRepresentation;
- (NSData *)PNGRepresentation;
- (NSData *)PNGRepresentationWithInterlacing:(BOOL)flag;

@end
