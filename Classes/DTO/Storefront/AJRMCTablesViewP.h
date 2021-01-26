//
//  AJRMCTablesView.h
//  AJRInterface
//
//  Created by Alex Raftis on 2/9/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import "AJRMarketingContextChooser.h"

@class AJRMarketingContextChooser;

@interface AJRMCTablesView : NSView
{
    AJRMarketingContextChooser    *_chooser;
    AJRMarketingContextPartMask    _focused;
}

@property (nonatomic,retain) IBOutlet AJRMarketingContextChooser *chooser;

- (void)tileWithAnimation:(BOOL)animate;
- (void)tile;

@end
