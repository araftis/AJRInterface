/*
 AJRLabelCell.m
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

#import <AJRInterface/AJRLabelCell.h>

#import "AJRInterfaceFunctions.h"
#import "AJRPathRenderer.h"
#import "NSBezierPath+Extensions.h"
#import "NSColor+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRLabelCell

+ (void)initialize
{
    [self setVersion:3];
}

- (id)init
{
    return [self initTextCell:@"Label"];
}

- (id)initTextCell:(NSString *)label
{
    self = [super initTextCell:label];
    
    [self setFont:[NSFont boldSystemFontOfSize:18.0]];
    [self setAlignment:NSTextAlignmentCenter];
    [self setBordered:NO];
    
    renderers = [[NSMutableArray allocWithZone:nil] init];
    [renderers addObject:[AJRPathRenderer rendererForName:@"Fill"]];
    
    return self;
}

- (id)initImageCell:(NSImage *)icon
{
    return [self initTextCell:[icon name]];
}


- (void)setFont:(NSFont *)aFont
{
    [super setFont:aFont];
//    if (NSDebugEnabled) {
//        AJRPrintf(@"%C: release %S %p\n", self, _cmd, path);
//        if (path) {
//            AJRPrintf(@"%C: stack: %@\n", self, GTMStackTrace());
//        }
//    }
     path = nil;
}

- (void)setStringValue:(NSString *)aValue
{
    [super setStringValue:aValue ? aValue : @""];
//    if (NSDebugEnabled) {
//        AJRPrintf(@"%C: release %S %p\n", self, _cmd, path);
//    }
     path = nil;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)aView
{    
    @try {
        CGFloat            x, y;
        NSFont            *font = [self font];
        NSRect            bounds;

        if (path == nil) {
            NSString        *string = [self stringValue];

            path = [[NSBezierPath alloc] init];
            [path moveToPoint:(NSPoint){0.0, -[font descender]}];
            [path appendBezierPathWithString:string font:font];
        }
        bounds = [path bounds];
        
        y = cellFrame.origin.y;
        switch ([self alignment]) {
            case NSTextAlignmentLeft:
                x = cellFrame.origin.x;
                break;
            case NSTextAlignmentCenter:
                x = cellFrame.origin.x + (cellFrame.size.width - bounds.size.width) * 0.5;
                break;
            case NSTextAlignmentRight:
                x = cellFrame.origin.x + cellFrame.size.width - bounds.size.width;
                break;
            default:
                x = cellFrame.origin.x;
        }
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        if ([aView isFlipped]) {
//            AJRPrintf(@"%C: ajrcender = %.1f, descender = %.1f, height = %.1f\n", self, [font ajrcender], [font descender], cellFrame.size.height);
//            AJRPrintf(@"    Bounding rect: %R\n", [font boundingRectForFont]);
//            AJRPrintf(@"    Drawing rect: %R\n", [self drawingRectForBounds:cellFrame]);
//            AJRPrintf(@"    Title rect: %R\n", [self titleRectForBounds:cellFrame]);
//            AJRPrintf(@"    size: %Z/%Z\n", [self cellSize], [self cellSizeForBounds:cellFrame]);
//            AJRPrintf(@"    baseline: %.1f\n", [[self font] _baselineOffsetForUILayout]);
//            AJRPrintf(@"    y: %.1f\n", [[self font] _baselineOffsetForUILayout]);
            y = cellFrame.origin.y + cellFrame.size.height;
//            AJRPrintf(@"    y: %.1f\n", [NSString defaultBaselineOffsetForFont:[self font]]);
            CGContextTranslateCTM([[NSGraphicsContext currentContext] CGContext], x, y);
            CGContextScaleCTM([[NSGraphicsContext currentContext] CGContext], 1.0, -1.0);
        } else {
            CGContextTranslateCTM([[NSGraphicsContext currentContext] CGContext], x, y);
        }
        
        for (AJRPathRenderer *renderer in renderers) {
            [renderer renderPath:path];
        }
        //[[NSColor blueColor] set];
        //NSRectFill((NSRect){{0.0, 0.0}, {10.0, 10.0}});
        //[[NSColor cyanColor] set];
        //NSFrameRect((NSRect){cellFrame.origin, {10.0, 10.0}});
        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        //[[NSColor greenColor] set];
        //NSRectFill((NSRect){{0.0, 0.0}, {10.0, 10.0}});
        //[[NSColor yellowColor] set];
        //NSFrameRect((NSRect){cellFrame.origin, {10.0, 10.0}});
    } @catch (NSException *localException) {
        AJRPrintf(@"Exception: %@", localException);
    }
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView
{
    //[[NSColor redColor] set];
    //NSFrameRect(cellFrame);
    //cellFrame = NSInsetRect(cellFrame, 1.0, 1.0);
    
    [self drawInteriorWithFrame:cellFrame inView:aView];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)aView
{
}

- (NSSize)cellSize
{
    NSSize size;
    size = [super cellSize];
    return size;
}

- (NSSize)cellSizeForBounds:(NSRect)rect
{
    NSSize size;
    size = [super cellSizeForBounds:rect];
    return size;
}

- (NSArray *)renderers
{
    return renderers;
}

- (NSUInteger)renderersCount
{
    return [renderers count];
}

- (AJRPathRenderer *)rendererAtIndex:(NSUInteger)index
{
    return [renderers objectAtIndex:index];
}

- (NSUInteger)indexOfRenderer:(AJRPathRenderer *)renderer
{
    return [renderers indexOfObjectIdenticalTo:renderer];
}

- (AJRPathRenderer *)lastRenderer
{
    return [renderers lastObject];
}

- (void)addRenderer:(AJRPathRenderer *)renderer
{
    [renderers addObject:renderer];
}

- (void)insertRenderer:(AJRPathRenderer *)renderer atIndex:(NSUInteger)index
{
    [renderers insertObject:renderer atIndex:index];
}

- (void)removeRendererAtIndex:(NSUInteger)index
{
    [renderers removeObjectAtIndex:index];
}

- (void)removeRenderersAtIndexes:(NSIndexSet *)indexes
{
    [renderers removeObjectsAtIndexes:indexes];
}

- (void)moveRendererAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    [renderers moveObjectAtIndex:fromIndex toIndex:toIndex];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"renderers"]) {
        renderers = [coder decodeObjectForKey:@"renderers"];
    } else {
        renderers = [coder decodeObject];
    }
    path = nil;
       
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:renderers forKey:@"renderers"];
    } else {
        [coder encodeObject:renderers];
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    AJRLabelCell        *new;

    // This may seem really strange, but this is to work around a “bug” in NSCell. What seems to happen is that the copy method on NSCell copies all instance variables without doing a retain. The problem with this is that it also calls setFont:, which causes a release to be sent to the path. However, this release is the path on the copy, not the original, which means that the original now has a pointer to a dealloc'd copy. Thus, we have to add an extra retain to path to get around this.
    new = [super copyWithZone:zone];
    
    new->renderers = [[NSMutableArray alloc] initWithCapacity:[renderers count]];
    for (AJRPathRenderer *renderer in renderers) {
        AJRPathRenderer    *rendererCopy = [renderer copyWithZone:zone];
        [new->renderers addObject:rendererCopy];
    }
    // Don't copy the path. This will be recreated on demand.
    //new->path = [path copyWithZone:zone];
    new->path = nil;
    
    return new;
}

@end

