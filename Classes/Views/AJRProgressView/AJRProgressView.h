//
//  AJRProgressView.h
//  AJRInterface
//
//  Created by A.J. Raftis on 8/31/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface AJRProgressView : NSView
{
    NSColor                *_backgroundColor;
}

@property (nonatomic,strong) NSColor *backgroundColor;

@end
