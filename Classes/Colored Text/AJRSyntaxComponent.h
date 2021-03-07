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

extern NSString * const AJRSyntaxComponentStringType;
extern NSString * const AJRSyntaxComponentNumberType;
extern NSString * const AJRSyntaxComponentKeywordType;
extern NSString * const AJRSyntaxComponentTagType;
extern NSString * const AJRSyntaxComponentBlockCommentType;
extern NSString * const AJRSyntaxComponentOneLineCommentType;
extern NSString * const AJRSyntaxComponentTextType;

extern NSString * const AJRSyntaxNameKey;
extern NSString * const AJRSyntaxTypeKey;
extern NSString * const AJRSyntaxColorKey;
extern NSString * const AJRSyntaxBackgroundColorKey;
extern NSString * const AJRSyntaxFontKey;
extern NSString * const AJRSyntaxEndKey;
extern NSString * const AJRSyntaxStartKey;
extern NSString * const AJRSyntaxEscapeCharacterKey;
extern NSString * const AJRSyntaxCharsetKey;
extern NSString * const AJRSyntaxKeywordsKey;
extern NSString * const AJRSyntaxIgnoreCommentsKey;
extern NSString * const AJRSyntaxRecolorComponentsKey;

/*!
 @class AJRSyntaxComponent
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSyntaxComponent : NSObject 

- (id)initWithProperties:(NSDictionary *)properties owner:(AJRSyntaxDefinition *)owner;

@property (nonatomic,readonly,weak) AJRSyntaxDefinition *owner;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSColor *color;
@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSFont *font;
@property (nonatomic,strong) NSString *end;
@property (nonatomic,strong) NSString *start;
@property (nonatomic,strong) NSString *escapeCharacter;
@property (nonatomic,strong) NSCharacterSet *characterSet;
@property (nonatomic,readonly) NSSet *keywords;
@property (nonatomic,strong) NSString *ignoreComponent;
@property (nonatomic,strong) NSArray *recolorComponents;

- (id)propertyList;

@property (nonatomic,readonly) NSDictionary *attributes;

@end
