//
//  AJRSyntaxDefinition.m
//  AJRInterface
//
//  Created by A.J. Raftis on 3/20/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "AJRSyntaxDefinition.h"

#import "AJRSyntaxComponent.h"
#import "NSDictionary+Extensions.h"

#import    <AJRFoundation/AJRFoundation.h>

NSString *AJRSyntaxDefinitionDidChangeNotification = @"AJRSyntaxDefinitionDidChangeNotification";
NSString *AJRSyntaxComponentKey = @"component";
NSString *AJRSyntaxComponentChangeKey = @"key";
NSString *AJRSyntaxActiveKey = @"active";

static NSMutableDictionary    *_syntaxDefinitions = nil;

@interface AJRSyntaxDefinition ()

- (id)initWithPath:(NSString *)path error:(NSError **)error;
- (id)initWithName:(NSString *)name dictionary:(NSDictionary *)dictionary error:(NSError **)error;

@end

@implementation AJRSyntaxDefinition

+ (void)initialize
{
    if (_syntaxDefinitions == nil) {
        _syntaxDefinitions = [[NSMutableDictionary alloc] init];
    }
}

+ (NSString *)defaultsKeyForName:(NSString *)name
{
    return AJRFormat(@"AJRSyntaxDefinition:%@", name);
}

+ (id)findPathForSyntaxDefinitionWithName:(NSString *)name
{
    NSString    *path;
    
    path = [[NSBundle mainBundle] pathForResource:name ofType:@"syntax"];

    if (path == nil) {
        for (NSBundle *bundle in [NSBundle allFrameworks]) {
            path = [bundle pathForResource:name ofType:@"syntax"];
            if (path) return path;
        }
        for (NSBundle *bundle in [NSBundle allBundles]) {
            path = [bundle pathForResource:name ofType:@"syntax"];
            if (path) return path;
        }
    }
    
    return path;
}

+ (id)findSyntaxDefinitionWithName:(NSString *)name
{
    AJRSyntaxDefinition    *definition = nil;
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:[self defaultsKeyForName:name]]) {
        // We seem to have a definition in defaults, so let's try to load that.
        definition = [[self alloc] initWithName:name error:NULL];
    }
    
    if (definition == nil) {
        NSString    *path = [self findPathForSyntaxDefinitionWithName:name];
        
        if (path) {
            definition = [[AJRSyntaxDefinition alloc] initWithPath:path error:NULL];
        }
    }
    
    return definition;
}

+ (id)syntaxDefinitionForName:(NSString *)name
{
    AJRSyntaxDefinition    *definition = [_syntaxDefinitions objectForKey:name];
    
    if (definition == nil) {
        definition = [self findSyntaxDefinitionWithName:name];
        if (definition != nil) {
            [_syntaxDefinitions setObject:definition forKey:name];
        }
    }
    
    return definition;
}

- (id)initWithName:(NSString *)name error:(NSError **)error
{
    NSString                *path;
    AJRSyntaxDefinition        *definition;
    
    // Must be retained, because we'll return it if it exists, at which point objects returned from init methods are retained.
    definition = [_syntaxDefinitions objectForKey:name];
    
    if (definition == nil) {
        NSString        *defaultsKey = [[self class] defaultsKeyForName:name];
        NSDictionary    *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultsKey];
        
        // Try to find the settings in the user defaults first.
        if (dictionary) {
            return [self initWithName:name dictionary:dictionary error:error];
        }
        
        // If the don't exists there, try to find them in one of the application's bundles.
        path = [[self class] findPathForSyntaxDefinitionWithName:name];
        if (error) *error = nil;
        if (path == nil) {
            if (error) {
                *error = [NSError errorWithDomain:@"AJRInterface" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:AJRFormat(@"Unable to find syntax definition named %@", name), NSLocalizedDescriptionKey, nil]];
                return nil;
            }
        }

        // And if we found a path, try to create from the path.
        self = [self initWithPath:path error:error];
        if (self == nil) {
            return nil;
        }
        
        [_syntaxDefinitions setObject:self forKey:name];
    } else {
        return definition;
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path error:(NSError **)error
{
    NSData                *rawDictionary;
    NSDictionary        *dictionary;
    NSError                *localError;
    NSString            *name;
    AJRSyntaxDefinition    *definition;

    NSAssert(path != nil, @"path parameter to -[AJRSyntaxDefinition initWithPath:error:] may not be nil");
    
    if (error) *error = nil;
    
    // See if we've already loaded this definition, since we're singleton by name.
    name = [[path lastPathComponent] stringByDeletingPathExtension];
    definition = [_syntaxDefinitions objectForKey:name];
    if (definition) {
        // Throw on an extra retain, since people calling init expect it.
        return definition;
    }

    // OK, we don't already exist, so let's try to get the raw dictionary from disk.
    rawDictionary = [[NSData alloc] initWithContentsOfFile:path options:0 error:error];
    if (!rawDictionary) {
        return nil;
    }
    
    dictionary = [NSPropertyListSerialization propertyListWithData:rawDictionary options:NSPropertyListImmutable format:NULL error:&localError];
    if (dictionary == nil) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    
    return [self initWithName:name dictionary:dictionary error:error];
}

- (void)_initComponents:(NSArray *)components
{
    if (components) {
        for (NSDictionary *raw in components) {
            NSString            *name = [raw objectForKey:AJRSyntaxNameKey];
            AJRSyntaxComponent    *component;
            
            component = [_componentIndex objectForKey:name];
            if (component) {
                [component ajr_performSelector:@selector(initWithProperties:owner:) withObject:raw withObject:self];
            } else {
                component = [[AJRSyntaxComponent alloc] initWithProperties:raw owner:self];
                if (component) {
                    [_components addObject:component];
                    [_componentIndex setObject:component forKey:[component name]];
                }
            }
        }
    }
}

- (id)initWithName:(NSString *)name dictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    if ((self = [self init])) {
        
        _name = name;
        _components    = [[NSMutableArray alloc] init];
        _componentIndex = [[NSMutableDictionary alloc] init];
        [self _initComponents:[dictionary objectForKey:@"components"]];
        
        _fileExtensions = [[dictionary objectForKey:@"fileNameSuffixes"] mutableCopy];
        _active = [dictionary boolForKey:AJRSyntaxActiveKey defaultValue:YES];
    }
    return self;
}

