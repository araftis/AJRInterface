
#import <AppKit/AppKit.h>

@class AJRPathRenderer;

@interface AJRPathRendererInspectorModule : NSObject
{
   IBOutlet NSView        *view;
   
   AJRPathRenderer        *renderer;
}

- (NSView *)view;
- (void)update;
- (void)setPathRenderer:(AJRPathRenderer *)aPathRenderer;

@end
