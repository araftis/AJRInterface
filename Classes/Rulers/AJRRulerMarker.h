//
//  AJRRulerMarker.h
//  Draw
//
//  Created by A.J. Raftis on 7/26/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface AJRRulerMarker : NSRulerMarker
{
    NSWindow            *_measureWindow;
    BOOL                _isRemoving;
}

@end
