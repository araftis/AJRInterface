
#import "AJRProduct-Assets.h"

#import "AJRImages.h"

#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRFoundation.h>
#import <Log4Cocoa/Log4Cocoa.h>

NSString *AJRProductIconDidLoadNotification = @"AJRProductIconDidLoadNotification";

@implementation AJRProduct (Assets)

+ (NSImage *)unknownImage
{
    return [AJRImages imageNamed:@"imagePlaceHolder70"];
}

- (NSDictionary *)ajrsetDataForSize:(NSString *)sizeString;
{
    NSDictionary    *ajrset = nil;
    
    [imagesLock lock];
    @try {
        if (ajrsets == nil) {
            ajrsets = [[NSMutableDictionary alloc] init];
        }
    } @finally {
        [imagesLock unlock];
    }
    
    ajrset = [ajrsets objectForKey:sizeString];
    if (ajrset == nil) {
        ajrset = [[self.environment ajrsetService] getImageDataForIdentifier:[self partNumber] type:@"product" size:sizeString andMarketingContext:[[self environment] marketingContext]];
        if (ajrset) {
            [ajrsets setObject:ajrset forKey:sizeString];
        }
    }
    
    return ajrset;
}

- (NSURL *)ajrsetURLForSize:(NSString *)sizeString
{
    NSDictionary    *ajrset = [self ajrsetDataForSize:sizeString];
    if (ajrset != nil) {
        return [NSURL URLWithString:[ajrset objectForKey:@"url"]];
    }
    return nil;
}

- (NSArray *)imageSizes
{
    return [[[self environment] ajrsetService] getSizesForType:@"product"];
}

- (NSImage *)imageForSize:(NSString *)sizeString key:(NSString *)key loadGeneric:(BOOL)loadGeneric
{
    return [self firstImageForSize:[NSArray arrayWithObject:sizeString] key:key loadGeneric:loadGeneric];
}

- (NSString *)imageLoadTokenForKey:(NSString *)key
{
    [imagesLock lock];
    @try {
        if (imageLoadTokens == nil) {
            imageLoadTokens = [[NSMutableSet alloc] init];
        }
    } @finally {
        [imagesLock unlock];
    }
    
    @synchronized (imageLoadTokens) {
        if ([imageLoadTokens containsObject:key]) return nil;
        [imageLoadTokens addObject:key];
    }
    
    return key;
}

- (void)releaseImageTokenForKey:(NSString *)key
{
    @synchronized (imageLoadTokens) {
        [imageLoadTokens removeObject:key];
    }
}

- (NSSize)sizeFromURL:(NSString *)rawURL
{
    NSRange        fragmentRange = [rawURL rangeOfString:@"?"];
    NSArray        *parts = nil;
    NSSize        size = NSZeroSize;
    
    if (fragmentRange.location != NSNotFound) {
        parts = [[rawURL substringFromIndex:fragmentRange.location + fragmentRange.length] componentsSeparatedByString:@"&"];
    }
    
    if (parts) {
        for (NSString *part in parts) {
            if ([part hasPrefix:@"wid"]) {
                size.width = [[part substringFromIndex:4] floatValue];
            } else if ([part hasPrefix:@"hei"]) {
                size.height = [[part substringFromIndex:4] floatValue];
            }
        }
    }
    
    return size;
}

