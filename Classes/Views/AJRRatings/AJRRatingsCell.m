
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
