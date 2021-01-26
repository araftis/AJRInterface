//
//  AJRImageSaveAccessory.h
//  LDView
//
//  Created by alex on Thu Nov 15 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class AJRImageFormat;

@interface AJRImageSaveAccessory : NSObject

- (instancetype)initWithSavePanel:(NSSavePanel *)savePanel;

- (AJRImageFormat *)currentImageFormat;

- (NSView *)view;

- (void)selectFormat:(id)sender;

- (NSData *)representationForImage:(NSImage *)image;

@end
