/*!
 @header AJRSyntaxComponent.h

 @author A.J. Raftis
 @updated 3/20/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRSyntaxDefinition;

extern NSString *AJRSyntaxComponentStringType;
extern NSString *AJRSyntaxComponentNumberType;
extern NSString *AJRSyntaxComponentKeywordType;
extern NSString *AJRSyntaxComponentTagType;
extern NSString *AJRSyntaxComponentBlockCommentType;
extern NSString *AJRSyntaxComponentOneLineCommentType;
extern NSString *AJRSyntaxComponentTextType;

extern NSString *AJRSyntaxNameKey;
extern NSString *AJRSyntaxTypeKey;
extern NSString *AJRSyntaxColorKey;
extern NSString *AJRSyntaxBackgroundColorKey;
extern NSString *AJRSyntaxFontKey;
extern NSString *AJRSyntaxEndKey;
extern NSString *AJRSyntaxStartKey;
extern NSString *AJRSyntaxEscapeCharacterKey;
extern NSString *AJRSyntaxCharsetKey;
extern NSString *AJRSyntaxKeywordsKey;
extern NSString *AJRSyntaxIgnoreCommentsKey;
extern NSString *AJRSyntaxRecolorComponentsKey;

/*!
 @class AJRSyntaxComponent
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSyntaxComponent : NSObject 
{
    AJRSyntaxDefinition    *__weak _owner;
    NSString            *_name;
    NSString            *_type;
    NSColor                *_color;
    NSColor                *_backgroundColor;
    NSFont                *_font;
    NSString            *_end;
    NSString            *_start;
    NSString            *_escapeCharacter;
    NSCharacterSet        *_characterSet;
    NSString            *_rawCharacterSet;
    NSMutableSet        *_keywords;
    NSString            *_ignoreComponent;
    NSArray                *_recolorComponents;
    
    NSDictionary        *_attributes;
}

- (id)initWithProperties:(NSDictionary *)properties owner:(AJRSyntaxDefinition *)owner;

@property (readonly) AJRSyntaxDefinition *owner;
@property (strong) NSString *name;
@property (strong) NSString *type;
@property (strong) NSColor *color;
@property (strong) NSColor *backgroundColor;
@property (strong) NSFont *font;
@property (strong) NSString *end;
@property (strong) NSString *start;
@property (strong) NSString *escapeCharacter;
@property (strong) NSCharacterSet *characterSet;
@property (readonly) NSSet *keywords;
@property (strong) NSString *ignoreComponent;
@property (strong) NSArray *recolorComponents;

- (id)propertyList;

- (NSDictionary *)attributes;

@end
