/*
AJRLineNumberMarker.m
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
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
//
//  AJRLineNumberMarker.m
//  AJRInterface
//
//  Created by Paul Kim on 9/30/08.
//  Copyright (c) 2008 ASsoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and ajrsociated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "AJRLineNumberMarker.h"

#import "AJRLineNumberView.h"

#import <AJRFoundation/AJRFoundation.h>

@interface AJRLineNumberView (AJRPrivate)

- (void)_moveMarkerFromLine:(NSUInteger)originLine toLine:(NSUInteger)destinationLine;

@end

@implementation AJRLineNumberMarker

#pragma mark - Creation

- (instancetype)initWithLineNumberView:(AJRLineNumberView *)lineNumberView lineNumber:(NSUInteger)line image:(NSImage *)anImage imageOrigin:(NSPoint)imageOrigin {
    NSImage *image = anImage;
    if (image == nil) {
        image = [NSImage imageNamed:NSImageNameStatusNone];
    }
    if ((self = [super initWithRulerView:lineNumberView markerLocation:0.0 image:image imageOrigin:imageOrigin]) != nil) {
        _lineNumber = line;
        _horizontalAlignment = AJRMarkerLeftAlignment;
        _verticalAlignment = AJRMarkerTopAlignment;
    }
    return self;
}

#pragma mark - Properties

- (AJRLineNumberView *)lineNumberView {
    return AJRObjectIfKindOfClass([super ruler], AJRLineNumberView);
}

- (void)setLineNumber:(NSUInteger)lineNumber {
    if (_lineNumber != lineNumber) {
        NSUInteger oldNumber = _lineNumber;
        _lineNumber = lineNumber;
        [[self lineNumberView] _moveMarkerFromLine:oldNumber toLine:_lineNumber];
    }
}

#pragma mark - NSCoding

#define AJR_LINE_CODING_KEY @"line"
#define AJR_HORIZONTAL_ALIGNMENT_CODING_KEY @"horizontalAlignment"
#define AJR_VERTICAL_ALIGNMENT_CODING_KEY @"verticalAlignment"

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder]) != nil) {
        if ([decoder allowsKeyedCoding]) {
            self.lineNumber = [decoder decodeIntegerForKey:AJR_LINE_CODING_KEY];
            self.horizontalAlignment = [decoder decodeIntegerForKey:AJR_HORIZONTAL_ALIGNMENT_CODING_KEY];
            self.verticalAlignment = [decoder decodeIntegerForKey:AJR_VERTICAL_ALIGNMENT_CODING_KEY];
        } else {
            self.lineNumber = [[decoder decodeObject] unsignedIntValue];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    if ([encoder allowsKeyedCoding]) {
        [encoder encodeInteger:self.lineNumber forKey:AJR_LINE_CODING_KEY];
        [encoder encodeInteger:self.horizontalAlignment forKey:AJR_HORIZONTAL_ALIGNMENT_CODING_KEY];
        [encoder encodeInteger:self.verticalAlignment forKey:AJR_VERTICAL_ALIGNMENT_CODING_KEY];
    } else {
        [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.lineNumber]];
    }
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [super copyWithZone:zone];
    
    [copy setLineNumber:self.lineNumber];
    [copy setHorizontalAlignment:self.horizontalAlignment];
    [(AJRLineNumberMarker *)copy setVerticalAlignment:self.verticalAlignment];
    
    return copy;
}


@end
