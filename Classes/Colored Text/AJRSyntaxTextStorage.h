/*
 AJRSyntaxTextStorage.h
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

/// Key in user defaults holding user-defined identifiers to colorize.
extern NSString * const AJRUserDefinedIdentifiers;
/// Anything we colorize gets this attribute.
extern NSString * const AJRSyntaxColoringModeAtttributeName;

/*!
 @class AJRSyntaxTextStorage
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSyntaxTextStorage : NSTextStorage 

- (id)initWithSyntaxDefinition:(AJRSyntaxDefinition *)definition;
- (id)initWithSyntaxDefinitionNamed:(NSString *)name;

@property (nonatomic,readonly) AJRSyntaxDefinition *syntaxDefinition;
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
