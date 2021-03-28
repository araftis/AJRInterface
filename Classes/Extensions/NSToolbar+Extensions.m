
#import "NSToolbar+Extensions.h"

#import <AJRFoundation/AJRTranslator.h>

#import <objc/objc-runtime.h>

@implementation NSToolbar (AJRInterfaceExtensions)

- (NSToolbarItem *)toolbarItemForItemIdentifier:(NSString *)itemIdentifier {
    NSArray *items = [self items];
    
    for (NSToolbarItem *item in items) {
        if ([[item itemIdentifier] isEqualToString:itemIdentifier]) return item;
    }
    
    return nil;
}

- (void)translateWithTranslator:(AJRTranslator *)translator {
    for (NSToolbarItem *item in [self items]) {
        NSString *labelKey;
        NSString *paletteKey;
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
        labelKey = objc_getAssociatedObject(item, @"__LABEL_KEY__");
        paletteKey = objc_getAssociatedObject(item, @"__PALETTE_KEY__");
        if (labelKey == nil) {
            labelKey = [item label];
            objc_setAssociatedObject(item, @"__LABEL_KEY__", labelKey, OBJC_ASSOCIATION_RETAIN);
        }
        if (paletteKey == nil) {
            paletteKey = [item paletteLabel];
            objc_setAssociatedObject(item, @"__PALETTE_KEY__", paletteKey, OBJC_ASSOCIATION_RETAIN);
        }
#else
        labelKey = [item label];
        paletteKey = [item paletteLabel];
#endif
        [item setLabel:[translator valueForKey:labelKey]];
        [item setPaletteLabel:[translator valueForKey:paletteKey]];
    }
}

@end
