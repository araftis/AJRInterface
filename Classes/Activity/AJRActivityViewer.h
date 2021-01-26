//
//  AJRActivityViewer.h
//
//  Created by A.J. Raftis on Mon Nov 18 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AJRInterface/AJRInterface.h>

@class AJRActivity, AJRActivityView;

@interface AJRActivityViewer : NSObject
{
   IBOutlet NSWindow            *window;
   IBOutlet AJRActivityView        *view;
   IBOutlet NSScrollView        *scrollView;
   IBOutlet NSTextField            *statusText;
   IBOutlet NSTextField            *progressText;
   IBOutlet NSButton            *stopButton;
}

+ (id)sharedInstance;

- (NSArray *)activities;
- (void)addActivity:(AJRActivity *)activity;
- (void)removeActivity:(AJRActivity *)activity;

- (void)stopActivity:(id)sender;
- (void)selectActivity:(id)sender;
- (void)showActivityPanel:(id)sender;

@end


@interface NSResponder (AJRActivityViewer)

- (void)showActivityPanel:(id)sender;

@end
