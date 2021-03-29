/*
NSColor+ExtensionsTests.m
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

#import <AJRInterface/AJRInterface.h>

@interface NSColor_ExtensionsTests : XCTestCase

@end

@implementation NSColor_ExtensionsTests

- (void)testCoding {
    NSMutableArray *array = [NSMutableArray array];

    // Colors
    [array addObject:[NSColor redColor]];
    [array addObject:[NSColor windowBackgroundColor]];
    [array addObject:[NSColor colorWithCalibratedWhite:0.75 alpha:0.95]];
    [array addObject:[NSColor colorWithDeviceWhite:0.75 alpha:0.95]];
    [array addObject:[NSColor colorWithDeviceRed:0.8 green:0.7 blue:0.6 alpha:0.5]];
    [array addObject:[NSColor colorWithDeviceCyan:0.8 magenta:0.8 yellow:0.6 black:0.5 alpha:0.4]];
    [array addObject:[NSColor colorWithGenericGamma22White:0.75 alpha:1.0]];
    [array addObject:[NSColor colorWithSRGBRed:0.8 green:0.7 blue:0.6 alpha:0.5]];
    CGFloat components[] = { 1.0, 0.75, 0.50, 0.25 };
    [array addObject:[NSColor colorWithColorSpace:[NSColorSpace displayP3ColorSpace] components:components count:4]];
    [array addObject:[NSColor colorWithPatternImage:[NSImage imageNamed:NSImageNameCaution]]];
    
    NSData *data = [AJRXMLArchiver archivedDataWithRootObject:array forKey:@"colors"];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSError *localError;
    NSArray *decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(localError == nil);
    XCTAssert(decoded != nil);
    XCTAssert([array isEqualToArray:decoded]);
}

@end
