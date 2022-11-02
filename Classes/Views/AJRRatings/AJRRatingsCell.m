/*
 AJRRatingsCell.m
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

#import "AJRRatingsCell.h"

#import "NSImage+Extensions.h"

static NSString *starSelectedSuffix = @"Selected";
static NSString *starNotSelectedSuffix = @"";

@interface AJRRatingsCell ()
- (void)_updateImage;
@end

@implementation AJRRatingsCell

#pragma mark NSObject (NSNibAwaking)

- (void)awakeFromNib {
    self.usesLargeStars = ![self.controlView isKindOfClass:[NSTableView class]];
}

#pragma mark NSCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSString *suffix = starNotSelectedSuffix;
    if ([self isHighlighted]) {
        suffix = starSelectedSuffix;
    }
    
    NSString *sizeString = self.usesLargeStars ? @"Large" : @"Small";
    NSImage *starImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:[[sizeString stringByAppendingString:@"StarApple"] stringByAppendingString:suffix]]];
    NSImage *halfImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:[sizeString stringByAppendingString:@"Star-Half"]]];
    NSImage *emptyImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:[[sizeString stringByAppendingString:@"Star-EmptyApple"] stringByAppendingString:suffix]]];
    
    CGFloat yPosition = NSMinY(cellFrame) + ([controlView isFlipped] ? starImage.size.height : 0);
    CGFloat wholeStars = floor(self.floatValue);

    NSUInteger starIndex;
    for (starIndex = 0; starIndex < wholeStars; starIndex++)
        [starImage ajr_drawAtPoint:NSMakePoint(NSMinX(cellFrame) + starIndex * (NSWidth(cellFrame) / self.maxValue), yPosition) operation:NSCompositingOperationSourceOver];
    
    if (rint([self floatValue] * 2.0) / 2.0 > wholeStars) {
        [halfImage ajr_drawAtPoint:NSMakePoint(NSMinX(cellFrame) + starIndex * (NSWidth(cellFrame) / self.maxValue), yPosition) operation:NSCompositingOperationSourceOver];
        starIndex++;
    }
    
    for (; starIndex < self.maxValue; starIndex++)
        [emptyImage ajr_drawAtPoint:NSMakePoint(NSMinX(cellFrame) + starIndex * (NSWidth(cellFrame) / self.maxValue), yPosition) operation:NSCompositingOperationSourceOver];
}


#pragma mark API

- (BOOL)usesLargeStars {
    return _usesLargeStars;
}

- (void)setUsesLargeStars:(BOOL)usesLargeStars {
    [self willChangeValueForKey:@"usesLargeStars"];
    _usesLargeStars = usesLargeStars;
    [self didChangeValueForKey:@"usesLargeStars"];
    [self _updateImage];
    [self.controlView setNeedsDisplay:YES];
}


#pragma mark Private API

- (void)_updateImage {    
    self.image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:self.usesLargeStars ? @"LargeStarApple" : @"SmallStarApple"]];
}

@end
