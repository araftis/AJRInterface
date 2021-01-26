//
//  AJRLineNumberMarker.h
//  Line View Test
//
//  Created by Paul Kim on 9/30/08.
//  Copyright (c) 2008 AJRsoft, LLC. All rights reserved.
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
// THE SOFTWARE IS PROVIDED "AJR IS", WITHOUT WARRANTY OF ANY KIND,
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
