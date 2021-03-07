//
//  AJRSyntaxTextStorage.m
//  AJRInterface
//
//  Created by A.J. Raftis on 3/20/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRSyntaxTextStorage.h"

#import "AJRSyntaxComponent.h"
#import "AJRSyntaxDefinition.h"

#import <AJRFoundation/AJRFunctions.h>

NSString * const AJRUserDefinedIdentifiers = @"SyntaxColoring:UserIdentifiers";
NSString * const AJRSyntaxColoringModeAtttributeName = @"AJRTextDocumentSyntaxColoringMode";

@interface AJRSyntaxTextStorage ()

- (NSDictionary *)_styleFromComponent:(AJRSyntaxComponent *)component andMode:(NSString *)mode;

@end


@implementation AJRSyntaxTextStorage {
    NSMutableAttributedString *_string;
}

- (void)updateColors:(NSNotification *)notification {
    AJRSyntaxComponent *component = [[notification userInfo] objectForKey:AJRSyntaxComponentKey];
    NSColor *backgroundColor = nil;
    NSColor *insertionPointColor = nil;
    BOOL isFontChange;
    NSRange allRange;
    NSString *changeKey = [[notification userInfo] objectForKey:AJRSyntaxComponentChangeKey];
    
    if ([[component type] isEqualToString:AJRSyntaxComponentTextType]) {
        CGFloat grayLevel;

        backgroundColor = [component backgroundColor];
        grayLevel = [[backgroundColor colorUsingColorSpace:[NSColorSpace genericGamma22GrayColorSpace]] whiteComponent];
        if (grayLevel < 0.5) {
            insertionPointColor = [NSColor whiteColor];
        } else {
            insertionPointColor = [NSColor blackColor];
        }
    }
    
    isFontChange = changeKey == nil || [changeKey isEqualTo:AJRSyntaxFontKey] || [changeKey isEqualTo:AJRSyntaxActiveKey];
    allRange = (NSRange){0, [self length]};
    
    [self invalidateAttributesInRange:(NSRange){0, [_string length]}];
    
    for (NSLayoutManager *layoutManager in [self layoutManagers]) {
        if (isFontChange) {
            [layoutManager processEditingForTextStorage:self edited:NSTextStorageEditedAttributes range:allRange changeInLength:0 invalidatedRange:allRange];
        } else {
            for (NSTextContainer *textContainer in [layoutManager textContainers]) {
                NSTextView *textView = [textContainer textView];
                [textView setNeedsDisplay:YES];
                if (backgroundColor) {
                    [textView setBackgroundColor:backgroundColor];
                }
                if (insertionPointColor) {
                    [textView setInsertionPointColor:insertionPointColor];
                }
            }
        }
    }
}

- (id)initWithSyntaxDefinition:(AJRSyntaxDefinition *)definition {
    if ((self = [super init])) {
        _string = [[NSMutableAttributedString alloc] init];
        _syntaxDefinition = definition;
        _syntaxColoringEnabled = _syntaxDefinition != nil;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColors:) name:AJRSyntaxDefinitionDidChangeNotification object:_syntaxDefinition];
    }
    return self;
}

- (id)initWithSyntaxDefinitionNamed:(NSString *)name {
    AJRSyntaxDefinition *definition = [AJRSyntaxDefinition syntaxDefinitionForName:name];
    
    if (definition == nil) {
        return nil;
    }
    
    return [self initWithSyntaxDefinition:definition];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSTextView *)textView {
    return [(NSTextContainer *)[[(NSLayoutManager *)[[self layoutManagers] lastObject] textContainers] lastObject] textView];
}

- (NSString *)string {
    return [_string string];
}

