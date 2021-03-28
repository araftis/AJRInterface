
#import <Cocoa/Cocoa.h>

@class AJRSeparatorBorder;

@interface AJRRibbonViewItem : NSView 

#pragma mark - Creation

- (id)initWithContentView:(NSView *)contentView;

#pragma mark - Properties

@property (strong) AJRSeparatorBorder *border;

@end
