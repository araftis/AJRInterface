//
//  AJRCalendarScroller.m
//  OnlineStoreManager
//
//  Created by Mike Lee on 1/13/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

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
