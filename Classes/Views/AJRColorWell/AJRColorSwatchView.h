//
//  AJRColorSwatchView.h
//
//  Created by A.J. Raftis on 8/30/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRColorSwatchView : NSView

- (id)initWithWidth:(NSInteger)width andHeight:(NSInteger)height;

@property (nonatomic,nullable,readonly,weak) NSColor *selectedColor;
@property (nonatomic,nullable,weak) id target;
@property (nonatomic,nullable,assign) SEL action;

- (void)setColor:(nullable NSColor *)color atX:(NSInteger)x andY:(NSInteger)y;
- (NSColor *)colorAtX:(NSInteger)x andY:(NSInteger)y;

@end

NS_ASSUME_NONNULL_END
