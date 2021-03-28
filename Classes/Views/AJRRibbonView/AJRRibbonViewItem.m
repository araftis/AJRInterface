
#import "AJRRibbonViewItem.h"

#import <AJRInterface/AJRSeparatorBorder.h>

@implementation AJRRibbonViewItem

#pragma mark - Creation

- (id)initWithContentView:(NSView *)contentView {
    if ((self = [super initWithFrame:[contentView bounds]])) {
        [self addSubview:contentView];
        _border = [[AJRSeparatorBorder alloc] init];
    }
    
    return self;
}

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect {
    [_border drawBorderInRect:[self bounds] controlView:self];
}

@end
