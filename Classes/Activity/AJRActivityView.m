/*
 AJRActivityView.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
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

#import "AJRActivityView.h"

#import <AJRFoundation/AJRActivity.h>

@implementation AJRActivityView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    activities = [[NSMutableArray alloc] init];
    lock = [[NSRecursiveLock alloc] init];
    [self tile];
    
    return self;
}


- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return YES;
}

- (void)setTarget:(id)aTarget
{
    if (target != aTarget) {
        target = aTarget;
    }
}

- (id)target
{
    return target;
}

- (void)setAction:(SEL)anAction
{
    action = anAction;
}

- (SEL)action
{
    return action;
}

- (void)tile
{
    NSInteger            x;
    AJRActivity        *activity;
    NSRect        rect;
    NSView        *view;
    
    [lock lock];
    rect = (NSRect){{0.0, 0.0}, {[self frame].size.width, 0.0}};
    for (x = 0; x < (const NSInteger)[activities count]; x++) {
        activity = [activities objectAtIndex:x];
        view = [activity view];
        rect.size.height = [view frame].size.height;
        [(NSView *)[activity view] setFrame:rect];
        rect.origin.y += rect.size.height + 1;
    }
    
    [self setFrame:(NSRect){{0.0, 0.0}, {[self frame].size.width, rect.origin.y + 1.0}}];
    [lock unlock];
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)drawRect
{
    NSInteger            x;
    NSRect        rect;
    NSView        *view;
    NSRect        frame;
    
    rect = (NSRect){{0.0, 0.0}, {[self frame].size.width, 1.0}};
    [[NSColor lightGrayColor] set];
    for (x = 0; x < (const NSInteger)[activities count]; x++) {
        view = [[activities objectAtIndex:x] view];
        frame = [view frame];
        rect.origin.y = frame.origin.y + frame.size.height + 1;
        NSRectFill(rect);
        if (selectedActivity == [activities objectAtIndex:x]) {
            if (x == 0) {
                frame.size.height += 1.0;
            } else {
                frame.origin.y += 1.0;
            }
            [[NSColor selectedControlColor] set];
            NSRectFill(frame);
            [[NSColor lightGrayColor] set];
        }
    }
}

- (NSArray *)activities
{
    return activities;
}

- (void)addActivity:(AJRActivity *)activity
{
    [lock lock];
    [activities addObject:activity];
    [self addSubview:[activity view]];
//    [activity addObserver:self forKeyPath:@"messages" options:0 context:NULL];
    [self tile];
    [lock unlock];
}

- (void)removeActivity:(AJRActivity *)activity
{
    [lock lock];
    [[activity view] removeFromSuperview];
    if (selectedActivity == activity) {
        selectedActivity = nil;
    }
//    @try {
//        [activity removeObserver:self forKeyPath:@"messages"];
//    } @catch (NSException *exception) { }
    [activities removeObject:activity];
    [self tile];
    [lock unlock];
}

- (void)selectActivityAtIndex:(NSUInteger)index
{
    selectedActivity = [activities objectAtIndex:index];
    [self setNeedsDisplay:YES];
}

- (AJRActivity *)selectedActivity
{
    return selectedActivity;
}

- (AJRActivity *)activityForPoint:(NSPoint)aPoint
{
    NSInteger        x;
    AJRActivity        *activity;
    NSView            *view;
    NSRect            frame;
    
    for (x = 0; x < (const NSInteger)[activities count]; x++) {
        activity = [activities objectAtIndex:x];
        view = [activity view];
        frame = [view frame];
        if (NSPointInRect(aPoint, frame)) return activity;
    }
    
    return nil;
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint        location = [self convertPoint:[event locationInWindow] fromView:nil];
    AJRActivity        *activity = [self activityForPoint:location];
    
    if (selectedActivity != activity) {
        selectedActivity = activity;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseDragged:(NSEvent *)event
{
    NSPoint        location = [self convertPoint:[event locationInWindow] fromView:nil];
    AJRActivity    *activity = [self activityForPoint:location];
    
    if (selectedActivity != activity) {
        selectedActivity = activity;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseUp:(NSEvent *)event
{
    NSPoint        location = [self convertPoint:[event locationInWindow] fromView:nil];
    
    selectedActivity = [self activityForPoint:location];
    [self setNeedsDisplay:YES];
    [NSApp sendAction:[self action] to:[self target] from:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self tile];
}

@end
