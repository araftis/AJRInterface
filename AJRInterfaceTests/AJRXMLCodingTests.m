/*
AJRXMLCodingTests.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterface/AJRInterface.h>

@interface AJRXMLCodingTestObject : NSObject <AJRXMLCoding>

@property (nonatomic,strong) NSMutableArray *colors;
@property (nonatomic,strong) AJRBezierPath *path;

@end

@implementation AJRXMLCodingTestObject

- (id)init {
    if ((self = [super init])) {
        _colors = [NSMutableArray array];
    }
    return self;
}

- (void)addColor:(NSColor *)color {
    [_colors addObject:color];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeComment:@"We're going to encode some colors. Go us!"];
    [coder encodeObject:_colors forKey:@"colors"];
    [coder encodeObject:_path forKey:@"path"];
}

@end

@interface AJRXMLCodingTests : XCTestCase

@end

@implementation AJRXMLCodingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXMLCoding {
    AJRXMLCodingTestObject *object = [[AJRXMLCodingTestObject alloc] init];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    AJRXMLCoder *coder = [AJRXMLArchiver archiverWithOutputStream:outputStream];

    // Colors
    [object addColor:[NSColor redColor]];
    [object addColor:[NSColor windowBackgroundColor]];
    [object addColor:[NSColor colorWithCalibratedWhite:0.75 alpha:0.95]];
    [object addColor:[NSColor colorWithDeviceWhite:0.75 alpha:0.95]];
    [object addColor:[NSColor colorWithDeviceRed:0.8 green:0.7 blue:0.6 alpha:0.5]];
    [object addColor:[NSColor colorWithDeviceCyan:0.8 magenta:0.8 yellow:0.6 black:0.5 alpha:0.4]];
    [object addColor:[NSColor colorWithGenericGamma22White:0.75 alpha:1.0]];
    [object addColor:[NSColor colorWithSRGBRed:0.8 green:0.7 blue:0.6 alpha:0.5]];
    [object addColor:[NSColor colorWithPatternImage:[NSImage imageNamed:NSImageNameCaution]]];

    // AJRBeziePath
    AJRBezierPath *path = [[AJRBezierPath alloc] init];

    [path appendBezierPathWithRect:(NSRect){{10.0, 10.0}, {100.0, 100.0}}];
    [path appendBezierPathWithOvalInRect:(NSRect){{150.0, 10.0}, {100.0, 100.0}}];
    [object setPath:path];

    // Finally test coding
    [outputStream open];
    [coder encodeRootObject:object forKey:@"object"];
    [outputStream close];
    
    NSLog(@"result:\n\n%@\n\n", [[NSString alloc] initWithData:[outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[outputStream encoding]]);
}

@end
