
#import <Cocoa/Cocoa.h>

@interface AJRPopUpTextFieldCell : NSTextFieldCell

@property (strong) IBOutlet NSMenu *menu;

@property (nonatomic,strong) NSGradient *activeGradient;
@property (nonatomic,strong) NSGradient *inactiveGradient;
@property (nonatomic,strong) NSGradient *disabledGradient;

- (void)viewDidChangeEffectiveAppearance;

@end
