//
//  NSOutlineView+Extensions.h
//  AJRInterface
//
//  Created by AJ Raftis on 1/28/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AJROutlineViewDataSource <NSObject, NSOutlineViewDataSource>
- (nullable NSMenu *)outlineView:(NSOutlineView *)outlineView menuForItem:(id)item;
@end

@interface NSOutlineView (AJRInterfaceExtensions)

- (NSMenu *)menuForEvent:(NSEvent *)event;

- (nullable NSView *)viewForItem:(id)item column:(NSInteger)columnIndex;

@end

NS_ASSUME_NONNULL_END
