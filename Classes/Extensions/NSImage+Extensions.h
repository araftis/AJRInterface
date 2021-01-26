//
//  NSImage-Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/6/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AJRFoundation/AJRFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (AJRInterfaceExtensions) <AJRXMLCoding>

/*! Creates and returns a new NSImage that's the same size as the passed in imageRep. */
+ (instancetype)ajr_imageWithImageRep:(NSImageRep *)imageRep;
/*! Creates and returns a new NSImage that's the size of the passed in size. */
+ (instancetype)ajr_imageWithImageRep:(NSImageRep *)imageRep size:(NSSize)size;
/*! Creates and return s a new NSIamage that's the same size as the passed in imageRep scaled by scale. */
+ (instancetype)ajr_imageWithImageRep:(NSImageRep *)imageRep scale:(CGFloat)scale;

+ (void)ajr_imageWithContentsOfURL:(NSURL *)url completionHandler:(void (^)(NSImage * _Nullable image))handler NS_SWIFT_NAME(contents(of:completionHandler:));

+ (NSImage *)ajr_imageWithSize:(NSSize)size scales:(NSArray<NSNumber *> *)scales flipped:(BOOL)flipped colorSpace:(nullable NSColorSpace *)colorSpace commands:(void (^)(CGFloat scale))commands;

/*! Returns a CGImageRef of the receiver. This will basically try to get the best representation and return that image, even if that means it must render the image. For example, if the receiver only contains and NSPDFImageRep, that will be rasterized, and a CGImageRef of that rasterization will be returned. */
- (CGImageRef)ajr_CGImage;

@property (nullable,nonatomic,readonly) NSData *ajr_JPEGRepresentation;
- (nullable NSData *)ajr_JPEGRepresentationWithQuality:(CGFloat)quality;
@property (nullable,nonatomic,readonly) NSData *ajr_GIFRepresentation;
- (nullable NSData *)ajr_GIFRepresentationWithDitheredTransparency:(BOOL)flag;
@property (nullable,nonatomic,readonly) NSData *ajr_PNGRepresentation;
- (nullable NSData *)ajr_PNGRepresentationWithInterlacing:(BOOL)flag;
@property (nullable,nonatomic,readonly) NSData *ajr_BMPRepresentation;

- (NSImage *)ajr_imageMattedWithColor:(NSColor *)color;
- (NSImage *)ajr_templateImageWithColor:(NSColor *)color;
- (NSImage *)ajr_imageTintedWithColor:(NSColor *)color;

+ (NSImage *)ajr_colorSwatch:(NSColor *)color ofSize:(NSSize)size;
+ (NSArray<NSImage *> *)ajr_threePartImagesWithHeight:(CGFloat)height
								 leftWidth:(CGFloat)leftWidth
							   centerWidth:(CGFloat)centerWidth
								rightWidth:(CGFloat)rightWitdh
						   andDrawnByBlock:(void (^)(NSSize size))drawingBlock;

- (void)setNaturalSize:(NSSize)aSize;
- (NSSize)naturalSize;

- (void)ajr_drawAtPoint:(NSPoint)point operation:(NSCompositingOperation)op;

- (void)ajr_flipCoordinateSystem;

+ (BOOL)ajr_supportsFileExtension:(NSString *)extension;

- (NSImage *)imageForAppearance:(NSAppearance *)appearance;

@end

NS_ASSUME_NONNULL_END
