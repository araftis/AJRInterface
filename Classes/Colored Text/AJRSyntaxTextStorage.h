/*!
 @header AJRSyntaxTextStorage.h

 @author A.J. Raftis
 @updated 3/20/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRSyntaxComponent, AJRSyntaxDefinition;

extern NSString *AJRUserDefinedIdentifiers;                // Key in user defaults holding user-defined identifiers to colorize.
extern NSString *AJRSyntaxColoringModeAtttributeName;    // Anything we colorize gets this attribute.

/*!
 @class AJRSyntaxTextStorage
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSyntaxTextStorage : NSTextStorage 
{
    NSMutableAttributedString    *_string;
    AJRSyntaxDefinition            *_syntaxDefinition;
    BOOL                        _syntaxColoringEnabled;
}

- (id)initWithSyntaxDefinition:(AJRSyntaxDefinition *)definition;
- (id)initWithSyntaxDefinitionNamed:(NSString *)name;

@property (nonatomic,assign) BOOL syntaxColoringEnabled;

- (NSTextView *)textView;

- (NSString *)string;
- (NSMutableString *)mutableString;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range;
- (void)replaceCharactersInRange:(NSRange)aRange withAttributedString:(NSAttributedString *)attributedString;
- (void)setAttributes:(NSDictionary *)dictionary range:(NSRange)range;

- (BOOL)colorComments:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr;
- (BOOL)colorOneLineComment:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr;
- (BOOL)colorNumbers:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr;
- (BOOL)colorStrings:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr;
- (BOOL)colorTags:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr;
- (BOOL)colorKeywords:(AJRSyntaxComponent *)component inRange:(NSRange)range andMode:(NSString *)attr;

@end


@interface NSTextView (AJRSyntaxText)

- (void)setSyntaxDefinition:(AJRSyntaxDefinition *)syntaxDefinition;

@end
