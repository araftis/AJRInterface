/*
 AJRSegmentedCell.m
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

#import "AJRSegmentedCell.h"

#import "NSBezierPath+Extensions.h"
#import "NSColor+Extensions.h"
#import "NSGraphicsContext+Extensions.h"
#import "NSFont+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>
#import <AJRInterface/AJRInterface-Swift.h>
#import <objc/runtime.h>

@implementation AJRSegmentedCell {
    NSGradient *_selectedActiveGradient;
    NSGradient *_selectedInactiveGradient;
}

typedef NSRect (*AJRRectForSegmentIMP)(id, SEL, NSInteger, NSRect);
typedef NSRect (*AJRTitleRectForBoundsIMP)(id, SEL, NSRect);

- (NSRect)rectForSegment:(NSInteger)index inFrame:(NSRect)frame {
#if defined(__x86_64__)
    AJRRectForSegmentIMP superImp = (AJRRectForSegmentIMP)class_getMethodImplementation_stret([[self class] superclass], _cmd);
#else
    AJRRectForSegmentIMP superImp = (AJRRectForSegmentIMP)class_getMethodImplementation([[self class] superclass], _cmd);
#endif
    return superImp(self, _cmd, index, frame);
}

- (NSRect)titleRectForBounds:(NSRect)bounds {
#if defined(__x86_64__)
    AJRTitleRectForBoundsIMP superImp = (AJRTitleRectForBoundsIMP)class_getMethodImplementation_stret([[self class] superclass], _cmd);
#else
    AJRTitleRectForBoundsIMP superImp = (AJRTitleRectForBoundsIMP)class_getMethodImplementation([[self class] superclass], _cmd);
#endif
    return superImp(self, _cmd, bounds);
}

- (NSGradient *)selectedActiveGradient {
    if (_selectedActiveGradient == nil) {
        _selectedActiveGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                   [[NSColor selectedContentBackgroundColor] colorByMultiplyingSaturation:0.8 andBrightness:3.0], 0.0,
                                   [NSColor selectedContentBackgroundColor], 1.0,
                                   nil];
    }
    return _selectedActiveGradient;
}

- (NSGradient *)selectedInactiveGradient {
    if (_selectedInactiveGradient == nil) {
        NSColor *color1 = [NSColor unemphasizedSelectedContentBackgroundColor];
        NSColor *color2 = [[NSColor unemphasizedSelectedContentBackgroundColor] colorByMultiplyingBrightness:0.85];
        _selectedInactiveGradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
    }
    return _selectedInactiveGradient;
}

- (NSString *)labelInControl:(NSSegmentedControl *)control forSegment:(NSInteger)segment {
    NSString *label = [[control labelForSegment:segment] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return label.length != 0 ? label : nil;
}

- (void)drawImage:(NSImage *)image in:(NSRect)frame {
    [image drawInRect:NSInsetRect(frame, 4.0, 4.0)];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    CGFloat backingScale = [[[controlView window] screen] backingScaleFactor];
    if (backingScale == 0.0) {
        backingScale = 1.0;
    }

    CGFloat radius;
    if (_cornerRadius == 0) {
        radius = NSHeight(cellFrame) / 2.0;
    } else {
        radius = _cornerRadius;
        if (radius > NSHeight(cellFrame) / 2.0) {
            radius = NSHeight(cellFrame) / 2.0;
        }
    }

    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:radius yRadius:radius];
    [NSColor.quaternaryLabelColor set];
    [path fill];
    path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 0.5 / backingScale, 0.5 / backingScale) xRadius:radius yRadius:radius];
    [path setLineWidth:1.0 / backingScale];
    [NSColor.tertiaryLabelColor set];
    [path stroke];
    
    NSSegmentedControl *control = AJRObjectIfKindOfClass(controlView, NSSegmentedControl);
    for (NSInteger x = 0; x < [control segmentCount]; x++) {
        NSRect borderFrame = [self rectForSegment:x inFrame:cellFrame];
        
        BOOL selected = [control isSelectedForSegment:x];
        BOOL highlighted = [AJRObjectIfKindOfClass(control, AJRSegmentedControl) isHighlightedForSegment:x];
        BOOL pressed = [AJRObjectIfKindOfClass(control, AJRSegmentedControl) isPressedForSegment:x];
        if (pressed || selected || highlighted) {
            NSImage *image = [control imageForSegment:x];
            NSString *label = [self labelInControl:control forSegment:x];

            if (label != nil || (image != nil && ![image isTemplate])) {
                // Selected always trumps highlighted
                if (selected) {
                    if ([[controlView window] isKeyWindow] && [NSApp isActive]) {
                        [NSColor.selectedContentBackgroundColor set];
                    } else {
                        [NSColor.tertiaryLabelColor set];
                    }
                } else if (pressed) {
                    [NSColor.tertiaryLabelColor set];
                } else if (highlighted) {
                    [NSColor.quaternaryLabelColor set];
                }
                NSRect backgroundFrame = NSInsetRect(borderFrame, 1.0 + 1.0 / backingScale, 1.0 + 1.0 / backingScale);
                [[NSBezierPath bezierPathWithRoundedRect:backgroundFrame xRadius:_cornerRadius - 2.0 yRadius:_cornerRadius - 2.0] fill];
            }
        }
        
        [self drawSegment:x inFrame:[self rectForSegment:x inFrame:cellFrame] withView:controlView];
        
        //[NSColor.redColor set];
        //NSFrameRect([self rectForSegment:x inFrame:cellFrame]);
    }
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    NSSegmentedControl *control = AJRObjectIfKindOfClass(controlView, NSSegmentedControl);
    NSImage *image = [control imageForSegment:segment];
    NSString *label = [self labelInControl:control forSegment:segment];

    if (label != nil) {
        NSColor *foregroundColor;
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

        if ([control isSelectedForSegment:segment]) {
            if ([[controlView window] isKeyWindow] && [NSApp isActive]) {
                foregroundColor = [NSColor alternateSelectedControlTextColor];
            } else {
                foregroundColor = [NSColor controlTextColor];
            }
        } else {
            foregroundColor = [NSColor controlTextColor];
        }
        [style setAlignment:[control alignmentForSegment:segment]];

        NSDictionary *attributes = @{NSForegroundColorAttributeName: foregroundColor,
                                     NSParagraphStyleAttributeName: style,
                                     NSFontAttributeName: [control font],
                                     };
        frame.size.height -= 1.0;
        frame.origin.y += 3.0;
        [[[NSAttributedString alloc] initWithString:label attributes:attributes] drawInRect:frame];
    } else if (image != nil) {
        if ([control isSelectedForSegment:segment]) {
            if (image.isTemplate) {
                image = [image ajr_imageTintedWithColor:NSColor.selectedContentBackgroundColor];
            }
        }
        [self drawImage:image in:AJRRectByCenteringInRect((CGRect){CGPointZero, image.size}, frame, AJRRectCenteringFitWidthAndHeight)];
    }
}

@end
