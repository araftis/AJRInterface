
#import "AJRFillInspectorModule.h"

#import "AJRFill.h"
#import "NSBundle+Extensions.h"

@implementation AJRFillInspectorModule


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

- (void)setFill:(AJRFill *)aFill
{
    if (fill != aFill) {
        fill = aFill;
        
        [self update];
    }
}

@end
