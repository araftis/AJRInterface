/*
 NSPrinter+Extensions.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSPrinter+Extensions.h"

#import "AJRPaper.h"
#import "NSPrintInfo+Extensions.h"

@interface AJRPrinterPlaceHolder : NSObject <AJRXMLDecoding>

@property (nonatomic,assign) BOOL isGeneric;
@property (nonatomic,strong,nullable) NSString *name;
@property (nonatomic,strong,nullable) NSString *type;

@end

// Not sure why this is so, but it's what seems to be so.
NSString * const AJRGenericPrinterName = @" ";

@implementation NSPrinter (Extensions)

static NSPrinter *genericPrinter;

+ (NSPrinter *)genericPrinter {
    if (genericPrinter == nil) {
        PMPrinter printer;

        if (PMCreateGenericPrinter(&printer) == kPMNoError) {
            genericPrinter = [[NSPrinter alloc] init];
            [genericPrinter setValue:@" " forKey:@"printerName"];
            Class printerClass = [NSPrinter class];
            Ivar variable = class_getInstanceVariable(printerClass, "_printer");
            if (variable) {
                object_setIvar(genericPrinter, variable, (__bridge id _Nullable)(printer));
            }
        }
    }
    return genericPrinter;
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRPrinterPlaceHolder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if ([self.name isEqualToString:AJRGenericPrinterName]) {
        [coder encodeBool:YES forKey:@"generic"];
    } else {
        [coder encodeObject:self.name forKey:@"name"];
        [coder encodeObject:self.type forKey:@"type"];
    }
}

@end

@implementation AJRPrinterPlaceHolder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeBoolForKey:@"generic" setter:^(BOOL value) {
        self->_isGeneric = YES;
    }];
    [coder decodeObjectForKey:@"name" setter:^(id  _Nullable object) {
        self->_name = object;
    }];
    [coder decodeObjectForKey:@"type" setter:^(id  _Nullable object) {
        self->_type = object;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    NSPrinter *printer = nil;

    if (_isGeneric) {
        printer = NSPrinter.genericPrinter;
    } else {
        if (_name != nil) {
            printer = [NSPrinter printerWithName:_name];
        }
        if (printer == nil && _type != nil) {
            printer = [NSPrinter printerWithType:_type];
        }
    }

    // Force the faulting of our papers, because we're going to want that when we decode our paper.
    [printer allPapers];

    return printer;
}

@end
