
@interface NSBundle (AJRInterfaceExtensions)

+ (BOOL)ajr_loadNibNamed:(NSString *)name owner:(id)owner;
+ (BOOL)ajr_loadNibNamed:(NSString *)name owner:(id)owner topLevelObjects:(NSArray **)array;

@end
