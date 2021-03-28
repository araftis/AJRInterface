
#import <Cocoa/Cocoa.h>

@class AJRSeparatorBorder;

@interface AJRRibbonView : NSView

@property (strong) AJRSeparatorBorder *border;
@property (copy) NSArray *viewControllers;

@end
