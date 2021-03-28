
#import <Cocoa/Cocoa.h>

@class EKCalendarItem, AJRCalendarItemInspector, AJRCalendarItemInspectorWindow, AJRCalendarView;

@interface AJRCalendarItemInspectorController : NSObject <NSWindowDelegate>
{
    AJRCalendarView                    *__weak _owner;
    NSWindow                        *_parentWindow;
    AJRCalendarItemInspectorWindow    *_window;
    AJRCalendarItemInspector            *_inspector;
    NSMutableDictionary                *_inspectors;
}

+ (void)registerInspector:(Class)inspectorClass;
+ (Class)inspectorClassForCalendarItem:(EKCalendarItem *)item;

- (id)initWithOwner:(AJRCalendarView *)calendarView;

@property (nonatomic,strong) NSWindow *parentWindow;
@property (nonatomic,readonly) AJRCalendarItemInspectorWindow *window;
@property (nonatomic,readonly) AJRCalendarView *owner;
@property (nonatomic,readonly) AJRCalendarItemInspector *inspector;

- (IBAction)dismiss:(id)sender;
- (void)inspectItem:(EKCalendarItem *)item inRect:(NSRect)rect;

@end
