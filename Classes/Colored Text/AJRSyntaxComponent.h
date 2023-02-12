/*
 AJRSyntaxComponent.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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
