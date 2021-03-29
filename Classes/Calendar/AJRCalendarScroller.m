/*
AJRCalendarScroller.m
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

#import "AJRCalendarScroller.h"

#import "AJRImages.h"

#import <AJRFoundation/AJRFunctions.h>

@interface AJRCalendarScroller ()
+ (NSImage *)imageForPart:(NSString *)part state:(NSString *)state;
@end

@implementation AJRCalendarScroller

static NSString *AJRCalendarScrollerTrackTopPart = @"scrollTrackTop";
static NSString *AJRCalendarScrollerTrackBodyPart = @"scrollTrackMiddle";
static NSString *AJRCalendarScrollerTrackBottomPart = @"scrollTrackBottom";
static NSString *AJRCalendarScrollerThumbTopPart = @"scrollThumbTop";
static NSString *AJRCalendarScrollerThumbBodyPart = @"scrollThumbMiddle";
static NSString *AJRCalendarScrollerThumbBottomPart = @"scrollThumbBottom";

+ (NSImage *)imageForPart:(NSString *)part state:(NSString *)state {
    return [AJRImages imageNamed:part forClass:self];
}

#pragma mark NSScroller

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
    NSImage *slotTop = [[self class] imageForPart:AJRCalendarScrollerTrackTopPart state:nil];
    NSImage *slotBody = [[self class] imageForPart:AJRCalendarScrollerTrackBodyPart state:nil];
    NSImage *slotBottom = [[self class] imageForPart:AJRCalendarScrollerTrackBottomPart state:nil];
    NSRect bodyRect, bottomRect, topRect;
    
    //AJRPrintf(@"%C: frame: %R, slotRect: %R\n", self, [self frame], slotRect);

    NSDivideRect(slotRect, &topRect, &bodyRect, slotTop.size.height, NSMaxYEdge);
    NSDivideRect(bodyRect, &bottomRect, &bodyRect, slotBottom.size.height, NSMinYEdge);

    [slotBody drawInRect:bodyRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [slotBottom drawInRect:bottomRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];    
    [slotTop drawInRect:topRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)drawKnob {
    NSImage *thumbTop = [[self class] imageForPart:AJRCalendarScrollerThumbTopPart state:nil];
    NSImage *thumbBottom = [[self class] imageForPart:AJRCalendarScrollerThumbBottomPart state:nil];
    NSImage *thumbBody = [[self class] imageForPart:AJRCalendarScrollerThumbBodyPart state:nil];
    NSRect bodyRect, bottomRect, topRect;
    
    NSDivideRect(NSIntegralRect(NSInsetRect([self rectForPart:NSScrollerKnob], 1.0, 0.0)), &topRect, &bodyRect, thumbTop.size.height, NSMaxYEdge);
    NSDivideRect(bodyRect, &bottomRect, &bodyRect, thumbBottom.size.height, NSMinYEdge);
    
    [thumbBody drawInRect:bodyRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [thumbBottom drawInRect:bottomRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];    
    [thumbTop drawInRect:topRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (BOOL)isOpaque {
    return NO;
}

@end
