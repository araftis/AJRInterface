//
//  NSColor+ExtensionsTests.m
//  AJRInterfaceTests
//
//  Created by AJ Raftis on 11/13/19.
//

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