- (void)backgroundImageLoadForParameters:(NSDictionary *)parameters
{
    NSArray                *sizeStrings = [[parameters objectForKey:@"sizeStrings"] retain];
    NSString            *key = [[parameters objectForKey:@"key"] retain];
    BOOL                loadGeneric = [[parameters objectForKey:@"loadGeneric"] boolValue];
    AJRMarketingContext    *marketingContext = [[parameters objectForKey:@"marketingContext"] retain];
    NSImage                *image = nil;
    AJRActivity            *activity = [[parameters objectForKey:@"activity"] retain];
    
    if (marketingContext == nil) {
        marketingContext = [[[self environment] marketingContext] retain];
    }
    
    @try {
        NSURL        *url = nil;
        NSURL        *genericURL = nil;
        for (NSString *sizeString in sizeStrings) {
            // First try the old style catalog images. These are slowing going away, but until they've all been replaced by new system, we still need to try the old.
            image = [[self catalogImageForKey:sizeString inMarketingContext:marketingContext] retain];
            log4Debug(@"Catalog image (%@): %@", key, image);
            if (image == nil) {
                @try {
                    url = [self ajrsetURLForSize:sizeString];
                } @catch (NSException *exception) {
                    url = nil;
                }
                log4Debug(@"Image URL (%@): %@", key, url);
                if (url != nil) {
                    if ([[url description] rangeOfString:@"NOIMAGE"].location != NSNotFound) {
                        NSURL        *otherURL;
                        NSString    *part = nil;
                        NSSize        size;
                        
                        if (genericURL == nil) {
                            genericURL = url;
                        }
                        
                        if ([[self instanceType] isEqualToString:@"CC"]) {
                            part = [[self parent] partNumber];
                        }
                        if (part == nil) {
                            part = [self partNumber];
                            if ([part length] > 5) {
                                part = [part substringToIndex:5];
                            }
                        }
                        size = [self sizeFromURL:[url description]];
                        if (size.width == 0.0 || size.height == 0.0) {
                            otherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://as-images.apple.com/is/image/AppleInc/%@?wid=75&hei=75&fmt=jpeg&qlt=95&op_sharpen=1&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0", part]];
                        } else {
                            otherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://as-images.apple.com/is/image/AppleInc/%@?wid=%d&hei=%d&fmt=jpeg&qlt=95&op_sharpen=1&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0", part, (NSInteger)size.width, (NSInteger)size.height]];
                        }
                        image = [[NSImage alloc] initWithContentsOfURL:otherURL];
                    } else {
                        log4Debug(@"Creating image from %@", url);
                        image = [[NSImage alloc] initWithContentsOfURL:url];
                    }
                }
            }
            // We found something of interest, so stop looking.
            if (image) break;
        }
        if (image == nil && loadGeneric && genericURL != nil) {
            // We failed to get an alternate image, so load the first, which will be a "generic" image.
            image = [[NSImage alloc] initWithContentsOfURL:genericURL];
        }
        [self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:key waitUntilDone:YES];
        log4Debug(@"%@: %@", key, image);
        if (image != nil) {
            [images setObject:image forKey:key];
            [image release];
        } else {
            [images setObject:[AJRImages imageNamed:@"imagePlaceHolder70"] forKey:key];
        }
        [self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:key waitUntilDone:YES];
    } @catch (NSException *exception) {
        log4Error(@"Exception while loading image: %@", exception);
    } @finally {
        [activity setStopped:YES];
        [activity removeFromViewer];
        [[NSRunLoop currentRunLoop] ping];
        [activity release];
        [sizeStrings release];
        [key release];
        [marketingContext release];
        [self releaseImageTokenForKey:key];
    }
}

- (NSImage *)firstImageForSize:(NSArray *)sizeStrings key:(NSString *)key loadGeneric:(BOOL)loadGeneric
{
    id        image = nil;
    
    [imagesLock lock];
    @try {
        if (images == nil) {
            images = [[NSMutableDictionary alloc] init];
        }
    } @finally {
        [imagesLock unlock];
    }
    
    // This could lead to multiple attempts to load the image, but that'll be blocked by the failure to get the image token below.
    image = [images objectForKey:key];
    if (image == nil) {
        //log4Debug(@"Will load key: %@", key);
        if ([self imageLoadTokenForKey:key]) {
            NSInvocationOperation    *operation;
            NSMutableDictionary        *parameters = [[NSMutableDictionary alloc] init];
            AJRActivity                *activity = [[AJRActivity alloc] init];
            
            //log4Debug(@"Got token for key: %@", key);

            [activity setMessage:AJRFormat(@"Fetching image “%@” for %@...", key, [self partNumber])];
            [activity setIndeterminate:YES];
            [activity addToViewer];
            
            if (sizeStrings) [parameters setObject:sizeStrings forKey:@"sizeStrings"];
            if (key) [parameters setObject:key forKey:@"key"];
            [parameters setObject:[NSNumber numberWithBool:loadGeneric] forKey:@"loadGeneric"];
            [parameters    setObject:activity forKey:@"activity"];
            operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(backgroundImageLoadForParameters:) object:parameters];
            [[[self class] operationQueue] addOperation:operation];
            [parameters release];
            [operation release];
        }
        image = [AJRImages imageNamed:@"imagePlaceHolder70"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ajrproductgallerylargeimageloaded" object:[NSDictionary dictionaryWithObject:self forKey:@"product"]];
    }
    
    return image;
}

- (NSImage *)galleryZoomImage
{
    return [self imageForSize:@"gallery_zoom" key:@"galleryZoomImage" loadGeneric:YES];
}

