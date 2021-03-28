
#import <AppKit/AppKit.h>

@class AJRActivity;

@interface AJRSourceIconCell : NSTextFieldCell {
    // NOTE: If adding instance variables, make sure to modify copyWithZone:
    NSMutableDictionary *_selectedTextAttributes;
    NSMutableDictionary *_categoryTextAttributes;
    NSMutableDictionary *_badgeAttributes;
    NSMutableDictionary *_badgeHighlightedAttributes;
    
    NSImage *_icon;
    NSImage *_alternateIcon;
    NSString *_badge;
    
    id __unsafe_unretained _iconTarget;
    SEL _iconAction;
    BOOL _iconTracking;
    BOOL _inIcon;
    NSRect _cellFrame;
    
    AJRActivity *_activity;
}

@property (nonatomic,strong) NSImage *icon;
@property (nonatomic,strong) NSImage *alternateIcon;
@property (nonatomic,strong) NSString *badge;
@property (nonatomic,unsafe_unretained) id iconTarget;
@property (nonatomic,assign) SEL iconAction;
@property (nonatomic,strong) AJRActivity *activity;

@end
