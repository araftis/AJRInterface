//
//  AJRSyntaxComponent.m
//  AJRInterface
//
//  Created by A.J. Raftis on 3/20/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRSyntaxComponent.h"

#import "AJRSyntaxDefinition.h"
#import "NSDictionary+Extensions.h"
#import "NSMutableDictionary+Extensions.h"
#import "NSUserDefaults+Extensions.h"

NSString *AJRSyntaxComponentStringType = @"String";
NSString *AJRSyntaxComponentNumberType = @"Number";
NSString *AJRSyntaxComponentKeywordType = @"Keywords";
NSString *AJRSyntaxComponentTagType = @"Tag";
NSString *AJRSyntaxComponentBlockCommentType = @"BlockComment";
NSString *AJRSyntaxComponentOneLineCommentType = @"OneLineComment";
NSString *AJRSyntaxComponentTextType = @"Text";

NSString *AJRSyntaxNameKey = @"name";
NSString *AJRSyntaxTypeKey = @"type";
NSString *AJRSyntaxColorKey = @"color";
NSString *AJRSyntaxBackgroundColorKey = @"backgroundColor";
NSString *AJRSyntaxFontKey = @"font";
NSString *AJRSyntaxEndKey = @"end";
NSString *AJRSyntaxStartKey = @"start";
NSString *AJRSyntaxEscapeCharacterKey = @"escapeCharacter";
NSString *AJRSyntaxCharsetKey = @"charset";
NSString *AJRSyntaxKeywordsKey = @"keywords";
NSString *AJRSyntaxIgnoreComponentKey = @"ignoreComponent";
NSString *AJRSyntaxRecolorComponentsKey = @"recolorComponents";

@implementation AJRSyntaxComponent

- (id)initWithProperties:(NSDictionary *)properties owner:(AJRSyntaxDefinition *)owner
{
    if ((self = [super init])) {
        NSColor        *defaultForegoundColor = [NSColor blackColor];
        NSColor        *defaultBackgroundColor = nil;
        NSFont        *defaultFont = nil;
        NSString    *characterSet;
        
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


@synthesize color = _color;
@synthesize backgroundColor = _backgroundColor;
@synthesize font = _font;
@synthesize keywords = _keywords;
@synthesize recolorComponents = _recolorComponents;

- (AJRSyntaxDefinition *)owner
{
    return _owner;
}

- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)value
{
    if (_name != value) {
        _name = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxNameKey];
    }
}

- (NSString *)type
{
    return _type;
}

- (void)setType:(NSString *)value
{
    if (_type != value) {
        _type = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxTypeKey];
    }
}

- (NSColor *)color
{
    if (_color == nil && ![_type isEqualToString:AJRSyntaxComponentTextType]) {
        return [_owner textColor];
    }
    return _color;
}

- (void)setColor:(NSColor *)value
{
    if (_color != value) {
        _color = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxColorKey];
    }
}

- (NSColor *)backgroundColor
{
    if (_backgroundColor == nil && ![_type isEqualToString:AJRSyntaxComponentTextType]) {
        return [_owner textBackgroundColor];
    }
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (_backgroundColor != value) {
        _backgroundColor = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxBackgroundColorKey];
    }
}

- (NSFont *)font
{
    if (_font == nil && ![_type isEqualToString:AJRSyntaxComponentTextType]) {
        return [_owner textFont];
    }
    return _font;
}

- (void)setFont:(NSFont *)value
{
    if (_font != value) {
        _font = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxFontKey];
    }
}

- (NSString *)end
{
    return _end;
}

- (void)setEnd:(NSString *)value
{
    if (_end != value) {
        _end = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxEndKey];
    }
}

- (NSString *)start
{
    return _start;
}

- (void)setStart:(NSString *)value
{
    if (_start != value) {
        _start = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxStartKey];
    }
}

- (NSString *)escapeCharacter
{
    return _escapeCharacter;
}

- (void)setEscapeCharacter:(NSString *)value
{
    if (_escapeCharacter != value) {
        _escapeCharacter = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxEscapeCharacterKey];
    }
}

- (NSCharacterSet *)characterSet
{
    return _characterSet;
}

- (void)setCharacterSet:(NSCharacterSet *)value
{
    if (_characterSet != value) {
        _characterSet = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxCharsetKey];
    }
}

- (void)setKeywords:(NSMutableSet *)value
{
    if (_keywords != value) {
        _keywords = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxKeywordsKey];
    }
}

- (NSString *)ignoreComponent
{
    return _ignoreComponent;
}

- (void)setIgnoreComponent:(NSString *)value
{
    if (_ignoreComponent != value) {
        _ignoreComponent = [value copy];
        [_owner componentDidChange:self key:AJRSyntaxIgnoreComponentKey];
    }
}

- (id)propertyList
{
    NSMutableDictionary    *properties = [NSMutableDictionary dictionary];
    
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

- (NSDictionary *)attributes
{
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
