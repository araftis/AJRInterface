//
//  AJRRibbonViewItem.h
//  AJRInterface
//
//  Created by A.J. Raftis on 8/12/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRSeparatorBorder;

@interface AJRRibbonViewItem : NSView
{
    AJRSeparatorBorder    *_border;
}

#pragma mark - Creation

- (id)initWithContentView:(NSView *)contentView;

#pragma mark - Properties

@property (strong) AJRSeparatorBorder *border;

@end
