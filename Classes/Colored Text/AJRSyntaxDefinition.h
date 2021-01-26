/*!
 @header AJRSyntaxDefinition.h

 @author A.J. Raftis
 @updated 3/20/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRSyntaxComponent;

extern NSString *AJRSyntaxDefinitionDidChangeNotification;
extern NSString *AJRSyntaxComponentKey;
extern NSString *AJRSyntaxComponentChangeKey;
extern NSString *AJRSyntaxActiveKey;

/*!
 @class AJRSyntaxDefinition
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSyntaxDefinition : NSObject 
{
    NSString                *_name;
    NSMutableArray            *_components;
    NSMutableDictionary        *_componentIndex;
    NSMutableArray            *_fileExtensions;
    BOOL                    _active;
}

+ (id)syntaxDefinitionForName:(NSString *)name;

- (id)initWithName:(NSString *)name error:(NSError **)error;

@property (readonly) NSString *name;
@property (readonly) NSArray *components;
@property (readonly) NSArray *fileExtensions;
@property (strong) NSColor *textColor;
@property (strong) NSColor *textBackgroundColor;
@property (strong) NSFont *textFont;
@property (assign,getter=isActive) BOOL active;

- (void)resetToDefaults;
- (BOOL)writeToPath:(NSString *)path error:(NSError **)error;
- (void)saveToDefaultsWithError:(NSError **)error;

- (AJRSyntaxComponent *)componentForName:(NSString *)name;
   
- (void)componentDidChange:(AJRSyntaxComponent *)component key:(NSString *)key;

@end
