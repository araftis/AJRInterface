/*
 NSString+Extensions.m
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

#import "NSString+Extensions.h"

#import "NSGraphicsContext+Extensions.h"

@implementation NSString (AJRInterfaceExtensions)

- (NSSize)sizeWithAttributes:(NSDictionary *)attributes constrainedToWidth:(CGFloat)width {
    NSSize size;
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttributes:attributes range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    size.height = [layoutManager usedRectForTextContainer:textContainer].size.height;
    size.width = width;
    

    return size;
}

- (void)drawAtPoint:(NSPoint)point withAttributes:(NSDictionary *)attrs context:(CGContextRef)context {
	[NSGraphicsContext drawInContext:context withBlock:^{
		[self drawAtPoint:point withAttributes:attrs];
	}];
}

- (void)drawInRect:(NSRect)rect withAttributes:(NSDictionary *)attrs context:(CGContextRef)context {
	[NSGraphicsContext drawInContext:context withBlock:^{
		[self drawInRect:rect withAttributes:attrs];
	}];
}

- (NSString *)stringByReplacingTypographicalSubstitutions {
	NSMutableString *string = [self mutableCopy];
	NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
	NSArray *results = [spellChecker checkString:string range:(NSRange){0, [string length]} types:NSTextCheckingTypeQuote|NSTextCheckingTypeDash|NSTextCheckingTypeReplacement options:nil inSpellDocumentWithTag:0 orthography:NULL wordCount:NULL];
	__block NSInteger rangeAdjust = 0;
	[results enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
		[string replaceCharactersInRange:(NSRange){[result range].location - rangeAdjust, [result range].length} withString:[result replacementString]];
		rangeAdjust += ([result range].length - [[result replacementString] length]);
	}];
	return string;
}

@end
