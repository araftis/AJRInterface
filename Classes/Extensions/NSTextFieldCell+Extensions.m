
#import "NSTextFieldCell+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <objc/runtime.h>

@interface NSTextFieldCell (AJRForwardDelcarations)
- (NSText *)ajr_setUpFieldEditorAttributes:(NSText *)textIn;
@end

@interface _AJRTextFieldCellExtensionsLoader : NSObject

@end

@implementation _AJRTextFieldCellExtensionsLoader

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AJRSwizzleMethods(objc_getClass("NSTextFieldCell"), @selector(setUpFieldEditorAttributes:), objc_getClass("NSTextFieldCell"), @selector(ajr_setUpFieldEditorAttributes:));
    });
}

@end

@implementation NSTextFieldCell (Extensions)

- (NSText *)ajr_setUpFieldEditorAttributes:(NSText *)textIn
{
    NSText    *text = [self ajr_setUpFieldEditorAttributes:textIn];
    id        delegate = nil;
    
    if ([[self controlView] respondsToSelector:@selector(delegate)]) {
        delegate = [(NSTextField *)[self controlView] delegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldCell:setUpFieldEditorAttributes:)]) {
        text = [delegate textFieldCell:self setUpFieldEditorAttributes:text];
    }
    
    return text;
}

@end
