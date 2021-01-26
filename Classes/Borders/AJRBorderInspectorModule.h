
#import <AppKit/AppKit.h>

@class AJRBorder;

@interface AJRBorderInspectorModule : NSObject
{
   IBOutlet NSView        *view;
   
   AJRBorder                *border;
}

- (NSView *)view;
- (void)update;
- (void)setBorder:(AJRBorder *)aBorder;

@end
