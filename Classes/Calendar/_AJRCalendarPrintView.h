
#import <Cocoa/Cocoa.h>

@class AJRCalendarRenderer;

@interface _AJRCalendarPrintView : NSView 
{
    AJRCalendarRenderer    *_renderer;
}

- (id)initWithRenderer:(AJRCalendarRenderer *)renderer;

@end