- (NSMutableString *)mutableString {
    return [_string mutableString];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [_string attributesAtIndex:index effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString {
    [_string replaceCharactersInRange:aRange withString:aString];
    [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:[aString length] - aRange.length];
}

- (void)replaceCharactersInRange:(NSRange)aRange withAttributedString:(NSAttributedString *)attributedString {
    [_string replaceCharactersInRange:aRange withAttributedString:attributedString];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:aRange changeInLength:[attributedString length] - aRange.length];
}

- (void)setAttributes:(NSDictionary *)dictionary range:(NSRange)range {
    [_string setAttributes:dictionary range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (NSColor *)textColor {
    return [_syntaxDefinition textColor];
}

- (NSColor *)textBackgroundColor {
    return [_syntaxDefinition textBackgroundColor];
}

- (NSFont *)textFont {
    return [_syntaxDefinition textFont];
}

- (BOOL)_applyComponent:(AJRSyntaxComponent *)component toRange:(NSRange)range {
    NSString *vComponentType = [component type];
    NSString *vComponentName = [component name];
    
    if ([vComponentType isEqualToString:AJRSyntaxComponentBlockCommentType]) {
        return [self colorComments:component inRange:range andMode:vComponentName];
    } else if ([vComponentType isEqualToString:AJRSyntaxComponentOneLineCommentType]) {
        return [self colorOneLineComment:component inRange:range andMode:vComponentName];
    } else if ([vComponentType isEqualToString:AJRSyntaxComponentNumberType]) {
        return [self colorNumbers:component inRange:range andMode:vComponentName];
    } else if ([vComponentType isEqualToString:AJRSyntaxComponentStringType]) {
        return [self colorStrings:component inRange:range andMode:vComponentName];
    } else if ([vComponentType isEqualToString:AJRSyntaxComponentTagType]) {
        return [self colorTags:component inRange:range andMode:vComponentName];
    } else if ([vComponentType isEqualToString:AJRSyntaxComponentKeywordType]) {
        return [self colorKeywords:component inRange:range andMode:vComponentName];
    }
    return NO;
}

- (void)invalidateAttributesInRange:(NSRange)aRange {
    NSRange range;
    BOOL repeat = NO, repeated = NO;
    
    [super invalidateAttributesInRange:aRange];
    
    if (!_syntaxColoringEnabled) {
        [_string addAttribute:NSForegroundColorAttributeName value:[self textColor] range:aRange];
        [_string addAttribute:NSBackgroundColorAttributeName value:[self textBackgroundColor] range:aRange];
        [_string addAttribute:NSFontAttributeName value:[self textFont] range:aRange];
        
        return;
    }
    
    range = [[_string string] lineRangeForRange:aRange];
    //AJRPrintf(@"%C:line:\"%@\"\n", self, [[_string string] substringWithRange:range]);
    
    do {
        // Reset the attributes first
        [_string setAttributes:[self _styleFromComponent:nil andMode:nil] range:range];
        //AJRPrintf(@"styles = %@\n", [self _styleFromComponent:nil andMode:nil]);
        
        if ([_syntaxDefinition isActive]) {
            for (AJRSyntaxComponent *vCurrComponent in [_syntaxDefinition components]) {
                if ([self _applyComponent:vCurrComponent toRange:range]) repeat = YES;
            }
            if (repeat && range.location + range.length < [_string length]) {
                // The repeat triggers us to re-code from our start location through to the end of the document.
                range.length = [_string length] - range.location;
                repeated = YES;
            } else {
                // We only allow one repeat for now.
                repeat = NO;
            }
        }
    } while (repeat);
    
    if (repeated) {
        // This is actually a bit inefficient, because, strictly speaking, it'd be better to just redisplay the region where we changed the attributes, but this shouldn't be too bad, and it's a magnitude of effort easier to accomplish.
        [[self textView] setNeedsDisplay:YES];
    }
}

- (void)ensureAttributesAreFixedInRange:(NSRange)range {
    [super ensureAttributesAreFixedInRange:range];
}

- (NSColor *)_color:(AJRSyntaxComponent *)component {
    NSColor *color = [component color];
    if (color == nil) return [self textColor];
    return color;
}

- (NSColor *)_backgroundColor:(AJRSyntaxComponent *)component {
    NSColor *color = [component backgroundColor];
    if (color == nil) return [self textBackgroundColor];
    return color;
}

- (NSFont *)_font:(AJRSyntaxComponent *)component {
    NSFont *font = [component font];
    if (font == nil) return [self textFont];
    return font;
}

- (NSDictionary *)_styleFromComponent:(AJRSyntaxComponent *)component andMode:(NSString *)mode {
    return @{
        NSForegroundColorAttributeName:[self _color:component],
        NSBackgroundColorAttributeName:[self _backgroundColor:component],
        NSFontAttributeName:[self _font:component],
        // This must be last, since mode may be nil
        AJRSyntaxColoringModeAtttributeName:mode ?: @"",
    };
}

- (BOOL)colorComments:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr {
    BOOL repeat = NO;

    @try {
        NSScanner *vScanner = [NSScanner scannerWithString:[_string string]];
        NSDictionary *vStyles = [self _styleFromComponent:component andMode:attr];
        NSString *startCh = [component start];
        NSString *endCh = [component end];
        BOOL startInComment = NO;
        BOOL endInComment = NO;
        
        NSAssert(startCh != nil, @"Comment components must define a start string");
        NSAssert(endCh != nil, @"Comment components must define a end string");
        
        [vScanner setScanLocation:range.location];
        
        if (range.location > 1) {
            startInComment = [[_string attribute:AJRSyntaxColoringModeAtttributeName
                                  atIndex:range.location - 1
                           effectiveRange:NULL] isEqualToString:attr];
        }
        if (range.location + range.length + 1 < [_string length]) {
            //AJRPrintf(@"%C:%@\n", self, [_string attribute:AJRSyntaxColoringModeAtttributeName
            //                                 atIndex:range.location + range.length + 1
            //                          effectiveRange:NULL]);
            endInComment = [[_string attribute:AJRSyntaxColoringModeAtttributeName
                                       atIndex:range.location + range.length + 1
                                effectiveRange:NULL] isEqualToString:attr];
        }

        //AJRPrintf(@"%C:%d:%B/%B\n", self, range.location, startInComment, endInComment);

        while (![vScanner isAtEnd] && [vScanner scanLocation] < range.location + range.length) {
            NSInteger        vStartOffs,    vEndOffs;
            
            // Look for start of multi-line comment:
            if (startInComment) {
                // Basically, this means the previous line was a comment, so the current line is a continuation of the comment, at least until the close block.
                startInComment = NO;
                vStartOffs = [vScanner scanLocation];
            } else {
                [vScanner scanUpToString:startCh intoString:nil];
                vStartOffs = [vScanner scanLocation];
                if (vStartOffs >= range.location + range.length) {
                    // We're outside our coloring range.
                    if (!startInComment && endInComment) {
                        repeat = YES;
                        //AJRPrintf(@"%C:Need a re-highlight? %B\n", self, repeat);
                    }
                    return repeat;
                }
                if (![vScanner scanString:startCh intoString:nil]) {
                    if (!startInComment && endInComment) {
                        repeat = YES;
                        //AJRPrintf(@"%C:Need a re-highlight? %B\n", self, repeat);
                    }
                    return repeat;
                }
            }
            
            // Look for ajrsociated end-of-comment marker:
            [vScanner scanUpToString:endCh intoString:nil];
            if (![vScanner scanString:endCh intoString:nil]) {
                // We might not expect an comment close terminator, as this comment could go multiple lines.
                //return repeat;
            } else {
                // We scanned the close character, so see if the comment used to continue past this point. If it did, that means the user just typed the close comment block, and we then need to return YES from this method, since we have to re-color the remainder of the document.
                if (endInComment) {
                    repeat = [vScanner scanLocation] < range.location + range.length;
                    //AJRPrintf(@"%C:Need a re-highlight? %B (%d, %d)\n", self, repeat, [vScanner scanLocation], range.location + range.length);
                }
            }

            vEndOffs = [vScanner scanLocation];
            
            // Now mess with the string's styles:
            [_string setAttributes:vStyles range:NSMakeRange(vStartOffs, vEndOffs - vStartOffs)];
        }
    } @catch (NSException *exception) {
        AJRPrintf(@"WARNING: Exception while coloring block comments:%@", exception);
    }
    
    return repeat;
}

- (BOOL)colorOneLineComment:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr {
    @try {
        NSScanner *vScanner = [NSScanner scannerWithString:[_string string]];
        NSDictionary *vStyles = [self _styleFromComponent:component andMode:attr];
        NSString *startCh = [component start];
//        NSString *string = [_string string];
//        NSCharacterSet *newlineCS = [NSCharacterSet newlineCharacterSet];
        
        NSAssert(startCh != nil, @"Comment components must define a start string");
        
        [vScanner setCharactersToBeSkipped:nil];
        [vScanner setScanLocation:range.location];
        
        while (![vScanner isAtEnd] && [vScanner scanLocation] < range.location + range.length) {
            NSInteger vStartOffs, vEndOffs;
            
            // Look for start of one-line comment:
            [vScanner scanUpToString:startCh intoString:nil];
            vStartOffs = [vScanner scanLocation];
            if (![vScanner scanString:startCh intoString:nil]) return NO;
            
            // Look for ajrsociated line break:
            //while (![newlineCS characterIsMember:[string characterAtIndex:[vScanner scanLocation
            [vScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            
            vEndOffs = [vScanner scanLocation];
            
            // Now mess with the string's styles:
            [_string setAttributes:vStyles range:NSMakeRange(vStartOffs, vEndOffs - vStartOffs)];
        }
    } @catch (NSException *exception) {
        AJRPrintf(@"WARNING: Exception while coloring one line comments:%@", exception);
    }
    
    return NO;
}

- (BOOL)colorNumbers:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr {
    @try {
        NSScanner *vScanner = [NSScanner scannerWithString:[_string string]];
        NSDictionary *vStyles = [self _styleFromComponent:component andMode:attr];
        NSCharacterSet *cset = [component characterSet];
        //NSInteger vStartOffs = 0;
        NSString *keyword = nil;
        
        NSAssert(cset != nil, @"Keyword type must define a character set");
        
        [vScanner setScanLocation:range.location];
        
        // Skip any leading whitespace chars, somehow NSScanner doesn't do that:
        [vScanner scanUpToCharactersFromSet:cset intoString:NULL];
        
        while (![vScanner isAtEnd] && [vScanner scanLocation] < range.location + range.length) {
            // Look for start of identifier:
            keyword = nil;
            [vScanner scanUpToCharactersFromSet:cset intoString:NULL];
            if (![vScanner scanCharactersFromSet:cset intoString:&keyword]) {
                return NO;
            }

            // A single decimal point does not a number make.
            if ([keyword isEqualToString:@"."]) continue;
            
            [_string setAttributes:vStyles range:NSMakeRange([vScanner scanLocation] - [keyword length], [keyword length])];
        }
    } @catch (NSException *exception) {
        AJRPrintf(@"WARNING: Exception while coloring keywords:%@", exception);
    }
    
    return NO;
}

- (BOOL)colorStrings:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr {
    @try {
        NSScanner *vScanner = [NSScanner scannerWithString:[_string string]];
        NSDictionary *vStyles = [self _styleFromComponent:component andMode:attr];
        NSString *startCh = [component start];
        NSString *endCh = [component end];
        NSString *vStringEscapeCharacter = [component escapeCharacter];
        BOOL vIsEndChar = NO;
        unichar vEscChar = '\\';
        
        NSAssert(startCh != nil, @"Comment components must define a start string");
        NSAssert(endCh != nil, @"Comment components must define a end string");
        
        [vScanner setScanLocation:range.location];
        
        if (vStringEscapeCharacter) {
            if ([vStringEscapeCharacter length] != 0) {
                vEscChar = [vStringEscapeCharacter characterAtIndex:0];
            }
        }
        
        while (![vScanner isAtEnd] && [vScanner scanLocation] < range.location + range.length) {
            NSInteger        vStartOffs, vEndOffs; vIsEndChar = NO;
            
            // Look for start of string:
            [vScanner scanUpToString:startCh intoString:nil];
            vStartOffs = [vScanner scanLocation];
            if (![vScanner scanString:startCh intoString:nil]) return NO;
            
            while (!vIsEndChar && ![vScanner isAtEnd] && [vScanner scanLocation] < range.location + range.length)    // Loop until we find end-of-string marker or our text to color is finished:
            {
                [vScanner scanUpToString:endCh intoString:nil];
                if (([vStringEscapeCharacter length] == 0) || [[_string string] characterAtIndex:([vScanner scanLocation] - 1)] != vEscChar)    // Backslash before the end marker? That means ignore the end marker.
                    vIsEndChar = YES;    // A real one! Terminate loop.
                if (![vScanner scanString:endCh intoString:nil])    // But skip this char before that.
                    return NO;
            }
            
            vEndOffs = [vScanner scanLocation];
            
            // Now mess with the string's styles:
            [_string setAttributes:vStyles range:NSMakeRange(vStartOffs, vEndOffs - vStartOffs)];
        }
    } @catch (NSException *exception) {
        AJRPrintf(@"WARNING: Exception while coloring strings:%@", exception);
    }
    
    return NO;
}

- (BOOL)colorTags:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr {
    @try {
        NSScanner *vScanner = [NSScanner scannerWithString:[_string string]];
        NSDictionary *vStyles = [self _styleFromComponent:component andMode:attr];
        NSString *startCh = [component start];
        NSString *endCh = [component end];
        NSString *ignoreAttr = [component ignoreComponent];
        NSArray *recolorComponents = [component recolorComponents];

        [vScanner setScanLocation:range.location];
        
        NSAssert(startCh != nil, @"Tag components must define a start string");
        NSAssert(endCh != nil, @"Tag components must define an end string");
        NSAssert(ignoreAttr != nil, @"Tag components must define an ignoreAttribute");
        
        while (![vScanner isAtEnd]) {
            NSInteger        vStartOffs,    vEndOffs;
            
            // Look for start of one-line comment:
            [vScanner scanUpToString:startCh intoString:nil];
            vStartOffs = [vScanner scanLocation];
            if (vStartOffs >= [_string length]) return NO;
            
            NSString *scMode = [[_string attributesAtIndex:vStartOffs effectiveRange:nil] objectForKey:AJRSyntaxColoringModeAtttributeName];
            if (![vScanner scanString:startCh intoString:nil]) return NO;
            
            // If start lies in range of ignored style, don't colorize it:
            if (ignoreAttr != nil && [scMode isEqualToString:ignoreAttr])
                continue;
            
            // Look for matching end marker:
            while (![vScanner isAtEnd]) {
                // Scan up to the next occurence of the terminating sequence:
                [vScanner scanUpToString:endCh intoString:nil];
                
                // Now, if the mode of the end marker is not the mode we were told to ignore,
                //  we're finished now and we can exit the inner loop:
                vEndOffs = [vScanner scanLocation];
                if (vEndOffs < [_string length]) {
                    scMode = [[_string attributesAtIndex:vEndOffs effectiveRange:nil] objectForKey:AJRSyntaxColoringModeAtttributeName];
                    [vScanner scanString:endCh intoString:nil];   // Also skip the terminating sequence.
                    if (ignoreAttr == nil || ![scMode isEqualToString:ignoreAttr])
                        break;
                }
                
                // Otherwise we keep going, look for the next occurence of endCh and hope it isn't in that style.
            }
            
            vEndOffs = [vScanner scanLocation];
            
            // Now mess with the string's styles:
            [_string setAttributes:vStyles range:NSMakeRange(vStartOffs, vEndOffs - vStartOffs)];
            
            if (recolorComponents) {
                for (NSString *name in recolorComponents) {
                    AJRSyntaxComponent *component = [_syntaxDefinition componentForName:name];
                    if (component) {
                        [self _applyComponent:component toRange:NSMakeRange(vStartOffs, vEndOffs - vStartOffs)];
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        AJRPrintf(@"WARNING: Exception while coloring tags:%@", exception);
    }
    
    return NO;
}

- (BOOL)colorKeywords:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr {
    @try {
        NSScanner *vScanner = [NSScanner scannerWithString:[_string string]];
        NSDictionary *vStyles = [self _styleFromComponent:component andMode:attr];
        NSCharacterSet *cset = [component characterSet];
        NSSet *keywords = [component keywords];
        //NSInteger vStartOffs = 0;
        NSString *keyword = nil;
        
        NSAssert(cset != nil, @"Keyword type must define a character set");
        
        [vScanner setScanLocation:range.location];
        
        // Skip any leading whitespace chars, somehow NSScanner doesn't do that:
        [vScanner scanUpToCharactersFromSet:cset intoString:NULL];
        
        while (![vScanner isAtEnd] && [vScanner scanLocation] < range.location + range.length) {
            // Look for start of identifier:
            keyword = nil;
            [vScanner scanUpToCharactersFromSet:cset intoString:NULL];
            if (![vScanner scanCharactersFromSet:cset intoString:&keyword]) {
                return NO;
            }
            if (![keywords containsObject:keyword]) {
                continue;
            }
            
            if ([vScanner scanLocation] < range.location + range.length) {
                // Now mess with the string's styles:
                [_string setAttributes:vStyles range:NSMakeRange([vScanner scanLocation] - [keyword length], [keyword length])];
            }
        }
    } @catch (NSException *exception) {
        AJRPrintf(@"WARNING: Exception while coloring keywords:%@", exception);
    }
    
    return NO;
}

@end


@implementation NSTextView (AJRSyntaxText)

- (void)setSyntaxDefinition:(AJRSyntaxDefinition *)definition {
    AJRSyntaxTextStorage *textStorage = [[AJRSyntaxTextStorage alloc] initWithSyntaxDefinition:definition];
    
    if (textStorage) {
        NSString *string = [self string];
        [[self layoutManager] replaceTextStorage:textStorage];
        [self setString:string];
    }
}

@end
