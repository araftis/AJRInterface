//
//  AJRCalendarDateChooser.h
//  AJRInterface
//
//  Created by A.J. Raftis on 2/24/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRCalendarDateChooser : NSObject
{
    // Sheet callbacks
    id _modalDelegate;
    SEL _didEndSelector;
    void *_contextInfo;
}

@property (nonatomic,strong) IBOutlet NSPanel *panel;
@property (nonatomic,strong) IBOutlet NSDatePicker *datePicker;
@property (nonatomic,strong) IBOutlet NSButton *cancelButton;
@property (nonatomic,strong) IBOutlet NSButton *showButton;
@property (nonatomic,strong) IBOutlet NSTextField *label;
@property (nonatomic,strong) NSDate *date;

/*!
 @methodgroup Running
 */

/*!
 Display the date chooser as a sheet of window. Once the user has made a selection, didEndSelector will be called on modalDelegate and passed the return code and supplied contextInfo. didEndSelector should take the form of:
 
 <pre>- (void)dateChooserDidEnd:(AJRCalendarDateChooser *)chooser returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;</pre>

 @param date The initial date displayed in the date chooser.
 @param docWindow The window to which the sheet will be attached.
 @param modalDelegate The delegate to call when the sheet is finished.
 @param didEndSelector The selector to call on modelDelegate.
 @param contextInfo Arbitrary data passed to the delegate. Note that the chooser does not own this data, therefore the caller if responsible for allocating and freeing the contextInfo.
 */

- (void)beginDateChooserForDate:(NSDate *)date modalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo;

/*!
 Display the date chooser as a sheet of window. Once the user has made a selection, didEndSelector will be called on modalDelegate and passed the return code and supplied contextInfo. didEndSelector should take the form of:
 
 <pre>- (void)dateChooserDidEnd:(AJRCalendarDateChooser *)chooser returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;</pre>
 
 @param docWindow The window to which the sheet will be attached.
 @param modalDelegate The delegate to call when the sheet is finished.
 @param didEndSelector The selector to call on modelDelegate.
 @param contextInfo Arbitrary data passed to the delegate. Note that the chooser does not own this data, therefore the caller if responsible for allocating and freeing the contextInfo.
 */
- (void)beginDateChooserModalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo;

/*!
 @methodgroup Actions
 */

/*!
 Called in response to the show button being pushed. Ends the modal session with a NSModalResponseOK.
 */
- (IBAction)show:(id)sender;
/*!
 Called in response to the cancel button being pushed. Ends the modal session with a NSModalResponseCancel.
 */
- (IBAction)cancel:(id)sender;

@end


@interface _AJRCalendarDateChooserPanel : NSPanel
{
    AJRCalendarDateChooser    *_chooser;
}

@property (nonatomic,strong) IBOutlet AJRCalendarDateChooser *chooser;

@end

