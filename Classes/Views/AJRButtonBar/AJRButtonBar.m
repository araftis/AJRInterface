/*
AJRButtonBar.m
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

#import "AJRButtonBar.h"

#import "AJRGradientColor.h"
#import "AJRImages.h"
#import "AJRSeparatorBorder.h"
#import "NSBezierPath+Extensions.h"
#import "NSView+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@interface AJRButtonBar ()

@property (nonatomic,strong) IBOutlet NSButton *buttonTemplate;
@property (nonatomic,strong) IBOutlet NSPopUpButton *popUpButtonTemplate;
@property (nonatomic,assign) NSInteger selectedButton;

@end

@implementation AJRButtonBar

#pragma mark Properties

- (void)setBorder:(AJRSeparatorBorder *)border {
    if (border != _border) {
        border = _border;
        [self setNeedsDisplay:YES];
    }
}

#pragma mark Creation

- (void)setup {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    [bundle loadNibNamed:@"AJRButtonBar" owner:self topLevelObjects:nil];

    _spacing = 4.0;
    _selectedButton = NSNotFound;

    _border = [[AJRSeparatorBorder alloc] init];
    [_border setBottomColor:[AJRGradientColor gradientColorWithColor:NSColor.separatorColor]];
    [_border setBackgroundColor:[AJRGradientColor gradientColorWithColor:NSColor.windowBackgroundColor]];
    [_border setTopColor:nil];
    
    [_border setInactiveBottomColor:[AJRGradientColor gradientColorWithColor:NSColor.separatorColor]];
    [_border setInactiveBackgroundColor:[AJRGradientColor gradientColorWithColor:NSColor.windowBackgroundColor]];
    [_border setInactiveTopColor:nil];

    [self setRedrawOnApplicationOrWindowStatusChange:YES];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

- (void)tile {
    for (NSInteger x = 0; x < [self numberOfButtons]; x++) {
        [self buttonAtIndex:x].frame = [self rectForIndex:x];
    }
    [self setNeedsDisplay:YES];
}

- (void)layout {
    [super layout];
    [self tile];
}

- (void)setSpacing:(CGFloat)spacing {
    if (spacing != _spacing) {
        _spacing = spacing;
        [self tile];
    }
}

- (void)setAlignment:(NSTextAlignment)alignment {
    if (_alignment != alignment) {
        _alignment = alignment;
        [self tile];
    }
}

- (NSInteger)numberOfButtons {
    return [self subviews].count;
}

- (void)setNumberOfButtons:(NSInteger)count {
    NSInteger currentCount = self.numberOfButtons;

    if (currentCount != count) {
        // Only do something if we're actually adding buttons.
        if (currentCount < count) {
            for (NSInteger x = 0; x < count - currentCount; x++) {
                [self addSubview:[self _createButtonForIndex:currentCount + x]];
            }
        } else {
            for (NSInteger x = 0; x < currentCount - count; x++) {
                [[self.subviews lastObject] removeFromSuperview];
            }
        }
        // We're going to re-tile.
        [self tile];
    }
}

- (NSButton *)_createButtonForIndex:(NSInteger)index {
    NSButton *button = (NSPopUpButton *)AJRCopyCodableObject(_buttonTemplate, Nil);
    [button setFrame:(NSRect){NSZeroPoint, {24.0, 24.0}}];
    button.target = self;
    button.action = @selector(selectButton:);
    return button;
}

- (NSPopUpButton *)_createPopUpButtonForIndex:(NSInteger)index {
    NSPopUpButton *button = (NSPopUpButton *)AJRCopyCodableObject(_popUpButtonTemplate, Nil);
    [button setFrame:(NSRect){NSZeroPoint, {24.0, 24.0}}];
    return button;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self setup];
    }
    return self;
}

- (NSButton *)buttonAtIndex:(NSInteger)index {
    return AJRObjectIfKindOfClass(self.subviews[index], NSButton);
}

- (NSRect)rectForIndex:(NSInteger)index {
    NSRect frame = [self bounds];
    NSRect buttonFrame = NSZeroRect;
    NSArray *subviews = [self subviews];
    NSInteger subviewsCount = [subviews count];

    frame.size.width = 0.0;

    BOOL needsSpace = NO;
    for (NSInteger x = 0; x < subviewsCount; x++) {
        NSButton *button = [self buttonAtIndex:x];

        if (button.isHidden) {
            frame.size.width = 0.0;
        } else {
            if (needsSpace) {
                frame.origin.x += _spacing;
            }
            frame.origin.x += frame.size.width;
            if ([button isKindOfClass:NSPopUpButton.class]) {
                frame.size.width = 36.0;
            } else {
                frame.size.width = 24.0;
            }
            needsSpace = YES;
        }
        if (x == index) {
            buttonFrame = frame;
        }
    }

    CGFloat fullWidth = frame.origin.x + frame.size.width;
    switch (_alignment) {
        case NSTextAlignmentLeft:
            // Nothing to do, we're left aligned by default.
            break;
        case NSTextAlignmentCenter:
            buttonFrame.origin.x += (self.bounds.size.width - fullWidth) / 2.0;
            break;
        case NSTextAlignmentRight:
            buttonFrame.origin.x += (self.bounds.size.width - fullWidth);
        case NSTextAlignmentNatural:
            // We don't handle this.
            break;
        case NSTextAlignmentJustified:
            // We don't handle this yet, but it'd be nice if we distributed the buttons evenly across the frame.
            break;
    }

    return buttonFrame;
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    [_border drawBorderInRect:bounds controlView:self];

//    [NSColor.redColor set];
//    [[NSBezierPath bezierPathWithCrossedRect:NSInsetRect(self.bounds, 0.5, 0.5)] stroke];
}

- (void)setEnabled:(BOOL)flag forIndex:(NSInteger)index {
    [self buttonAtIndex:index].enabled = flag;
}

- (BOOL)isEnabledForIndex:(NSInteger)index {
    return [self buttonAtIndex:index].isEnabled;
}

- (void)setHidden:(BOOL)flag forIndex:(NSInteger)index {
    [self buttonAtIndex:index].hidden = flag;
    [self tile];
}

- (BOOL)isHiddenForIndex:(NSInteger)index {
    return [self buttonAtIndex:index].isHidden;
}

- (void)setSelected:(BOOL)selected forIndex:(NSInteger)index {
    switch (self.trackingMode) {
        case AJRButtonBarTrackingSelectAny:
            [self buttonAtIndex:index].state = selected ? NSControlStateValueOn : NSControlStateValueOff;
            break;
        case AJRButtonBarTrackingSelectOne:
            for (NSInteger x = 0; x < self.numberOfButtons; x++) {
                [[self buttonAtIndex:x] setState:index == x ? NSControlStateValueOn : NSControlStateValueOff];
            }
            break;
        case AJRButtonBarTrackingSelectMementary:
            for (NSInteger x = 0; x < self.numberOfButtons; x++) {
                [[self buttonAtIndex:x] setState:NSControlStateValueOff];
            }
            break;
    }
}

- (BOOL)selectedForIndex:(NSInteger)index {
    return [[self buttonAtIndex:index] state] == NSControlStateValueOn;
}

- (void)setTarget:(id)target forIndex:(NSInteger)index {
    [[self buttonAtIndex:index] setInstanceObject:target forKey:@"target"];
}

- (id)targetForIndex:(NSInteger)index {
    return [[self buttonAtIndex:index] instanceObjectForKey:@"target"];
}

- (void)setAction:(SEL)action forIndex:(NSInteger)index {
    [[self buttonAtIndex:index] setInstanceObject:NSStringFromSelector(action) forKey:@"action"];
}

- (SEL)actionForIndex:(NSInteger)index {
    return NSSelectorFromString([[self buttonAtIndex:index] instanceObjectForKey:@"action"]);
}

- (void)setImage:(NSImage *)image forIndex:(NSInteger)index {
    [self buttonAtIndex:index].image = image;
}

- (NSImage *)imageForIndex:(NSInteger)index {
    return [self buttonAtIndex:index].image;
}

- (void)setMenu:(NSMenu *)menu forIndex:(NSInteger)index {
    NSButton *button = [self buttonAtIndex:index];
    NSPopUpButton *popUpButton = AJRObjectIfKindOfClass(button, NSPopUpButton);

    if (menu == nil) {
        if (popUpButton == nil) {
            // We're not a pop up, so we don't have a menu, so there's nothing to remove.
        } else {
            // We are a pop up button, but we want to be a normal button.
            button = [self _createButtonForIndex:index];

            [self replaceSubview:popUpButton with:button];
            button.image = popUpButton.image;
            [self tile];
        }
    } else {
        if (popUpButton == nil) {
            // Create a pop up button.
            popUpButton = [self _createPopUpButtonForIndex:index];
            popUpButton.image = button.image;
            [self replaceSubview:button with:popUpButton];
            [self tile];
        } else {
            // We're already a pop up button, so just replace our menu.
            popUpButton.menu = menu;
        }
    }
}

- (NSMenu *)menuForIndex:(NSInteger)index {
    NSPopUpButton *button = AJRObjectIfKindOfClass([self buttonAtIndex:index], NSPopUpButton);

    if (button != nil) {
        return button.menu;
    }

    return nil;
}

- (void)setRepresentedObject:(id)object forIndex:(NSInteger)index {
    [[self buttonAtIndex:index] setInstanceObject:object forKey:@"representedObject"];
}

- (id)representedObjectForIndex:(NSInteger)index {
    return [[self buttonAtIndex:index] instanceObjectForKey:@"representedObject"];
}

- (IBAction)selectButton:(NSButton *)sender {
    _selectedButton = [self.subviews indexOfObjectIdenticalTo:sender];

    if (_selectedButton != NSNotFound) {
        [self setSelected:YES forIndex:_selectedButton];
    }

    // Do the actual action...
    id target = [sender instanceObjectForKey:@"target"];
    SEL action = NSSelectorFromString([sender instanceObjectForKey:@"action"]);
    if (action != NULL) {
        [NSApp sendAction:action to:target from:self];
    }
}

@end
