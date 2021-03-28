
#import <Cocoa/Cocoa.h>

@interface AJRURLFieldCell : NSTextFieldCell

@property (nonatomic,class,readonly) NSImage *backgroundImage;

@property (nonatomic,strong) NSImage *icon;
@property (nonatomic,readonly) NSImage *displayIcon;

@property (nonatomic,assign) double progress;
- (void)noteProgressComplete;

#pragma mark - Layout

- (NSRect)textRectForBounds:(NSRect)cellFrame;
- (NSRect)iconRectForBounds:(NSRect)cellFrame;

@end


