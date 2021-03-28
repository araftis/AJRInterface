
#import <Cocoa/Cocoa.h>

@class EKCalendarItem, AJRCalendarItemInspectorController;

@interface AJRCalendarItemInspector : NSObject 
{
    __weak AJRCalendarItemInspectorController    *_owner;
    NSView                                      *_view;
    NSObjectController                          *_itemController;
}

- (id)initWithOwner:(AJRCalendarItemInspectorController *)owner;

@property (nonatomic,readonly,weak) AJRCalendarItemInspectorController *owner;
@property (nonatomic,strong) IBOutlet NSView *view;
@property (nonatomic,strong) IBOutlet NSObjectController *itemController;
@property (nonatomic,strong) EKCalendarItem *item;

/*!
 @methodgroup Actions
 */
- (void)dismiss:(id)sender;

/*!
 This method examines event and returns an integer who'd value depends on whether or not it should be the inspector for the event. The superclass implementation always returns 0. If you want to register an inspector and have it inspect an event, you should then return something from this method that return a value larger 0. Note that returning 0 means that you cannot inspect the event. System inspectors will return a value of 100.
 */
+ (NSUInteger)shouldInspectCalendarItem:(EKCalendarItem *)event;

/*!
 @methodgroup Observable values
 */
- (NSString *)title;
- (BOOL)isTitleEditable;
- (BOOL)editTitleOnFirstAppearance;
- (void)titleDidChange:(NSString *)title;

- (NSString *)rightButtonTitle;
- (NSString *)rightButtonKeyEquivalent;
- (BOOL)rightButtonEnabled;
- (id)rightButtonTarget;
- (SEL)rightButtonAction;
- (NSString *)middleButtonTitle;
- (NSString *)middleButtonKeyEquivalent;
- (BOOL)middleButtonEnabled;
- (id)middleButtonTarget;
- (SEL)middleButtonAction;
- (NSString *)leftButtonTitle;
- (NSString *)leftButtonKeyEquivalent;
- (BOOL)leftButtonEnabled;
- (id)leftButtonTarget;
- (SEL)leftButtonAction;

- (id)initialFirstResponder;

@end
