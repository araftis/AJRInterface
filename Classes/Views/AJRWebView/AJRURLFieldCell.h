//
//  AJRURLFieldCell.h
//  AJRInterface
//
//  Created by A.J. Raftis on 11/13/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRURLFieldCell : NSTextFieldCell

@property (nonatomic,class,readonly) NSImage *backgroundImage;

@property (nonatomic,strong) NSImage *icon;
@property (nonatomic,readonly) NSImage *displayIcon;

@property (nonatomic,assign) double progress;
- (void)noteProgressComplete;

#pragma mark - Layout

- (NSRect)textRectForBounds:(NSRect)cellFrame;
- (NSRect)iconRectForBounds:(NSRect)cellFrame;

@end


