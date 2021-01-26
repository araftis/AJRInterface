
#import "NSBitmapImageRep+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation NSBitmapImageRep (AJRInterfaceExtensions)

- (NSData *)JPEGRepresentation {
   return [self JPEGRepresentationWithQuality:0.8];
}

- (NSData *)JPEGRepresentationWithQuality:(float)quality {
	return [self representationUsingType:NSBitmapImageFileTypeJPEG properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:quality], NSImageCompressionFactor, nil]];
}

- (NSData *)GIFRepresentation {
   return [self GIFRepresentationWithDitheredTransparency:YES];
}

- (NSData *)GIFRepresentationWithDitheredTransparency:(BOOL)flag {
	return [self representationUsingType:NSBitmapImageFileTypeGIF properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:flag], NSImageDitherTransparency, nil]];
}

- (NSData *)BMPRepresentation {
	return [self representationUsingType:NSBitmapImageFileTypeBMP properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSImageCompressionFactor, nil]];
}

- (NSData *)PNGRepresentation {
   return [self PNGRepresentationWithInterlacing:YES];
}

- (NSData *)PNGRepresentationWithInterlacing:(BOOL)flag {
	return [self representationUsingType:NSBitmapImageFileTypePNG properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:flag], NSImageInterlaced, nil]];
}

@end