@synthesize name = _name;
@synthesize components = _components;
@synthesize fileExtensions = _fileExtensions;

- (NSColor *)textColor
{
    NSColor        *color = [[_componentIndex objectForKey:@"Text"] color];
    
    return color ? color : [NSColor textColor];
}

- (void)setTextColor:(NSColor *)color
{
    [[_componentIndex objectForKey:@"Text"] setColor:color];
}

- (NSColor *)textBackgroundColor
{
    NSColor        *color = [[_componentIndex objectForKey:@"Text"] backgroundColor];
    
    return color ? color : [NSColor textBackgroundColor];
}

- (void)setTextBackgroundColor:(NSColor *)color
{
    [[_componentIndex objectForKey:@"Text"] setBackgroundColor:color];
}

- (NSFont *)textFont
{
    NSFont        *font = [[_componentIndex objectForKey:@"Text"] font];
    
    return font ? font : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSize]];
}

- (void)setTextFont:(NSFont *)font
{
    [[_componentIndex objectForKey:@"Text"] setFont:font];
}

- (BOOL)isActive
{
    return _active;
}

- (void)setActive:(BOOL)flag
{
    if (_active != flag) {
        _active = flag;
        [self componentDidChange:nil key:AJRSyntaxActiveKey];
    }
}

- (void)resetToDefaults
{
    NSString    *path = [[self class] findPathForSyntaxDefinitionWithName:_name];
    
    if (path) {
        NSDictionary    *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        if (dictionary) {
            [self _initComponents:[dictionary objectForKey:@"components"]];
            [self componentDidChange:nil key:nil];
        }
    }
}

- (NSDictionary *)propertyList
{
    NSMutableDictionary    *output = [[NSMutableDictionary alloc] init];
    NSMutableArray        *components = [[NSMutableArray alloc] init];
    
    [output setObject:components forKey:@"components"];
    for (AJRSyntaxComponent *component in _components) {
        NSDictionary    *raw = [component propertyList];
        if (raw) {
            [components addObject:raw];
        }
    }
    if (_fileExtensions) {
        [output setObject:_fileExtensions forKey:@"fileNameSuffixes"];
    }
    [output setObject:_active ? @"YES" : @"NO" forKey:AJRSyntaxActiveKey];
    
    return output;
}

- (BOOL)writeToPath:(NSString *)path error:(NSError **)error
{
    return [[[self propertyList] description] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
}

- (void)saveToDefaultsWithError:(NSError **)error
{
    [[NSUserDefaults standardUserDefaults] setObject:[self propertyList] forKey:[[self class] defaultsKeyForName:_name]];
}

- (AJRSyntaxComponent *)componentForName:(NSString *)name
{
    return [_componentIndex objectForKey:name];
}

- (void)componentDidChange:(AJRSyntaxComponent *)component key:(NSString *)key
{
    NSMutableDictionary    *info = [[NSMutableDictionary alloc] init];
    if (component) {
        [info setObject:component forKey:AJRSyntaxComponentKey];
    }
    if (key) {
        [info setObject:key forKey:AJRSyntaxComponentChangeKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRSyntaxDefinitionDidChangeNotification object:self userInfo:info];
}

@end
