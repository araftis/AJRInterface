
#import "AJRPathRendererInspectorModule.h"

#import "AJRPathRenderer.h"
#import "NSBundle+Extensions.h"

@implementation AJRPathRendererInspectorModule


- (NSView *)view
{
   if (!view) {
      [NSBundle ajr_loadNibNamed:NSStringFromClass([self class]) owner:self];
   }
   
   return view;
}

- (void)update
{
}

- (void)setPathRenderer:(AJRPathRenderer *)aPathRenderer
{
   if (renderer != aPathRenderer) {
      renderer = aPathRenderer;
      
      [self update];
   }
}

@end
