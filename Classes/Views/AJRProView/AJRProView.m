/*
AJRProView.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AJRProView.h"

@implementation AJRProView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [NSGraphicsContext saveGraphicsState];
    
    // Create the shadow below and to the right of the shape.
    NSShadow* theShadow = [[NSShadow alloc] init];
    [theShadow setShadowOffset:NSMakeSize(10.0, -10.0)];
    [theShadow setShadowBlurRadius:3.0];
    
    // Use a partially transparent color for shapes that overlap.
    [theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
    
    [theShadow set];
    
    // Draw your custom content here. Anything you draw
    // automatically has the shadow effect applied to it.

    NSRect bounds = [self bounds];
    
    NSBezierPath* clipShape = [NSBezierPath bezierPath];
    [clipShape appendBezierPathWithRoundedRect:bounds xRadius:20 yRadius:20];
    
    NSColor *top = [NSColor colorWithDeviceRed:190.0 / 255.0 green:190.0 / 255.0 blue:190.0 / 255.0 alpha:1.0];
    NSColor *bottom = [NSColor colorWithDeviceRed:64.0 / 255.0 green:64.0 / 255.0 blue:64.0 / 255.0 alpha:1.0];

    NSGradient* aGradient = [[NSGradient alloc] initWithColorsAndLocations:top, (CGFloat)0.0,
                             bottom, (CGFloat)1.0,
                             nil];
    
    [aGradient drawInBezierPath:clipShape angle:-90.0];
    
    // end shadow
    [NSGraphicsContext restoreGraphicsState];
}

@end
