/*
 AJRScrollViewAccessories.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

#import "AJRScrollViewAccessories.h"

#import "NSBundle+Extensions.h"

#import <math.h>

#define EXPONENT ((double)2.66)

@implementation AJRScrollViewAccessories

static AJRScrollViewAccessories *SELF = nil;

+ (id)allocWithZone:(NSZone *)zone {
    if (SELF == nil) {
        SELF = [super allocWithZone:zone];
    }
    return SELF;
}

+ (id)sharedInstance {
    return [[self alloc] init];
}

- (void)awakeFromNib {
   [textField setFont:[NSFont userFontOfSize:10.0]];
}

- (NSInteger)runWithPercent:(NSInteger)percent {
   NSInteger result;
   
   if (!window) {
      [NSBundle ajr_loadNibNamed:@"AJRScrollViewAccessories" owner:self];

      [slider setMinValue:(double)pow((double)10.0, (double)1.0 / EXPONENT)];
      [slider setMaxValue:(double)pow((double)1600.0, (double)1.0 / EXPONENT)];
   }

   [textField setIntegerValue:percent];
   [slider setDoubleValue:(double)pow((double)percent, (double)1.0 / EXPONENT)];

   [window center];
   [window makeKeyAndOrderFront:self];

   result = [NSApp runModalForWindow:window];
   
   [window orderOut:self];

   return result;
}

- (void)takeIntValueFrom:(id)sender {
   NSInteger percent = rint(pow([sender floatValue], EXPONENT));

   if (percent < 100) {
      percent = (percent / 5) * 5;
   } else if (percent < 250) {
      percent = (percent / 25) * 25;
   } else if (percent < 500) {
      percent = (percent / 50) * 50;
   } else {
      percent = (percent / 100) * 100;
   }

   [textField setIntegerValue:percent];
}

- (void)ok:sender {
   [NSApp stopModalWithCode:NSModalResponseOK];
}

- (void)cancel:sender {
   [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (NSInteger)percent {
   return [textField floatValue];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
   double value = [textField doubleValue];

   if (value < 10.0) value = 10.0;
   if (value > 1600.0) value = 1600.0;

   [slider setDoubleValue:(double)pow(value, (double)1.0 / EXPONENT)];
}

@end
