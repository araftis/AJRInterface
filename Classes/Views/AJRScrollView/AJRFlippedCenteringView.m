
#import "AJRFlippedCenteringView.h"

@implementation AJRFlippedCenteringView

- (NSRect)pageRectangleForPage:(NSInteger)pageNumber
{
    NSRect rect;
    NSInteger oneAdjustedPage = pageNumber - firstPage + 1;
    NSInteger row;
    
    if ((pageNumber < firstPage) || (pageNumber > lastPage)) return NSZeroRect;
    
    rect = [subview rectForPage:pageNumber];
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    
    switch (pagePosition) {
        case AJRPagesVertical:
            rect.origin.x = contentRect.origin.x;
            rect.origin.y = contentRect.origin.y + (rect.size.height + self.gutter) * (oneAdjustedPage - 1) + self.gutter;
            break;
        case AJRPagesHorizontal:
            rect.origin.x = contentRect.origin.x + (rect.size.width + self.gutter) * (oneAdjustedPage - 1);
            rect.origin.y = contentRect.origin.y;
            break;
        case AJRPagesTwoUpOddRight:
            if (firstPage % 2 == 0) {
                row = (oneAdjustedPage - 1) / 2;
                if (oneAdjustedPage % 2 == 1) {
                    rect.origin.x = contentRect.origin.x;
                } else {
                    rect.origin.x = contentRect.origin.x + rect.size.width + self.gutter;
                }
            } else {
                row = oneAdjustedPage / 2;
                if (oneAdjustedPage % 2 == 1) {
                    rect.origin.x = contentRect.origin.x + rect.size.width + self.gutter;
                } else {
                    rect.origin.x = contentRect.origin.x;
                }
            }
            rect.origin.y = contentRect.origin.y + (rect.size.height + self.gutter) * row;
            break;
        case AJRPagesTwoUpOddLeft:
            if (firstPage % 2 == 0) {
                row = oneAdjustedPage / 2;
                if (oneAdjustedPage % 2 == 0) {
                    rect.origin.x = contentRect.origin.x;
                } else {
                    rect.origin.x = contentRect.origin.x + rect.size.width + self.gutter;
                }
            } else {
                row = (oneAdjustedPage - 1) / 2;
                if (oneAdjustedPage % 2 == 0) {
                    rect.origin.x = contentRect.origin.x + rect.size.width + self.gutter;
                } else {
                    rect.origin.x = contentRect.origin.x;
                }
            }
            rect.origin.y = contentRect.origin.y + (rect.size.height + self.gutter) * row;
            break;
        case AJRPagesSingle:
            rect.origin = contentRect.origin;
            break;
    }
    
    return rect;
}

// Draw the page number. This is the page number that always displays. The user might opt to have a different page number that displays in a header or footer, but this is the phisical page number of the page.
- (void)drawPageNumber:(NSInteger)aPageNumber inRect:(NSRect)rect
{
    CGFloat pointSize = 12.0 / self.scale;
    NSFont *font = [NSFont boldSystemFontOfSize:pointSize];
    NSString *string;
    NSDictionary *attributes;
    
    attributes = [[NSDictionary allocWithZone:nil] initWithObjectsAndKeys:
                  [NSColor controlHighlightColor], NSForegroundColorAttributeName,
                  font, NSFontAttributeName,
                  nil];
    
    string = [NSString stringWithFormat:@"%ld", aPageNumber];
    [string drawAtPoint:(NSPoint){rect.size.width - [string sizeWithAttributes:attributes].width - 5.0, pointSize + 4.0} withAttributes:attributes];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
