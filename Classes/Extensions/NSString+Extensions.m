
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
