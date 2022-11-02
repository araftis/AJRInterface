/*
 NSTextView+Extensions.m
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

#import "NSTextView+Extensions.h"

#import <AJRFoundation/AJRFunctions.h>

@implementation NSTextView (AJRInterfaceExtensions)

- (NSRange)rangeForLine:(NSUInteger)line {
    NSUInteger index, numberOfLines, stringLength;
    NSString *text;
    NSRange range;
    
    text = [[self textStorage] string];
    stringLength = [text length];
    
    index = 0;
    numberOfLines = 0;
    
    do {
        range = [text lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange(range);
        numberOfLines++;
        if (numberOfLines == line) {
            return range;
        }
    }
    while (index < stringLength);
    
    return (NSRange){NSNotFound, 0};
//    
//    // Check if text ends with a new line.
//    [text getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineIndices lastObject] unsignedIntValue], 0)];
//    if (contentEnd < lineEnd) {
//        [_lineIndices addObject:[NSNumber numberWithUnsignedInt:index]];
//    }
}

- (AJRLineNumberView *)lineNumberView {
    NSScrollView *scrollView = [self enclosingScrollView];
    id lineNumberView;
    
    lineNumberView = [scrollView verticalRulerView];
    
    if ([lineNumberView isKindOfClass:[NSRulerView class]]) {
        return lineNumberView;
    }
    
    return nil;
}

@end
