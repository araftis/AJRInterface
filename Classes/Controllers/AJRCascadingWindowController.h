
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRCascadingWindowController : NSWindowController

/*!
 Returns the desired size of the window, or nil if the desired size is the window's storyboard/xib size.
 */
@property (nullable,nonatomic,readonly) NSValue *desiredWindowSize;

@end

NS_ASSUME_NONNULL_END
