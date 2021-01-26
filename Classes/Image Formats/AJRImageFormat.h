//
//  AJRImageFormat.h
//  LDView
//
//  Created by alex on Thu Nov 15 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface AJRImageFormat : NSObject
{
   IBOutlet NSView        *view;
}

+ (void)registerFormat:(Class)aClass;
+ (NSArray *)formatNames;

+ (AJRImageFormat *)imageFormatForName:(NSString *)name;

- (NSString *)name;
- (NSString *)extension;
- (NSView *)view;
- (NSInteger)imageType;
- (NSDictionary *)properties;

@end
