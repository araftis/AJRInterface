/*
AJRActivityToolbarViewLayer.m
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

#import "AJRActivityToolbarViewLayer.h"

#import "AJRActivityToolbarProgressLayer.h"
#import "AJRImages.h"
#import "AJRURLFieldCell.h"
#import "NSGraphicsContext+Extensions.h"
#import <AJRInterface/AJRInterface-Swift.h>

#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>

#define MM_DEFAULT_MESSAGE [[NSProcessInfo processInfo] processName]

@interface AJRActivityToolbarViewLayer ()

@property (nonatomic,strong) NSDictionary *messageAttributes;
@property (nonatomic,strong) NSDictionary *bylineAttributes;

@end

@implementation AJRActivityToolbarViewLayer

- (id)init {
    if ((self = [super init])) {
        _messageLayer = [[AJRTextLayer alloc] init];
        [_messageLayer setBorderColor:[[[NSColor redColor] colorWithAlphaComponent:0.2] CGColor]];
        //[_messageLayer setBorderWidth:1.0];
        [self addSublayer:_messageLayer];
        [self setMessage:MM_DEFAULT_MESSAGE];
        
        _progressLayer = [[AJRActivityToolbarProgressLayer alloc] init];
        [_progressLayer setBorderColor:[[[NSColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
        //[_progressLayer setBorderWidth:1.0];
        [self addSublayer:_progressLayer];
        
        _bylineLayer = [[AJRTextLayer alloc] init];
        [_bylineLayer setBorderColor:[[[NSColor blueColor] colorWithAlphaComponent:0.2] CGColor]];
        //[_bylineLayer setBorderWidth:1.0];
        [self addSublayer:_bylineLayer];
        [self setBylineMessage:@""];
        
        // Don't show the progress layer, initially.
        [self hideProgress];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self setNeedsDisplay];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self setNeedsDisplay];
        }];
    }
    return self;
}

#pragma mark - Attributes

- (NSDictionary *)messageAttributes {
    if (_messageAttributes == nil) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        [style setLineBreakMode:NSLineBreakByTruncatingHead];
        
        _messageAttributes = @{NSFontAttributeName:[NSFont monospacedDigitSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall] weight:NSFontWeightRegular],
                               NSForegroundColorAttributeName:[NSColor colorNamed:NSApp.isActive ? AJRActivityActiveTextColor : AJRActivityInactiveTextColor bundle:AJRInterfaceBundle()],
                               NSParagraphStyleAttributeName:style,
                               };
    }
    return _messageAttributes;
}

- (NSDictionary *)bylineAttributes {
    if (_bylineAttributes == nil) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        [style setLineBreakMode:NSLineBreakByTruncatingHead];
        
        _bylineAttributes = @{NSFontAttributeName:[NSFont monospacedDigitSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeMini] weight:NSFontWeightBold],
                              NSForegroundColorAttributeName:[NSColor colorNamed:NSApp.isActive ? AJRActivitySecondaryActiveTextColor : AJRActivitySecondaryInactiveTextColor bundle:AJRInterfaceBundle()],
                              NSParagraphStyleAttributeName:style,
                              };
    }
    return _bylineAttributes;
}

#pragma mark - Display

- (void)setIdleMessage:(NSString *)idleMessage {
    [self setAttributedIdleMessage:[[NSAttributedString alloc] initWithString:idleMessage attributes:self.messageAttributes]];
}

- (NSString *)idleMessage {
    return [_attributedIdleMessage string];
}

- (void)setAttributedIdleMessage:(NSAttributedString *)message {
    if (_attributedIdleMessage != message) {
        _attributedIdleMessage = message;
        [self setMessage:nil];
    }
}

- (void)setMessage:(NSString *)message {
    [self setAttributedMessage:message ? [[NSAttributedString alloc] initWithString:message attributes:self.messageAttributes] : nil];
}

- (void)setAttributedMessage:(NSAttributedString *)message {
    NSAttributedString *attributedMessage;
    
    if (message == nil) {
        attributedMessage = _attributedIdleMessage ?: [[NSAttributedString alloc] initWithString:MM_DEFAULT_MESSAGE attributes:self.messageAttributes];
    } else {
        attributedMessage = message;
    }
    
    [_messageLayer setAttributedString:attributedMessage];
}

- (NSString *)bylineMessage {
    return [_bylineLayer.attributedString string];
}

- (void)setBylineMessage:(NSString *)message {
    NSAttributedString	*attributedMessage;
    
    if (message == nil) {
        attributedMessage = [[NSAttributedString alloc] initWithString:@"" attributes:self.bylineAttributes];
    } else {
        attributedMessage = [[NSAttributedString alloc] initWithString:message attributes:self.bylineAttributes];
    }
    
    [self setAttributedBylineMessage:attributedMessage];
}

- (NSAttributedString *)attributedBylineMessage {
    return _bylineLayer.attributedString;
}

- (void)setAttributedBylineMessage:(NSAttributedString *)message {
    [_bylineLayer setAttributedString:message];
}

- (void)setProgressMinimum:(double)progressMinimum {
    [_progressLayer setMinimum:progressMinimum];
}

- (void)setProgressMaximum:(double)progressMaximum {
    [_progressLayer setMaximum:progressMaximum];
}

- (void)setProgress:(double)progress {
    [_progressLayer setProgress:progress];
}

- (void)setIndeterminate:(BOOL)flag {
    [_progressLayer setIndeterminate:flag];
}

- (void)showProgress {
    [_progressLayer setHidden:NO];
    [_bylineLayer setHidden:YES];
}

- (void)hideProgress {
    [_progressLayer setHidden:YES];
    [_bylineLayer setHidden:NO];
}

- (void)setContentsScale:(CGFloat)contentsScale {
    [super setContentsScale:contentsScale];
    [[self messageLayer] setContentsScale:contentsScale];
    [[self bylineLayer] setContentsScale:contentsScale];
    [[self progressLayer] setContentsScale:contentsScale];
}

#pragma mark - Drawing

+ (NSShadow *)bottomHighlightShadow {
    static NSShadow *sharedShadow;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedShadow = [[NSShadow alloc] init];
        [sharedShadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.5]];
        [sharedShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [sharedShadow setShadowBlurRadius:0.0];
    });
    return sharedShadow;
}

+ (NSShadow *)innerGlowShadow {
    static NSShadow *sharedShadow;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedShadow = [[NSShadow alloc] init];
        [sharedShadow setShadowColor:[NSColor colorWithDeviceRed:159.0 / 255.0 green:209 / 255.0 blue:255.0 / 255.0 alpha:0.29]];
        [sharedShadow setShadowBlurRadius:12.0];
        [sharedShadow setShadowOffset:NSZeroSize];
    });
    return sharedShadow;
}

+ (NSGradient *)outerBezelGradient {
    return [[NSGradient alloc] initWithColorsAndLocations:
            [NSColor colorWithDeviceWhite:95.0 / 255.0 alpha:1.0], 0.0,
            [NSColor colorWithDeviceWhite:146.0 / 255.0 alpha:1.0], 1.0,
            nil];
}

+ (NSGradient *)innerBezelGradient {
    return [[NSGradient alloc] initWithColorsAndLocations:
            [NSColor colorWithDeviceRed:188.0 / 255.0 green:195.0 / 255.0 blue:200.0 / 255.0 alpha:1.0], 0.0,
            [NSColor colorWithDeviceRed:201.0 / 255.0 green:211.0 / 255.0 blue:217.0 / 255.0 alpha:1.0], 1.0,
            nil];
}

+ (NSGradient *)backgroundGradient {
    return [[NSGradient alloc] initWithColorsAndLocations:
            [NSColor colorWithDeviceWhite:255.0 / 255.0 alpha:1.0], 0.0,
            [NSColor colorWithDeviceRed:250.0 / 255.0 green:253.0 / 255.0 blue:255.0 / 255.0 alpha:1.0], 0.0307,
            [NSColor colorWithDeviceRed:225.0 / 255.0 green:233.0 / 255.0 blue:240.0 / 255.0 alpha:1.0], 0.5,
            [NSColor colorWithDeviceRed:216.0 / 255.0 green:222.0 / 255.0 blue:227.0 / 255.0 alpha:1.0], 0.5,
            [NSColor colorWithDeviceRed:213.0 / 255.0 green:218.0 / 255.0 blue:224.0 / 255.0 alpha:1.0], 1.0,
            nil];
}

- (void)drawInContext:(CGContextRef)context {
    [NSGraphicsContext drawInContext:context withBlock:^{
        NSAppearance *appearance = AJRObjectIfKindOfClass(self.delegate, NSView).effectiveAppearance;
        if (appearance == nil) {
            appearance = NSAppearance.currentDrawingAppearance;
        }
        [appearance performAsCurrentDrawingAppearance:^{
            NSImage *borderImage = [NSApp isActive] ? [AJRImages viewBorderImageFocused] : [AJRImages viewBorderImageUnfocused];
            [borderImage drawInRect:[self bounds]];
        }];
    }];
}

#pragma mark - CALayer - Layout

- (void)layoutSublayers {
    NSRect bounds = [self bounds];
    NSRect messageRect;
    NSRect progressRect;
    NSRect bylineRect;
    
    messageRect.origin.x = bounds.origin.x + 4.0;
    messageRect.size.width = bounds.size.width - 8.0;
    messageRect.size.height = 15.0;
    messageRect.origin.y = bounds.origin.y + bounds.size.height - messageRect.size.height - 4.0;
    [_messageLayer setFrame:messageRect];
    
    progressRect.origin.x = 0.0;
    progressRect.size.width = bounds.size.width;
    progressRect.size.height = 2.0;
    progressRect.origin.y = bounds.origin.y + 1.0;
    [_progressLayer setFrame:progressRect];
    
    bylineRect.origin.x = bounds.origin.x + 4.0;
    bylineRect.size.width = bounds.size.width - 8.0;
    bylineRect.size.height = 13.0;
    bylineRect.origin.y = 5.0;
    [_bylineLayer setFrame:bylineRect];
}

@end
