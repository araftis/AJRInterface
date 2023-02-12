/*
 AJRFlippedCenteringView.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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
                  [NSColor selectedControlColor], NSForegroundColorAttributeName,
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
