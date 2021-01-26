
#import <AppKit/AppKit.h>

@interface AJRPreferences : NSObject <NSToolbarDelegate, NSWindowDelegate>

+ (id)sharedInstance;

@property (nonatomic,strong) IBOutlet NSPanel *panel;
@property (nonatomic,strong) IBOutlet NSView *allView;
@property (nonatomic,strong) IBOutlet NSMatrix *moduleMatrix;
@property (nonatomic,assign) BOOL displayNeedsRefresh;

- (void)run;
- (void)runWithModuleNamed:(NSString *)aPanelName;
- (NSPanel *)panel;

- (IBAction)selectModule:(id)sender;
- (void)selectModuleNamed:(NSString *)name;

@end


@interface NSResponder (AJRPreferences)

- (IBAction)runPreferencesPanel:(id)sender;

@end
