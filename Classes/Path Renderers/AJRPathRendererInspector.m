
#import "AJRPathRendererInspector.h"

#import "AJRPathRenderer.h"
#import "AJRPathRendererInspectorModule.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRPathRendererInspector

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    inspectorModules = [[NSMutableDictionary alloc] init];
    
    [self setTitle:@"Path Renderer Inspector"];
    [self setBoxType:NSBoxPrimary];
    [self setTitlePosition:NSNoTitle];
    [self setTransparent:YES];
    [self setContentViewMargins:NSZeroSize];
    
    return self;
}


- (void)setPathRenderer:(AJRPathRenderer *)aPathRenderer;
{
    if (renderer != aPathRenderer) {
        renderer = aPathRenderer;
        
        if (renderer) {
            inspectorModule = [inspectorModules objectForKey:[[renderer class] name]];
            if (!inspectorModule) {
                Class        class = NSClassFromString(AJRFormat(@"%@InspectorModule", NSStringFromClass([renderer class])));
                if (class) {
                    inspectorModule = [[class alloc] init];
                    [inspectorModules setObject:inspectorModule forKey:[[renderer class] name]];
                }
            }
        }
        
        [self setContentView:[inspectorModule view]];
    }
    
    [inspectorModule setPathRenderer:renderer];
}

- (AJRPathRenderer *)renderer;
{
    return renderer;
}

@end
