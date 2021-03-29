/*
AJRLineNumberMarker.h
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
//  AJRLineNumberMarker.h
//  AJRInterface
//
//  Created by Paul Kim on 9/30/08.
//  Copyright (c) 2008 ASsoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRMarkerAlignment) {
    AJRMarkerLeftAlignment = 0,
    AJRMarkerTopAlignment = 1,
    AJRMarkerCenterAlignment = 2,
    AJRMarkerBottomAlignment = 3,
    AJRMarkerRightAlignment = 4
};

@class AJRLineNumberView;

@interface AJRLineNumberMarker : NSRulerMarker

- (id)initWithLineNumberView:(AJRLineNumberView *)lineNumberView lineNumber:(NSUInteger)line image:(nullable NSImage *)image imageOrigin:(NSPoint)imageOrigin;

@property (nonatomic,assign) NSUInteger lineNumber;
@property (nonatomic,assign) AJRMarkerAlignment horizontalAlignment;
@property (nonatomic,assign) AJRMarkerAlignment verticalAlignment;
@property (nonatomic,assign) NSRect hitRect;

@end

NS_ASSUME_NONNULL_END