- (NSImage *)galleryZoomHighImage
{
    return [self imageForSize:@"gallery_zoom_high" key:@"galleryZoomImage" loadGeneric:YES];
}

- (NSImage *)galleryTourImage
{
    return [self imageForSize:@"gallery_tour" key:@"galleryZoomImage" loadGeneric:YES];
}

- (NSImage *)galleryMainImage
{
    return [self imageForSize:@"gallery_main" key:@"galleryZoomImage" loadGeneric:YES];
}

- (NSImage *)galleryThumbImage
{
    return [self imageForSize:@"gallery_thumb" key:@"galleryZoomImage" loadGeneric:YES];
}

- (NSImage *)mediumThumbImage
{
    return [self imageForSize:@"medium_thumb" key:@"galleryZoomImage" loadGeneric:YES];
}

- (NSImage *)galleryLargeImage
{
    // Note, these two image sizes should be handled correctly, but at the moment, they aren't.
    return [self firstImageForSize:[NSArray arrayWithObjects:@"gallery_large", /*@"heroImage", @"collectionMemberImage",*/ nil] key:@"galleryLargeImage" loadGeneric:YES];
}

- (NSImage *)galleryZoomMediumImage
{
    return [self imageForSize:@"gallery_zoom_medium" key:@"galleryZoomMediumImage" loadGeneric:YES];
}

- (NSImage *)galleryZoomLowImage
{
    return [self imageForSize:@"gallery_zoom_low" key:@"galleryZoomLowImage" loadGeneric:YES];
}

- (NSImage *)galleryZoomNoneImage
{
    return [self imageForSize:@"gallery_zoom_none" key:@"galleryZoomNoneImage" loadGeneric:YES];
}

- (NSImage *)pimSmallImage
{
    return [self imageForSize:@"pim_small" key:@"pimSmallImage" loadGeneric:YES];
}

- (NSImage *)smallThumbImage
{
    return [self imageForSize:@"small_thumb" key:@"smallThumbImage" loadGeneric:YES];
}

- (NSImage *)pimMediumImage
{
    return [self imageForSize:@"pim_medium" key:@"galleryLargeImage" loadGeneric:YES];
}

- (NSImage *)catalogImageForKey:(NSString *)key inMarketingContext:(AJRMarketingContext *)marketingContext
{
    NSString    *value = [self valueForKey:key inMarketingContext:marketingContext];
    
    if (value == nil) {
        value = [self valueForKey:key inMarketingContext:[marketingContext marketingContextWithLanguageCode:@"en-us"]];
    }
    
    if (value) {
        return [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://storedev.apple.com/Catalog/US/Images/%@", value]]] autorelease];
    }
    
    return nil;
}

- (NSImage *)preferredIconImage
{
    // Note, these two image sizes should be handled correctly, but at the moment, they aren't.
    return [self firstImageForSize:[NSArray arrayWithObjects:@"pim_small", @"pim_medium", /*@"searchResultImage", @"heroImage",*/ nil] key:@"preferredIconImage" loadGeneric:YES];
}

#pragma mark String Functions
- (NSAttributedString *)nameAndPartNumber {
    //format the name
    NSMutableAttributedString *formattedName = nil;
    if(self.name != nil) {
        NSFont *regularFont = [NSFont fontWithName:@"Verdana" size:11.0];
        NSDictionary *nameAttributes = [[NSDictionary alloc]initWithObjectsAndKeys:regularFont, NSFontAttributeName, nil];
        formattedName = [[NSMutableAttributedString alloc]initWithString:self.name attributes:nameAttributes];
    }
    
    //format the part number (light grey and smaller font)
    NSFont *smallerFont = [NSFont fontWithName:@"Verdana" size:9.0];
    NSColor *lightGrey = [NSColor grayColor];
    
    NSMutableAttributedString *attributedPartNumber = nil;
    if(self.partNumber != nil) {
        [formattedName appendAttributedString:[(NSString *)[NSMutableAttributedString alloc] initWithString:@"\n"]];
        
        NSMutableDictionary *partNumberAttributes = [[NSMutableDictionary alloc]initWithObjectsAndKeys:smallerFont, NSFontAttributeName,
                                                                                                 lightGrey, NSForegroundColorAttributeName, nil];
        
        attributedPartNumber = [[NSMutableAttributedString alloc]initWithString:self.partNumber attributes:partNumberAttributes];
        if(formattedName != nil) {
            [formattedName appendAttributedString:attributedPartNumber];
        } else {
            formattedName = attributedPartNumber;
        }
    }
    
    return formattedName;
}

@end
