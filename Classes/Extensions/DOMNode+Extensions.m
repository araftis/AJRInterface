
#import "DOMNode+Extensions.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

@implementation DOMNode (Extensions)

- (void)removeAllChildren {
    while ([[self childNodes] length]) {
        [self removeChild:[[self childNodes] item:0]];
    }
}

- (BOOL)matchesName:(NSString *)name withAttribute:(NSString *)attributeName equalTo:(NSString *)value {
    return [[self nodeName] caseInsensitiveCompare:name] == NSOrderedSame &&
    [[self attributes] getNamedItem:@"CLASS"] != nil &&
    [[[(DOMAttr *)[[self attributes] getNamedItem:@"CLASS"] value] description] caseInsensitiveCompare:value] == NSOrderedSame;
}

@end

#pragma clang diagnostic pop
