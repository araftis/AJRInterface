
#import <Cocoa/Cocoa.h>

#import <AJRFoundation/AJRFoundation.h>

@class AJRActivity;

extern NSColorName const AJRActivityActiveTextColor;
extern NSColorName const AJRActivityInactiveTextColor;
extern NSColorName const AJRActivitySecondaryActiveTextColor;
extern NSColorName const AJRActivitySecondaryInactiveTextColor;

@interface AJRActivityToolbarView : NSView <CALayerDelegate>

@property (nonatomic,strong) AJRActivity *currentActivity;
@property (nonatomic,strong) AJRActivityIdentifier activityIdentifier;

@property (nonatomic,strong) NSString *idleMessage;
@property (nonatomic,strong) NSAttributedString *attributedIdleMessage;
@property (nonatomic,strong) NSString *bylineMessage;
@property (nonatomic,strong) NSAttributedString *attributedBylineMessage;

@end
