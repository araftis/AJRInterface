
#import "NSPrinter+Extensions.h"

@interface AJRPrinterPlaceHolder : NSObject <AJRXMLDecoding>

@property (nonatomic,strong,nullable) NSString *name;
@property (nonatomic,strong,nullable) NSString *type;

@end

@implementation NSPrinter (Extensions)

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRPrinterPlaceHolder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.type forKey:@"type"];
}

@end

@implementation AJRPrinterPlaceHolder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeObjectForKey:@"name" setter:^(id  _Nullable object) {
        self->_name = object;
    }];
    [coder decodeObjectForKey:@"type" setter:^(id  _Nullable object) {
        self->_type = object;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    NSPrinter *printer = nil;

    if (_name != nil) {
        printer = [NSPrinter printerWithName:_name];
    }
    if (_type != nil) {
        printer = [NSPrinter printerWithType:_type];
    }

    return printer;
}

@end
