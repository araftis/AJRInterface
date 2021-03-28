
#import "NSShadow+Extensions.h"

#import <AJRInterfaceFoundation/AJRXMLCoder+Extensions.h>

@implementation NSShadow (AJRInterfaceExtensions)

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeObject:[self shadowColor] forKey:@"color"];
    [coder encodeFloat:[self shadowBlurRadius] forKey:@"blurRadius"];
    [coder encodeSize:[self shadowOffset] forKey:@"offset"];
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeObjectForKey:@"color" setter:^(id object) {
        self.shadowColor = object;
    }];
    [coder decodeFloatForKey:@"blurRadius" setter:^(float value) {
        self.shadowBlurRadius = value;
    }];
    [coder decodeSizeForKey:@"offset" setter:^(CGSize size) {
        self.shadowOffset = size;
    }];
}

@end
