//
//  AJRRibbonView.h
//  AJRInterface
//
//  Created by A.J. Raftis on 8/6/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRSeparatorBorder;

@interface AJRRibbonView : NSView

@property (strong) AJRSeparatorBorder *border;
@property (copy) NSArray *viewControllers;

@end
