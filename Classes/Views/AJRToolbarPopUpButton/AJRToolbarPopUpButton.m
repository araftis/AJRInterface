/*
 AJRToolbarPopUpButton.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import "AJRToolbarPopUpButton.h"

#import "AJRToolbarPopUpButtonCell.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRTrigonometry.h>

@implementation AJRToolbarPopUpButton

+ (Class)cellClass {
    return [AJRToolbarPopUpButtonCell class];
}

- (void)_setup {
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _setup];
    }
    return self;
}

- (void)setButtonMenu:(NSMenu *)menu {
    if (menu != _buttonMenu) {
        _buttonMenu = menu;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];

    if (self.menu) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        NSRect bounds = [self bounds];
        CGFloat x;
        CGFloat radius = 3.0;
        NSPoint center;
        
		if ([self bezelStyle] == NSBezelStyleSmallSquare) {
            center.x = bounds.origin.x + bounds.size.width - radius - 3.0;
            center.y = bounds.origin.y + (bounds.size.height - radius) / 2.0 + 1.0;
        } else {
            center.x = bounds.origin.x + bounds.size.width - radius - 1.0;
            center.y = bounds.origin.y + bounds.size.height - radius - 1.0;
        }
        
        for (x = 0.0; x < 360.0; x += (360.0 / 3.0)) {
            NSPoint    point;
            
            point.x = AJRSin(x) * 3.0 + center.x;
            point.y = AJRCos(x) * 3.0 + center.y;
            
            if (x == 0.0) {
                [path moveToPoint:point];
            } else {
                [path lineToPoint:point];
            }
        }
        [path closePath];
        if ([self isEnabled]) {
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.75] set];
        } else {
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
        }
        [path fill];
    }
}

- (NSPoint)pointForEvent:(NSEvent *)event {
    return [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void)popUpMenuWithEvent:(NSEvent *)event {
    NSEvent *newEvent;
    NSPoint newWhere;
    NSRect bounds = [self bounds];
    
    newWhere = [self convertPoint:(NSPoint){0.0, bounds.origin.y + bounds.size.height + 4.0} toView:nil];
    newEvent = [NSEvent mouseEventWithType:[event type]
                                   location:newWhere 
                             modifierFlags:[event modifierFlags] 
                                 timestamp:[event timestamp] 
                              windowNumber:[event windowNumber]
                                   context:nil
                               eventNumber:[event eventNumber]
                                clickCount:[event clickCount]
                                  pressure:[event pressure]];

    [NSMenu popUpContextMenu:self.menu withEvent:newEvent forView:self];
    [[self cell] setHighlighted:NO];
}

- (void)_popUpMenuWithEvent:(NSEvent *)event {
    [self popUpMenuWithEvent:event];
}

- (void)mouseDown:(NSEvent *)event {
    if (![self isEnabled]) return;
    
    [[self cell] setHighlighted:YES];
    
    if (self.popDelay <= 0.0 && [self menu] != nil) {
//        [NSMenu popUpContextMenu:self.menu withEvent:event forView:self];
//        [[self cell] setHighlighted:NO];
        [self popUpMenuWithEvent:event];
    } else if (self.popDelay > 0.0) {
        [self performSelector:@selector(_popUpMenuWithEvent:) withObject:event afterDelay:self.popDelay];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint where = [self pointForEvent:event];
    
    if (![self isEnabled]) return;
    
    if (self.popDelay > 0.0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [NSMenu popUpContextMenu:self.menu withEvent:event forView:self];
//        [[self cell] setHighlighted:NO];
        [self popUpMenuWithEvent:event];
    } else {
        if (NSPointInRect(where, [self bounds])) {
            [[self cell] setHighlighted:YES];
        } else {
            [[self cell] setHighlighted:NO];
        }
    }
}

- (void)mouseUp:(NSEvent *)event {
    NSPoint where = [self pointForEvent:event];

    if (![self isEnabled]) return;
    
    [[self cell] setHighlighted:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (NSPointInRect(where, [self bounds])) {
        if ([self action] != NULL) {
            [NSApp sendAction:[self action] to:[self target] from:self];
        }
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self _setup];
        
        self.menu = [coder decodeObjectForKey:@"menu"];
        self.popDelay = [coder decodeDoubleForKey:@"popDelay"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_buttonMenu forKey:@"menu"];
    [coder encodeDouble:_popDelay forKey:@"popDelay"];
}

@end
