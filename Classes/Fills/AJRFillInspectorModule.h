
#import <AppKit/AppKit.h>

@class AJRFill;

@interface AJRFillInspectorModule : NSObject
{
    IBOutlet NSView        *view;
    
    AJRFill                *fill;
}

- (NSView *)view;
- (void)update;
- (void)setFill:(AJRFill *)aFill;

@end
