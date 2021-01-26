//
//  _AJRCalendarPrintView.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/30/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRCalendarRenderer;

@interface _AJRCalendarPrintView : NSView 
{
    AJRCalendarRenderer    *_renderer;
}

- (id)initWithRenderer:(AJRCalendarRenderer *)renderer;

@end
