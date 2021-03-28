
#import <Cocoa/Cocoa.h>

@interface NSTextFieldCell (Extensions)

@end


@interface NSObject (NSTextFieldCellDelegate)

- (NSText *)textFieldCell:(NSTextFieldCell *)cell setUpFieldEditorAttributes:(NSText *)text;

@end
