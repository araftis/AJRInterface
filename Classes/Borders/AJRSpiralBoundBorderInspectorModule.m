
#import "AJRSpiralBoundBorderInspectorModule.h"

#import "AJRSpiralBoundBorder.h"

@implementation AJRSpiralBoundBorderInspectorModule

- (void)update
{
    [edgeMatrix selectCellWithTag:[(AJRSpiralBoundBorder *)border edge]];
}

- (void)selectEdge:(id)sender
{
    [(AJRSpiralBoundBorder *)border setEdge:[[sender selectedCell] tag]];
}

@end
