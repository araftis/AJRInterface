/*
AJRActivityToolbarProgressLayer.m
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

#import "AJRActivityToolbarProgressLayer.h"

#import "AJRActivityToolbarViewLayer.h"

#import <AJRInterface/AJRInterface.h>

@interface AJRActivityToolbarProgressLayer ()

@property (nonatomic,strong) NSTimer *animationTimer;
@property (nonatomic,assign) CGFloat animationOffset;

@end

@implementation AJRActivityToolbarProgressLayer {
	NSImage *_indeterminateImage;
	NSColor *_indeterminateColor;
}

- (void)ajr_commonInit {
	[self setColor:[[NSColor alternateSelectedControlColor] CGColor]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self ajr_commonInit];
	}
	return self;
}

- (instancetype)init {
	if ((self = [super init])) {
		[self ajr_commonInit];
	}
	return self;
}

- (NSImage *)indeterminateImage {
	if (_indeterminateImage == nil) {
		NSSize size = {40.0, 2.0};
		_indeterminateImage = [NSImage imageWithSize:size scales:@[@(1.0), @(2.0)] flipped:NO colorSpace:AJRGetSRGBColorSpace() commands:^(CGFloat scale) {
			CGContextRef context = AJRGetCurrentContext();
			CGContextSetFillColorWithColor(context, [self color]);
			CGContextFillRect(context, (CGRect){CGPointZero, size});
			
			AJRBezierPath *path = [[AJRBezierPath alloc] init];
			[path moveToPoint:CGPointZero];
			[path lineToPoint:(CGPoint){2.0, 2.0}];
			[path lineToPoint:(CGPoint){7.0, 2.0}];
			[path lineToPoint:(CGPoint){5.0, 0.0}];
			[path closePath];
			
			CGColorRef white = AJRCreateLinearGrayColor(1.0, 0.75);
			CGContextSetFillColorWithColor(context, white);
			CGColorRelease(white);
			for (NSInteger x = 0; x < 5; x++) {
				[path fill];
				CGContextTranslateCTM(context, 10.0, 0.0);
			}
		}];
		[_indeterminateImage setCapInsets:(NSEdgeInsets){0.0, 0.0, 0.0, 0.0}];
		[_indeterminateImage setResizingMode:NSImageResizingModeTile];
	}
	return _indeterminateImage;
}

- (NSColor *)indeterminateColor {
	if (_indeterminateColor == nil) {
		_indeterminateColor = [NSColor colorWithPatternImage:[self indeterminateImage]];
	}
	return _indeterminateColor;
}

- (void)dealloc {
	if (_color) {
		CGColorRelease(_color); _color = NULL;
	}
}

#pragma mark - Properties

- (void)setColor:(CGColorRef)color {
	if (_color) {
		CGColorRelease(_color);
	}
	_color = CGColorRetain(color);
	_indeterminateImage = nil;
	_indeterminateColor = nil;
}

- (void)setIndeterminate:(BOOL)indeterminate {
	if ((_indeterminate && !indeterminate) || (!_indeterminate && indeterminate)) {
		if (_animationTimer) {
			[_animationTimer invalidate];
		}
		_indeterminate = indeterminate;
		if (_indeterminate) {
			_animationOffset = 0.0;
			_animationTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(animateIndeterminate) userInfo:nil repeats:YES];
			[[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
			[_animationTimer fire];
		}
		[self setNeedsDisplay];
	}
}

- (void)setMinimum:(double)minimum {
    _minimum = minimum;
    [self setNeedsDisplay];
}

- (void)setMaximum:(double)maximum {
    _maximum = maximum;
    [self setNeedsDisplay];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

#pragma mark - CALayer

- (void)drawInContext:(CGContextRef)context {
    [NSGraphicsContext drawInContext:context withBlock:^{
		CALayer *parent = [self superlayer];
		
		if (parent) {
			CGRect parentBounds = [parent bounds];
			AJRBezierPath *path = [AJRBezierPath bezierPathWithRoundedRect:parentBounds xRadius:4.0 yRadius:4.0];
			parentBounds = [parent convertRect:parentBounds toLayer:self];
			[path addClip];
		}
		
		if (self->_indeterminate) {
			CGContextSaveGState(context);
			CGRect rect = [self bounds];
			rect.origin.x -= 30.0;
			rect.size.width += 60.0;
			CGContextTranslateCTM(context, self->_animationOffset, 0.0);
			[[self indeterminateImage] drawInRect:rect];
			CGContextRestoreGState(context);
		} else {
			CGRect rect = [self bounds];
			CGFloat percent = self->_progress / (self->_maximum - self->_minimum);
			rect.size.width *= percent;
			CGContextSetFillColorWithColor(context, [self color]);
			CGContextFillRect(context, rect);
		}
    }];
}

- (void)animateIndeterminate {
	_animationOffset += 2.0;
	if (_animationOffset > 30.0) {
		_animationOffset = 0.0;
	}
	[self setNeedsDisplay];
}

@end
