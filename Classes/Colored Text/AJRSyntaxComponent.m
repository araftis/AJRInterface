/*
 AJRSyntaxComponent.m
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

#import "AJRSyntaxComponent.h"

#import "AJRSyntaxDefinition.h"
#import "NSDictionary+Extensions.h"
#import "NSMutableDictionary+Extensions.h"
#import "NSUserDefaults+Extensions.h"

NSString * const AJRSyntaxComponentStringType = @"String";
NSString * const AJRSyntaxComponentNumberType = @"Number";
NSString * const AJRSyntaxComponentKeywordType = @"Keywords";
NSString * const AJRSyntaxComponentTagType = @"Tag";
NSString * const AJRSyntaxComponentBlockCommentType = @"BlockComment";
NSString * const AJRSyntaxComponentOneLineCommentType = @"OneLineComment";
NSString * const AJRSyntaxComponentTextType = @"Text";

NSString * const AJRSyntaxNameKey = @"name";
NSString * const AJRSyntaxTypeKey = @"type";
NSString * const AJRSyntaxColorKey = @"color";
NSString * const AJRSyntaxBackgroundColorKey = @"backgroundColor";
NSString * const AJRSyntaxFontKey = @"font";
NSString * const AJRSyntaxEndKey = @"end";
NSString * const AJRSyntaxStartKey = @"start";
NSString * const AJRSyntaxEscapeCharacterKey = @"escapeCharacter";
NSString * const AJRSyntaxCharsetKey = @"charset";
NSString * const AJRSyntaxKeywordsKey = @"keywords";
NSString * const AJRSyntaxIgnoreComponentKey = @"ignoreComponent";
NSString * const AJRSyntaxRecolorComponentsKey = @"recolorComponents";

@implementation AJRSyntaxComponent {
    NSString *_rawCharacterSet;

    NSDictionary *_attributes;
}

- (id)initWithProperties:(NSDictionary *)properties owner:(AJRSyntaxDefinition *)owner {
    if ((self = [super init])) {
        NSColor *defaultForegoundColor = [NSColor blackColor];
        NSColor *defaultBackgroundColor = nil;
        NSFont *defaultFont = nil;
        NSString *characterSet;
        
        self.type = [properties objectForKey:AJRSyntaxTypeKey];
        self.name = [properties objectForKey:AJRSyntaxNameKey];
        self.color = [properties colorForKey:AJRSyntaxColorKey defaultValue:defaultForegoundColor];
        self.backgroundColor = [properties colorForKey:AJRSyntaxBackgroundColorKey defaultValue:defaultBackgroundColor];
        self.font = [properties fontForKey:AJRSyntaxFontKey defaultValue:defaultFont];
        self.end = [properties objectForKey:AJRSyntaxEndKey];
        self.start = [properties objectForKey:AJRSyntaxStartKey];
        self.escapeCharacter = [properties objectForKey:AJRSyntaxEscapeCharacterKey];
        characterSet = [properties objectForKey:AJRSyntaxCharsetKey];
        if (characterSet) {
            _rawCharacterSet = characterSet;
            self.characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSet];
        }
        _keywords = [[NSMutableSet alloc] initWithArray:[properties objectForKey:AJRSyntaxKeywordsKey]];
        self.ignoreComponent = [properties objectForKey:AJRSyntaxIgnoreComponentKey];
        self.recolorComponents = [properties objectForKey:AJRSyntaxRecolorComponentsKey];

        _owner = owner;
    }
    return self;
}

- (void)setName:(NSString *)value {
    if (_name != value) {
        _name = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxNameKey];
    }
}

- (void)setType:(NSString *)value {
    if (_type != value) {
        _type = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxTypeKey];
    }
}

@synthesize color = _color;

- (NSColor *)color {
    if (_color == nil && ![_type isEqualToString:AJRSyntaxComponentTextType]) {
        return [_owner textColor];
    }
    return _color;
}

- (void)setColor:(NSColor *)value {
    if (_color != value) {
        _color = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxColorKey];
    }
}

@synthesize backgroundColor = _backgroundColor;

- (NSColor *)backgroundColor {
    if (_backgroundColor == nil && ![_type isEqualToString:AJRSyntaxComponentTextType]) {
        return [_owner textBackgroundColor];
    }
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)value {
    if (_backgroundColor != value) {
        _backgroundColor = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxBackgroundColorKey];
    }
}

@synthesize font = _font;

- (NSFont *)font {
    if (_font == nil && ![_type isEqualToString:AJRSyntaxComponentTextType]) {
        return [_owner textFont];
    }
    return _font;
}

- (void)setFont:(NSFont *)value {
    if (_font != value) {
        _font = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxFontKey];
    }
}

- (void)setEnd:(NSString *)value {
    if (_end != value) {
        _end = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxEndKey];
    }
}

- (void)setStart:(NSString *)value {
    if (_start != value) {
        _start = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxStartKey];
    }
}

- (void)setEscapeCharacter:(NSString *)value {
    if (_escapeCharacter != value) {
        _escapeCharacter = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxEscapeCharacterKey];
    }
}

- (void)setCharacterSet:(NSCharacterSet *)value {
    if (_characterSet != value) {
        _characterSet = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxCharsetKey];
    }
}

- (void)setKeywords:(NSMutableSet *)value {
    if (_keywords != value) {
        _keywords = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxKeywordsKey];
    }
}

- (void)setIgnoreComponent:(NSString *)value {
    if (_ignoreComponent != value) {
        _ignoreComponent = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxIgnoreComponentKey];
    }
}

- (id)propertyList {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    if (_name) [properties setObject:_name forKey:AJRSyntaxNameKey];
    if (_type) [properties setObject:_type forKey:AJRSyntaxTypeKey];
    if (_color) [properties setColor:_color forKey:AJRSyntaxColorKey];
    if (_backgroundColor) [properties setColor:_backgroundColor forKey:AJRSyntaxBackgroundColorKey];
    if (_font) [properties setFont:_font forKey:AJRSyntaxFontKey];
    if (_end) [properties setObject:_end forKey:AJRSyntaxEndKey];
    if (_start) [properties setObject:_start forKey:AJRSyntaxStartKey];
    if (_escapeCharacter) [properties setObject:_escapeCharacter forKey:AJRSyntaxEscapeCharacterKey];
    if (_rawCharacterSet) [properties setObject:_rawCharacterSet forKey:AJRSyntaxCharsetKey];
    if ([_keywords count]) [properties setObject:[_keywords allObjects] forKey:AJRSyntaxKeywordsKey];
    if (_ignoreComponent) [properties setObject:_ignoreComponent forKey:AJRSyntaxIgnoreComponentKey];
    if (_recolorComponents) [properties setObject:_recolorComponents forKey:AJRSyntaxRecolorComponentsKey];

    return properties;
}

- (NSDictionary *)attributes {
    if (_attributes == nil) {
        _attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                       _color ? _color : [_owner textColor], NSForegroundColorAttributeName,
                       _backgroundColor ? _backgroundColor : [_owner textBackgroundColor], NSBackgroundColorAttributeName,
                       _font ? _font : [_owner textFont], NSFontAttributeName,
                       nil];
    }
    return _attributes;
}

@end
