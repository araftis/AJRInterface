/*
 NSUserDefaults+Extensions.h
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

#import <AppKit/AppKit.h>

#import <AJRInterface/AJRInterfaceDefines.h>

extern NSString *AJRStringFromColor(NSColor *color);
extern NSColor *AJRColorFromString(NSString *color);
extern NSString *AJRStringFromFont(NSFont *font);
extern NSFont *AJRFontFromString(NSString *font);

@interface NSUserDefaults (AJRInterfaceExtensions)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)key;
- (NSColor *)colorForKey:(NSString *)key;

- (void)setPrintInfo:(NSPrintInfo *)anInfo forKey:(NSString *)aKey;
- (NSPrintInfo *)printInfoForKey:(NSString *)aKey;

- (void)setFont:(NSFont *)aFont forKey:(NSString *)aKey;
- (NSFont *)fontForKey:(NSString *)key;
- (NSFont *)fontForKey:(NSString *)key defaultFont:(NSFont *)defaultFont;

- (NSSize)sizeForKey:(NSString *)key;
- (void)setSize:(NSSize)size forKey:(NSString *)key;

@end
