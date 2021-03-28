
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AJRTableViewDelegate <NSObject>

- (nullable NSMenu *)tableView:(NSTableView *)tableView menuForRow:(NSInteger)row;

@end

@interface NSTableView (AJRInterfaceExtensions)

- (NSMenu *)menuForEvent:(NSEvent *)event;

@end

NS_ASSUME_NONNULL_END
