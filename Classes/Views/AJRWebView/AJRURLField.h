//
//  MBURLField.h
//  Web Tool
//
//  Created by A.J. Raftis on 4/4/07.
//  Copyright 2007 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRURLField : NSTextField <NSDraggingSource, NSDraggingDestination>

// Defined as a category on NSContol.
//@property (nullable,nonatomic,strong) NSURL *URLValue NS_SWIFT_NAME(urlValue);
@property (null_resettable,nonatomic,strong) NSString *titleForDrag; // If set to nil, will return URL string value.

@property (nullable,nonatomic,strong) NSImage *icon;
@property (nullable,nonatomic,readonly) NSImage *displayIcon;
@property (nonatomic,readonly) NSButton *reloadButton;

@property (nonatomic,assign) double progress;
- (void)noteProgressComplete;

@end

NS_ASSUME_NONNULL_END
