//
//  NSBundle+Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 5/9/14.
//

@interface NSBundle (AJRInterfaceExtensions)

+ (BOOL)ajr_loadNibNamed:(NSString *)name owner:(id)owner;
+ (BOOL)ajr_loadNibNamed:(NSString *)name owner:(id)owner topLevelObjects:(NSArray **)array;

@end
