
#import <AppKit/AppKit.h>

@interface AJRPreferencesModule : NSViewController

- (id)init;

@property (nonatomic,strong) NSImage *image;

- (NSString *)name;
- (NSString *)toolTip;
- (BOOL)isPreferred;

- (void)update;

@end

