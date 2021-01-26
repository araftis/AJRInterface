
#import <AJRInterface/AJRBorderInspectorModule.h>

@interface AJRSpiralBoundBorderInspectorModule : AJRBorderInspectorModule
{
    IBOutlet NSMatrix        *edgeMatrix;
}

- (void)selectEdge:(id)sender;

@end
