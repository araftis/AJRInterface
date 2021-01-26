//
//  AJRSpeechBorder.h
//  AJRSpeechBorder
//
//  Created by A.J. Raftis on 7/17/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <AJRInterface/AJRBorder.h>

typedef enum _ajrSpeechOrigin {
    AJRSpeechOriginLeft = 0,
    AJRSpeechOriginRight = 1
} AJRSpeechOrigin;

@interface AJRSpeechBorder : AJRBorder
{
    NSColor            *_color;
    NSBezierPath    *_path;
    NSBezierPath    *_shinePath;
    NSGradient        *_shineGradient;    // Gradient used by the shine.
    NSShadow        *_noShadow;
    NSShadow        *_baseShadow;        // Shadow for entire speech bubble.
    NSShadow        *_edgeShadow;        // Dark shadow that highlights the bottom edge.
    NSShadow        *_darkShadow;        // Produces the dark shadow along the upper edge.
    NSShadow        *_highlightShadow;    // Produces the light shadow along the lower edge.
    NSRect            _previousRect;        // Used to track the drawing rect, so we know when to recache the path
    AJRSpeechOrigin    _speechOrigin;
}

@property (nonatomic,strong) NSColor *color;
@property (nonatomic,assign) AJRSpeechOrigin speechOrigin;

@end
