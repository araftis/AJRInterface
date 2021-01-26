//
//  AJRPagedScrollView.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/22/11.
//  Copyright 2011 A.J. Raftis. All rights reserved.
//

#import <AppKit/AppKit.h>

@class AJRPagedView;

@interface AJRPagedScrollView : NSScrollView
{
    NSPopUpButton *_viewPopUp;
    NSTextField *_pagesLabel;
    NSGradient *_controlsGradient;
    NSColor *_controlsDividerColor;
    NSColor *_controlsTopDividerColor;
}

@property (nonatomic,readonly) AJRPagedView *pagedView;
@property (nonatomic,assign) CGFloat scale;

@end
