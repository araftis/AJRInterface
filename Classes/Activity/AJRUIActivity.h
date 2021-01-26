//
//  AJRActivity.h
//
//  Created by A.J. Raftis on Mon Nov 18 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRActivity.h>

@interface AJRUIActivity : AJRActivity
{
   IBOutlet NSView                *view;
   IBOutlet NSProgressIndicator    *progressView;
   IBOutlet NSTextField            *messageText;
}

@end
