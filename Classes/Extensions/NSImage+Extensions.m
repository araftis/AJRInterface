/*
 NSImage+Extensions.m
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

#import "NSImage+Extensions.h"

#import "AJRImages.h"
#import "NSAffineTransform+Extensions.h"
#import "NSBitmapImageRep+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRImageUtilities.h>
#import <AJRInterface/AJRInterface-Swift.h>

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static char * const DrawNaturalSizeKey = "naturalSize";

@interface AJRImageDecodingPlaceholder : NSObject <AJRXMLDecoding>

@end

@implementation AJRImageDecodingPlaceholder {
    NSString *_name;
    NSData *_data;
    BOOL _isTemplate;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"name" setter:^(NSString * _Nonnull string) {
        self->_name = string;
    }];
    [coder decodeBoolForKey:@"template" setter:^(BOOL value) {
        self->_isTemplate = value;
    }];
    [coder decodeObjectForKey:@"data" setter:^(id  _Nonnull object) {
        self->_data = object;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    NSError *localError;
    NSImage *image;
    
    if (_name != nil) {
        // Try and get the image via name, first.
        image = [NSImage imageNamed:_name];
    }
    
    if (image == nil) {
        // We failed to get the image by name, so let's assume we have to build it via that stored data.
        if (_data == nil) {
            localError = [NSError errorWithDomain:AJRXMLDecodingErrorDomain message:@"Image in archive did not contain a \"data\" child element."];
        } else {
            image = [[NSImage alloc] initWithData:_data];
            if (image == nil) {
                localError = [NSError errorWithDomain:AJRXMLDecodingErrorDomain message:@"Image data in archive failed to create an image."];
            } else {
                if (_name != nil) {
                    image.name = _name;
                }
                if (_isTemplate) {
                    [image setTemplate:_isTemplate];
                }
            }
        }
    }
    
    return AJRAssertOrPropagateError(image, error, localError);
}

@end

@implementation NSImage (AJRInterfaceExtensions)

+ (void)load {
    AJRSwizzleClassMethods(self, @selector(imageNamed:), self, @selector(ajr_imageNamed:));
}

+ (NSImage *)ajr_imageNamed:(NSString *)imageName {
    NSImage *image = [self ajr_imageNamed:imageName];
    if (image == nil) {
        image = [AJRImages imageNamed:imageName];
    }
    return image;
}

+ (instancetype)ajr_imageWithImageRep:(NSImageRep *)imageRep {
    return [self ajr_imageWithImageRep:imageRep size:[imageRep size]];
}

+ (instancetype)ajr_imageWithImageRep:(NSImageRep *)imageRep size:(NSSize)size {
    NSImage *image = [[self alloc] initWithSize:size];
    [image addRepresentation:imageRep];
    return image;
}

+ (instancetype)ajr_imageWithImageRep:(NSImageRep *)imageRep scale:(CGFloat)scale {
    NSSize size = [imageRep size];
    size.width /= scale;
    size.height /= scale;
    return [self ajr_imageWithImageRep:imageRep size:size];
}

+ (void)ajr_imageWithContentsOfURL:(NSURL *)url completionHandler:(void (^)(NSImage *image))handler {
	NSThread *currentThread = [NSThread currentThread];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
		[currentThread performAsyncBlock:^{
			handler(image);
		}];
	});
}

+ (NSImage *)ajr_imageWithSize:(NSSize)size scales:(NSArray<NSNumber *> *)scales flipped:(BOOL)flipped colorSpace:(NSColorSpace *)colorSpace commands:(void (^)(CGFloat scale))commands {
	NSMutableArray<NSBitmapImageRep *> *images = [NSMutableArray array];
	
	for (NSNumber *scale in scales) {
		CGImageRef subimage = NULL;
		
		@try {
			subimage = AJRCreateImage(size, [scale doubleValue], flipped, [colorSpace CGColorSpace], ^(CGContextRef context) {
				NSGraphicsContext *savedContext = [NSGraphicsContext currentContext];
				NSGraphicsContext *nsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:flipped];
				[NSGraphicsContext setCurrentContext:nsContext];
				commands([scale doubleValue]);
				[NSGraphicsContext setCurrentContext:savedContext];
			});
		} @catch (NSException *localException) {
			AJRLogWarning(@"Exception while rendering image: %@\n%@", localException, [localException callStackSymbols]);
		}
		if (subimage) {
			// Might be NULL on an exception
			NSBitmapImageRep *bitmapImage = [[NSBitmapImageRep alloc] initWithCGImage:subimage];
			[images addObject:bitmapImage];
		}
	}
	
	NSImage *finalImage = nil;
	if ([images count]) {
		finalImage = [[NSImage alloc] initWithSize:size];
		[finalImage addRepresentations:images];
	}
	
	return finalImage;
}

- (CGImageRef)ajr_CGImage {
    // Loop the images and see if we can't find a representation with good CGImageRef, first.
    CGImageRef result = NULL;
    // Note currentContext can be NULL, but that OK, because NSImage has appropriate fall backs.
    NSImageRep *possible = [self bestRepresentationForRect:(NSRect){NSZeroPoint, [self size]} context:[NSGraphicsContext currentContext] hints:nil];
    
    result = [possible respondsToSelector:@selector(CGImage)] ? [(NSBitmapImageRep *)possible CGImage] : nil;
    
    if (result == NULL) {
        // Didn't find a match, so let's just take the first image that has a CGImageRep
        for (possible in [self representations]) {
            result = [possible respondsToSelector:@selector(CGImage)] ? [(NSBitmapImageRep *)possible CGImage] : nil;
            if (result) {
                break;
            }
        }
    }

    // Still no luck? Let's match again, and then ask that image to make a CGImageRef of itself.
    if (result == NULL) {
        NSImageRep *possible = [self bestRepresentationForRect:(NSRect){NSZeroPoint, [self size]} context:[NSGraphicsContext currentContext] hints:nil];
        if (possible == nil) {
            if (self.representations.count == 0) {
                // We don't have any representations, so just create a blank image
                result = AJRCreateImage([self size], 1.0, NO, NULL, ^(CGContextRef context) {
                    // Just go with nothing.
                });
            } else {
                possible = [[self representations] firstObject];
            }
        }
        if (possible) {
            result = [possible CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
        }
    }
    
    return result;
}

- (NSData *)ajr_JPEGRepresentation {
    return [self ajr_JPEGRepresentationWithQuality:0.8];
}

- (NSData *)ajr_JPEGRepresentationWithQuality:(CGFloat)quality; {
    CGImageRef imageRef = [self ajr_CGImage];
    return imageRef ? AJRJPEGDataFromCGImage(imageRef, quality) : nil;
}

- (NSData *)ajr_GIFRepresentation {
    return [self ajr_GIFRepresentationWithDitheredTransparency:YES];
}

- (NSData *)ajr_GIFRepresentationWithDitheredTransparency:(BOOL)flag; {
    CGImageRef imageRef = [self ajr_CGImage];
    return imageRef ? AJRGIFDataFromCGImage(imageRef, flag) : nil;
}

- (NSData *)ajr_BMPRepresentation {
    CGImageRef imageRef = [self ajr_CGImage];
    return imageRef ? AJRBMPDataFromCGImage(imageRef) : nil;
}

- (NSData *)ajr_PNGRepresentation {
    return [self ajr_PNGRepresentationWithInterlacing:YES];
}

- (NSData *)ajr_PNGRepresentationWithInterlacing:(BOOL)flag; {
    CGImageRef imageRef = [self ajr_CGImage];
    return imageRef ? AJRPNGDataFromCGImage(imageRef, flag) : nil;
}

- (NSImage *)ajr_imageMattedWithColor:(NSColor *)color {
    NSImage        *newImage;
    
    newImage = [[NSImage alloc] initWithSize:[self size]];
    [newImage lockFocus];
    [color set];
    NSRectFill((NSRect){{0.0, 0.0}, [self size]});
    [self drawAtPoint:NSZeroPoint fromRect:(NSRect){{0.0, 0.0}, [self size]} operation:NSCompositingOperationDestinationIn fraction:1.0];
    [self drawAtPoint:NSZeroPoint fromRect:(NSRect){{0.0, 0.0}, [self size]} operation:NSCompositingOperationSourceOver fraction:1.0];
    [newImage unlockFocus];

    return newImage;
}

- (NSImage *)ajr_templateImageWithColor:(NSColor *)color {
    NSImage    *newImage = [[NSImage alloc] initWithSize:[self size]];
    
    [newImage lockFocus];
    [color set];
    NSRectFill((NSRect){NSZeroPoint, [self size]});
    [self drawAtPoint:NSZeroPoint fromRect:(NSRect){{0.0, 0.0}, [self size]} operation:NSCompositingOperationDestinationIn fraction:1.0];
    [newImage unlockFocus];
    
    return newImage;
}

- (NSImage *)ajr_imageTintedWithColor:(NSColor *)color {
	NSImage *image = [self copy];
	[image setTemplate:NO];
	[image lockFocus];
	[color set];
	NSRectFillUsingOperation((NSRect){NSZeroPoint, [image size]}, NSCompositingOperationSourceAtop);
	[image unlockFocus];
	return image;
}

+ (NSImage *)ajr_colorSwatch:(NSColor *)color ofSize:(NSSize)size {
    NSImage *image = [[NSImage alloc] initWithSize:size];
    
    [image lockFocus];
    [color set];
    NSRectFill((NSRect){NSZeroPoint, size});
    [[NSColor blackColor] set];
    NSFrameRect((NSRect){NSZeroPoint, size});
    [image unlockFocus];
    
    return image;
}

+ (NSArray *)ajr_threePartImagesWithHeight:(CGFloat)height
								 leftWidth:(CGFloat)leftWidth
							   centerWidth:(CGFloat)centerWidth
								rightWidth:(CGFloat)rightWitdh
						   andDrawnByBlock:(void (^)(NSSize size))drawingBlock {
	__block NSImage *baseImage;
	CGFloat fullWidth = leftWidth + centerWidth + rightWitdh;
	
	NSImage	* (^CreateImage)(CGFloat) = ^(CGFloat offset) {
		NSImage	*newImage = [[NSImage alloc] initWithSize:(NSSize){12.0, 12.0}];
		
		[newImage lockFocus];
		[baseImage drawAtPoint:(NSPoint){0.0, 0.0} fromRect:(NSRect){{offset, 0.0}, {12.0, 12.0}} operation:NSCompositingOperationCopy fraction:1.0];
		[newImage unlockFocus];
		
		return newImage;
	};
	
	baseImage = [[NSImage alloc] initWithSize:(NSSize){fullWidth, height}];
	[baseImage lockFocus];
	drawingBlock([baseImage size]);
	[baseImage unlockFocus];
	
	return [NSArray arrayWithObjects:CreateImage(0.0), CreateImage(12.0), CreateImage(24.0), nil];
}

- (void)setNaturalSize:(NSSize)aSize {
    objc_setAssociatedObject(self, DrawNaturalSizeKey, [NSValue valueWithSize:aSize], OBJC_ASSOCIATION_RETAIN);
}

- (NSSize)naturalSize {
    NSValue *value = objc_getAssociatedObject(self, DrawNaturalSizeKey);
    
    if (!value) return [self size];
    
    return [value sizeValue];
}

- (void)ajr_drawAtPoint:(NSPoint)point operation:(NSCompositingOperation)op {
    [self drawAtPoint:point fromRect:(NSRect){NSZeroPoint, [self size]} operation:op fraction:1.0];
}

- (void)ajr_flipCoordinateSystem {
    [NSAffineTransform scaleXBy:1.0 yBy:-1.0];
    [NSAffineTransform translateXBy:0.0 yBy:-[self size].height];
}

+ (BOOL)ajr_supportsFileExtension:(NSString *)extension {
    NSString *utiType;
    
    utiType = [[UTType typeWithFilenameExtension:extension.lowercaseString] preferredMIMEType];
    //utiType = (__bridge NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[extension lowercaseString], NULL);
    
    return [[NSImage imageTypes] containsObject:utiType];
}

#pragma mark - AJRXMLCoding

+ (NSString *)ajr_nameForXMLArchiving {
    return @"image";
}

- (Class)ajr_classForXMLArchiving {
    return [NSImage class];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    BOOL encodeData = YES;
    if (self.name) {
        [coder encodeString:self.name forKey:@"name"];
        encodeData = [NSImage imageNamed:self.name] != self;
    }
    if (self.isTemplate) {
        [coder encodeBool:YES forKey:@"template"];
    }
    if (encodeData) {
        [coder encodeObject:self.TIFFRepresentation forKey:@"data"];
    }
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRImageDecodingPlaceholder alloc] init];
}

- (NSImage *)imageForAppearance:(NSAppearance *)appearance {
    NSImage *newImage = self;
    
    if (newImage.isTemplate && appearance.isDarkMode) {
        newImage = [newImage ajr_imageMattedWithColor:NSColor.whiteColor];
    }
    
    return newImage;
}


@end
