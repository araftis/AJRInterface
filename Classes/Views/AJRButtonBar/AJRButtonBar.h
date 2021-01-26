//
//  AJRButtonBar.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/4/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

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

@end

NS_ASSUME_NONNULL_END
