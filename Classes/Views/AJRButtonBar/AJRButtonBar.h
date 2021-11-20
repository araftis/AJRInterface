/*
AJRButtonBar.h
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRButtonBarItem, AJRSeparatorBorder;

typedef NS_ENUM(uint8_t, AJRButtonBarTracking) {
    AJRButtonBarTrackingSelectOne,
    AJRButtonBarTrackingSelectAny,
    AJRButtonBarTrackingSelectMementary,
};

@interface AJRButtonBar : NSView

@property (nonatomic,strong) AJRSeparatorBorder *border;

@property (nonatomic,assign) CGFloat spacing;
@property (nonatomic,assign) NSTextAlignment alignment;
@property (nonatomic,assign) AJRButtonBarTracking trackingMode;
@property (nonatomic,assign) NSInteger numberOfButtons;
@property (nonatomic,readonly) NSInteger selectedButton;

- (NSRect)rectForIndex:(NSInteger)index;

- (void)setEnabled:(BOOL)enabled forIndex:(NSInteger)index;
- (BOOL)isEnabledForIndex:(NSInteger)index;
- (void)setHidden:(BOOL)hidden forIndex:(NSInteger)index;
- (BOOL)isHiddenForIndex:(NSInteger)index;
- (void)setSelected:(BOOL)selected forIndex:(NSInteger)index;
- (BOOL)selectedForIndex:(NSInteger)index;
- (void)setImage:(NSImage *)image forIndex:(NSInteger)index;
- (NSImage *)imageForIndex:(NSInteger)index;
- (void)setMenu:(nullable NSMenu *)menu forIndex:(NSInteger)index;
- (nullable NSMenu *)menuForIndex:(NSInteger)index;
- (void)setTarget:(id)target forIndex:(NSInteger)index;
- (id)targetForIndex:(NSInteger)index;
- (void)setAction:(SEL)action forIndex:(NSInteger)index;
- (SEL)actionForIndex:(NSInteger)index;
- (void)setRepresentedObject:(id)object forIndex:(NSInteger)index;
- (id)representedObjectForIndex:(NSInteger)index;
- (void)setBadge:(nullable NSImage *)image forIndex:(NSInteger)index;
- (nullable NSImage *)badgeForIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
