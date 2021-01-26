//
//  AJRXMLCodingTests.m
//  AJRInterface
//
//  Created by A.J. Raftis on 5/30/14.
//
//

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
