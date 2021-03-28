
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

@class AJRActivityToolbarProgressLayer, AJRTextLayer;

@interface AJRActivityToolbarViewLayer : CALayer

#pragma mark - Properties

@property (nonatomic,strong) AJRTextLayer *messageLayer;
@property (nonatomic,strong) AJRTextLayer *bylineLayer;
@property (nonatomic,strong) AJRActivityToolbarProgressLayer *progressLayer;

@property (nonatomic,strong) NSAttributedString *attributedIdleMessage;

#pragma mark - Display

@property (nonatomic,strong) NSString *idleMessage;
- (void)setMessage:(NSString *)message;
- (void)setAttributedMessage:(NSAttributedString *)message;

@property (nonatomic,strong) NSString *bylineMessage;
@property (nonatomic,strong) NSAttributedString *attributedBylineMessage;

- (void)setProgressMinimum:(double)progressMinimum;
- (void)setProgressMaximum:(double)progressMaximum;
- (void)setProgress:(double)progress;
- (void)setIndeterminate:(BOOL)flag;
- (void)showProgress;
- (void)hideProgress;

#pragma mark - Display Properties

+ (NSShadow *)bottomHighlightShadow;
+ (NSShadow *)innerGlowShadow;
+ (NSGradient *)outerBezelGradient;
+ (NSGradient *)innerBezelGradient;
+ (NSGradient *)backgroundGradient;

@end
