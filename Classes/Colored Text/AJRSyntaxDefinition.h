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

extern NSString * const AJRSyntaxDefinitionDidChangeNotification;
extern NSString * const AJRSyntaxComponentKey;
extern NSString * const AJRSyntaxComponentChangeKey;
extern NSString * const AJRSyntaxActiveKey;

/*!
 @class AJRSyntaxDefinition
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSyntaxDefinition : NSObject 

+ (id)syntaxDefinitionForName:(NSString *)name;

- (id)initWithName:(NSString *)name error:(NSError **)error;

@property (readonly) NSString *name;
@property (readonly) NSArray<AJRSyntaxComponent *> *components;
@property (readonly) NSArray<NSString *> *fileExtensions;
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
