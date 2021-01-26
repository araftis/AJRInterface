
#import <AJRInterface/AJRInspectorModule.h>

@class AJRPathRenderer, AJRPathRendererInspectorModule;

@interface AJRPathRendererInspector : NSBox
{
   AJRPathRenderer                    *renderer;
   NSMutableDictionary                *inspectorModules;
   AJRPathRendererInspectorModule    *inspectorModule;
   NSMutableDictionary                *dictionary;
}

- (void)setPathRenderer:(AJRPathRenderer *)aRenderer;
- (AJRPathRenderer *)renderer;

@end
