//
//  NSAttributedString-Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "NSAttributedString+Extensions.h"

#import "NSGraphicsContext+Extensions.h"

@implementation NSAttributedString (AJRInterfaceExtensions)

- (NSSize)ajr_sizeConstrainedToWidth:(CGFloat)width {
    NSSize size;
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    size.height = [layoutManager usedRectForTextContainer:textContainer].size.height;
    size.width = width;
    
    return size;
}

- (void)ajr_drawAtPoint:(NSPoint)point context:(CGContextRef)context {
	// See: http://stackoverflow.com/questions/715750/ugly-looking-text-when-drawing-nsattributedstring-in-cgcontext
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext *graphics = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
	[NSGraphicsContext setCurrentContext:graphics];
	[self drawAtPoint:point];
	[NSGraphicsContext restoreGraphicsState];
}

- (void)ajr_drawInRect:(NSRect)rect context:(CGContextRef)context {
	// See: http://stackoverflow.com/questions/715750/ugly-looking-text-when-drawing-nsattributedstring-in-cgcontext
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext *graphics = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
	[NSGraphicsContext setCurrentContext:graphics];
	[self drawInRect:rect];
	[NSGraphicsContext restoreGraphicsState];
}


@end
