
#import "AJRBorderInspector.h"

#import "AJRBorder.h"
#import "AJRBorderInspectorModule.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRBorderInspector

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    inspectorModules = [[NSMutableDictionary alloc] init];
    
    [self setTitle:@""];
    [self setBoxType:NSBoxCustom];
    [self setTitlePosition:NSNoTitle];
    [self setTransparent:YES];
    [self setContentViewMargins:NSZeroSize];

    return self;
}


- (void)setBorder:(AJRBorder *)aBorder;
{
    if (border != aBorder) {
        border = aBorder;
        
        if (border) {
            inspectorModule = [inspectorModules objectForKey:[[border class] name]];
            if (!inspectorModule) {
                Class        class = NSClassFromString(AJRFormat(@"%@InspectorModule", NSStringFromClass([border class])));
                if (class) {
                    inspectorModule = [[class alloc] init];
                    [inspectorModules setObject:inspectorModule forKey:[[border class] name]];
                }
            }
        } else {
            inspectorModule = nil;
        }
        
        [self setContentView:[inspectorModule view]];
    }
    
    [inspectorModule setBorder:border];
}

- (AJRBorder *)border;
{
    return border;
}

@end
