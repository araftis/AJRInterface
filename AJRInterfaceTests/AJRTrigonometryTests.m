/*
 AJRTrigonometryTests.m
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

#import <XCTest/XCTest.h>

#import "AJRTrigonometry.h"

#import <AJRFoundation/AJRLogging.h>

@interface AJRTrigonometryTests : XCTestCase

@end

@implementation AJRTrigonometryTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)checkAngle:(double)angle granularity:(double)granularity expected:(double)expected {
    NSAssert(AJRRoundAngle(angle, granularity) == expected, @"Expected angles don't match AJRRoundAngle(%.1f, %.1f) = %.1f, should equal %.1f", angle, granularity, AJRRoundAngle(angle, granularity));
}

- (void)testAngleRounding {
//    for (double angle = -180; angle < 720; angle += 5) {
//        AJRLogInfo(@"[self checkAngle:%.1f granularity:45.0 expected:%.1f];", angle, AJRRoundAngle(angle, 45.0));
//    }
    [self checkAngle:-180.0 granularity:45.0 expected:-180.0];
    [self checkAngle:-175.0 granularity:45.0 expected:-180.0];
    [self checkAngle:-170.0 granularity:45.0 expected:-180.0];
    [self checkAngle:-165.0 granularity:45.0 expected:-180.0];
    [self checkAngle:-160.0 granularity:45.0 expected:-180.0];
    [self checkAngle:-155.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-150.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-145.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-140.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-135.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-130.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-125.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-120.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-115.0 granularity:45.0 expected:-135.0];
    [self checkAngle:-110.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-105.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-100.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-95.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-90.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-85.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-80.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-75.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-70.0 granularity:45.0 expected:-90.0];
    [self checkAngle:-65.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-60.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-55.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-50.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-45.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-40.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-35.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-30.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-25.0 granularity:45.0 expected:-45.0];
    [self checkAngle:-20.0 granularity:45.0 expected:-0.0];
    [self checkAngle:-15.0 granularity:45.0 expected:-0.0];
    [self checkAngle:-10.0 granularity:45.0 expected:-0.0];
    [self checkAngle:-5.0 granularity:45.0 expected:-0.0];
    [self checkAngle:0.0 granularity:45.0 expected:0.0];
    [self checkAngle:5.0 granularity:45.0 expected:0.0];
    [self checkAngle:10.0 granularity:45.0 expected:0.0];
    [self checkAngle:15.0 granularity:45.0 expected:0.0];
    [self checkAngle:20.0 granularity:45.0 expected:0.0];
    [self checkAngle:25.0 granularity:45.0 expected:45.0];
    [self checkAngle:30.0 granularity:45.0 expected:45.0];
    [self checkAngle:35.0 granularity:45.0 expected:45.0];
    [self checkAngle:40.0 granularity:45.0 expected:45.0];
    [self checkAngle:45.0 granularity:45.0 expected:45.0];
    [self checkAngle:50.0 granularity:45.0 expected:45.0];
    [self checkAngle:55.0 granularity:45.0 expected:45.0];
    [self checkAngle:60.0 granularity:45.0 expected:45.0];
    [self checkAngle:65.0 granularity:45.0 expected:45.0];
    [self checkAngle:70.0 granularity:45.0 expected:90.0];
    [self checkAngle:75.0 granularity:45.0 expected:90.0];
    [self checkAngle:80.0 granularity:45.0 expected:90.0];
    [self checkAngle:85.0 granularity:45.0 expected:90.0];
    [self checkAngle:90.0 granularity:45.0 expected:90.0];
    [self checkAngle:95.0 granularity:45.0 expected:90.0];
    [self checkAngle:100.0 granularity:45.0 expected:90.0];
    [self checkAngle:105.0 granularity:45.0 expected:90.0];
    [self checkAngle:110.0 granularity:45.0 expected:90.0];
    [self checkAngle:115.0 granularity:45.0 expected:135.0];
    [self checkAngle:120.0 granularity:45.0 expected:135.0];
    [self checkAngle:125.0 granularity:45.0 expected:135.0];
    [self checkAngle:130.0 granularity:45.0 expected:135.0];
    [self checkAngle:135.0 granularity:45.0 expected:135.0];
    [self checkAngle:140.0 granularity:45.0 expected:135.0];
    [self checkAngle:145.0 granularity:45.0 expected:135.0];
    [self checkAngle:150.0 granularity:45.0 expected:135.0];
    [self checkAngle:155.0 granularity:45.0 expected:135.0];
    [self checkAngle:160.0 granularity:45.0 expected:180.0];
    [self checkAngle:165.0 granularity:45.0 expected:180.0];
    [self checkAngle:170.0 granularity:45.0 expected:180.0];
    [self checkAngle:175.0 granularity:45.0 expected:180.0];
    [self checkAngle:180.0 granularity:45.0 expected:180.0];
    [self checkAngle:185.0 granularity:45.0 expected:180.0];
    [self checkAngle:190.0 granularity:45.0 expected:180.0];
    [self checkAngle:195.0 granularity:45.0 expected:180.0];
    [self checkAngle:200.0 granularity:45.0 expected:180.0];
    [self checkAngle:205.0 granularity:45.0 expected:225.0];
    [self checkAngle:210.0 granularity:45.0 expected:225.0];
    [self checkAngle:215.0 granularity:45.0 expected:225.0];
    [self checkAngle:220.0 granularity:45.0 expected:225.0];
    [self checkAngle:225.0 granularity:45.0 expected:225.0];
    [self checkAngle:230.0 granularity:45.0 expected:225.0];
    [self checkAngle:235.0 granularity:45.0 expected:225.0];
    [self checkAngle:240.0 granularity:45.0 expected:225.0];
    [self checkAngle:245.0 granularity:45.0 expected:225.0];
    [self checkAngle:250.0 granularity:45.0 expected:270.0];
    [self checkAngle:255.0 granularity:45.0 expected:270.0];
    [self checkAngle:260.0 granularity:45.0 expected:270.0];
    [self checkAngle:265.0 granularity:45.0 expected:270.0];
    [self checkAngle:270.0 granularity:45.0 expected:270.0];
    [self checkAngle:275.0 granularity:45.0 expected:270.0];
    [self checkAngle:280.0 granularity:45.0 expected:270.0];
    [self checkAngle:285.0 granularity:45.0 expected:270.0];
    [self checkAngle:290.0 granularity:45.0 expected:270.0];
    [self checkAngle:295.0 granularity:45.0 expected:315.0];
    [self checkAngle:300.0 granularity:45.0 expected:315.0];
    [self checkAngle:305.0 granularity:45.0 expected:315.0];
    [self checkAngle:310.0 granularity:45.0 expected:315.0];
    [self checkAngle:315.0 granularity:45.0 expected:315.0];
    [self checkAngle:320.0 granularity:45.0 expected:315.0];
    [self checkAngle:325.0 granularity:45.0 expected:315.0];
    [self checkAngle:330.0 granularity:45.0 expected:315.0];
    [self checkAngle:335.0 granularity:45.0 expected:315.0];
    [self checkAngle:340.0 granularity:45.0 expected:360.0];
    [self checkAngle:345.0 granularity:45.0 expected:360.0];
    [self checkAngle:350.0 granularity:45.0 expected:360.0];
    [self checkAngle:355.0 granularity:45.0 expected:360.0];
    [self checkAngle:360.0 granularity:45.0 expected:360.0];
    [self checkAngle:365.0 granularity:45.0 expected:360.0];
    [self checkAngle:370.0 granularity:45.0 expected:360.0];
    [self checkAngle:375.0 granularity:45.0 expected:360.0];
    [self checkAngle:380.0 granularity:45.0 expected:360.0];
    [self checkAngle:385.0 granularity:45.0 expected:405.0];
    [self checkAngle:390.0 granularity:45.0 expected:405.0];
    [self checkAngle:395.0 granularity:45.0 expected:405.0];
    [self checkAngle:400.0 granularity:45.0 expected:405.0];
    [self checkAngle:405.0 granularity:45.0 expected:405.0];
    [self checkAngle:410.0 granularity:45.0 expected:405.0];
    [self checkAngle:415.0 granularity:45.0 expected:405.0];
    [self checkAngle:420.0 granularity:45.0 expected:405.0];
    [self checkAngle:425.0 granularity:45.0 expected:405.0];
    [self checkAngle:430.0 granularity:45.0 expected:450.0];
    [self checkAngle:435.0 granularity:45.0 expected:450.0];
    [self checkAngle:440.0 granularity:45.0 expected:450.0];
    [self checkAngle:445.0 granularity:45.0 expected:450.0];
    [self checkAngle:450.0 granularity:45.0 expected:450.0];
    [self checkAngle:455.0 granularity:45.0 expected:450.0];
    [self checkAngle:460.0 granularity:45.0 expected:450.0];
    [self checkAngle:465.0 granularity:45.0 expected:450.0];
    [self checkAngle:470.0 granularity:45.0 expected:450.0];
    [self checkAngle:475.0 granularity:45.0 expected:495.0];
    [self checkAngle:480.0 granularity:45.0 expected:495.0];
    [self checkAngle:485.0 granularity:45.0 expected:495.0];
    [self checkAngle:490.0 granularity:45.0 expected:495.0];
    [self checkAngle:495.0 granularity:45.0 expected:495.0];
    [self checkAngle:500.0 granularity:45.0 expected:495.0];
    [self checkAngle:505.0 granularity:45.0 expected:495.0];
    [self checkAngle:510.0 granularity:45.0 expected:495.0];
    [self checkAngle:515.0 granularity:45.0 expected:495.0];
    [self checkAngle:520.0 granularity:45.0 expected:540.0];
    [self checkAngle:525.0 granularity:45.0 expected:540.0];
    [self checkAngle:530.0 granularity:45.0 expected:540.0];
    [self checkAngle:535.0 granularity:45.0 expected:540.0];
    [self checkAngle:540.0 granularity:45.0 expected:540.0];
    [self checkAngle:545.0 granularity:45.0 expected:540.0];
    [self checkAngle:550.0 granularity:45.0 expected:540.0];
    [self checkAngle:555.0 granularity:45.0 expected:540.0];
    [self checkAngle:560.0 granularity:45.0 expected:540.0];
    [self checkAngle:565.0 granularity:45.0 expected:585.0];
    [self checkAngle:570.0 granularity:45.0 expected:585.0];
    [self checkAngle:575.0 granularity:45.0 expected:585.0];
    [self checkAngle:580.0 granularity:45.0 expected:585.0];
    [self checkAngle:585.0 granularity:45.0 expected:585.0];
    [self checkAngle:590.0 granularity:45.0 expected:585.0];
    [self checkAngle:595.0 granularity:45.0 expected:585.0];
    [self checkAngle:600.0 granularity:45.0 expected:585.0];
    [self checkAngle:605.0 granularity:45.0 expected:585.0];
    [self checkAngle:610.0 granularity:45.0 expected:630.0];
    [self checkAngle:615.0 granularity:45.0 expected:630.0];
    [self checkAngle:620.0 granularity:45.0 expected:630.0];
    [self checkAngle:625.0 granularity:45.0 expected:630.0];
    [self checkAngle:630.0 granularity:45.0 expected:630.0];
    [self checkAngle:635.0 granularity:45.0 expected:630.0];
    [self checkAngle:640.0 granularity:45.0 expected:630.0];
    [self checkAngle:645.0 granularity:45.0 expected:630.0];
    [self checkAngle:650.0 granularity:45.0 expected:630.0];
    [self checkAngle:655.0 granularity:45.0 expected:675.0];
    [self checkAngle:660.0 granularity:45.0 expected:675.0];
    [self checkAngle:665.0 granularity:45.0 expected:675.0];
    [self checkAngle:670.0 granularity:45.0 expected:675.0];
    [self checkAngle:675.0 granularity:45.0 expected:675.0];
    [self checkAngle:680.0 granularity:45.0 expected:675.0];
    [self checkAngle:685.0 granularity:45.0 expected:675.0];
    [self checkAngle:690.0 granularity:45.0 expected:675.0];
    [self checkAngle:695.0 granularity:45.0 expected:675.0];
    [self checkAngle:700.0 granularity:45.0 expected:720.0];
    [self checkAngle:705.0 granularity:45.0 expected:720.0];
    [self checkAngle:710.0 granularity:45.0 expected:720.0];
    [self checkAngle:715.0 granularity:45.0 expected:720.0];
}

@end
