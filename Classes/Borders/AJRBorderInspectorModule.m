
#import "AJRBorderInspectorModule.h"

#import "AJRBorder.h"

@implementation AJRBorderInspectorModule


- (NSView *)view
{
    if (!view) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self topLevelObjects:NULL];
    }
    
    return view;
}

- (void)update
{
}

- (void)setBorder:(AJRBorder *)aBorder
{
    if (border != aBorder) {
        border = aBorder;
        
        [self update];
    }
}

@end
