
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
