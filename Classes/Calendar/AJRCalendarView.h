/*
 AJRCalendarView.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <AJRInterface/AJRCalendarEvent.h>

typedef enum _ajrCalendarDisplayMode {
    AJRCalendarDisplayCustom = 0,
    AJRCalendarDisplayDay = 1,
    AJRCalendarDisplayWeek = 2,
    AJRCalendarDisplayMonth = 3,
    AJRCalendarDisplayQuarter = 4,
    AJRCalendarDisplayYear = 5
} AJRCalendarDisplayMode;

extern NSString *AJRCalendarViewWillChangeSelectionNotification;
extern NSString *AJRCalendarViewDidChangeSelectionNotification;

extern NSString *AJRCalendarViewWillSelectEventNotification;
extern NSString *AJRCalendarViewDidSelectEventNotification;
extern NSString *AJRCalendarViewEventKey;

extern NSString *AJRCalendarViewWillInspectEventNotification;
extern NSString *AJRCalendarViewDidInspectEventNotification;

extern NSString *AJRCalendarViewWillChangeDateNotification;
extern NSString *AJRCalendarViewDidChangeDateNotification;
extern NSString *AJRCalendarViewDateKey;

extern NSString *AJRCalendarViewWillChangeRendererNotification;
extern NSString *AJRCalendarViewDidChangeRendererNotification;
extern NSString *AJRCalendarViewRendererKey;

extern NSString *AJRCalendarViewWillDeleteEventsNotification;
extern NSString *AJRCalendarViewDidDeleteEventsNotification;
extern NSString *AJRCalendarViewEventsKey;

@class AJRCalendarView, AJRCalendarItemInspectorController, AJRCalendarRenderer, EKCalendar, EKEvent, EKEventStore;


@protocol AJRCalendarViewDelegate <NSObject>

@optional
- (BOOL)calendarViewWillChangeSelection:(AJRCalendarView *)calendarView;
- (void)calendarViewDidChangeSelection:(NSNotification *)notification;
- (BOOL)calendarView:(AJRCalendarView *)calendarView willChangeDate:(NSDate *)date;
- (void)calendarViewDidChangeDate:(NSNotification *)notification;
- (BOOL)calendarView:(AJRCalendarView *)calendarView willSelectEvent:(EKEvent *)event;
- (void)calendarViewDidSelectEvent:(NSNotification *)notification;
- (BOOL)calendarView:(AJRCalendarView *)calendarView willInspectEvent:(EKEvent *)event;
- (void)calendarViewDidInspectEvent:(NSNotification *)notification;
- (BOOL)calendarView:(AJRCalendarView *)calendarView willChangeRenderer:(AJRCalendarRenderer *)renderer;
- (void)calendarViewDidChangeRenderer:(NSNotification *)notification;
- (BOOL)calendarView:(AJRCalendarView *)calendarView willDeleteEvents:(NSArray *)events;
- (void)calendarView:(AJRCalendarView *)calendarView didDeleteEvents:(NSArray *)events;
- (NSArray *)calendarViewNeedsInitialCalendars:(AJRCalendarView *)calendarView;
- (NSMenu *)calendarView:(AJRCalendarView *)calendarView wantsMenuForCalendarEvent:(EKEvent *)event;

@end


@interface AJRCalendarView : NSView
{
    // Display properties
    NSColor                    *_backgroundColor;
    NSColor                    *_selectedBackgroundColor;
    NSColor                    *_todayBackgroundColor;
    NSColor                    *_gridColor;
    NSFont                    *_font;
    NSColor                    *_fontColor;
    NSColor                    *_dimmedFontColor;
    NSColor                    *_selectedFontColor;
    NSColor                    *_selectedDimmedFontColor;
    NSColor                    *_timeIndicatorColor;
    
    // IB Outlets
    NSControl                *_managedControl;
    
    // Calendars
    NSMutableArray            *_calendars;
    NSMutableArray            *_temporaryEvents;
    
    // Work day
    NSUInteger                _firstMinuteOfWorkHours;
    NSUInteger                _lastMinuteOfWorkHours;
    
    // Selection
    NSMutableDictionary        *_selection;
    
    // Inspection
    AJRCalendarItemInspectorController    *_inspectorController;
    
    // Targets and actions
    id                        _target;
    SEL                        _action;
    BOOL                    _sendSingleAction;
    id                        _doubleTarget;
    SEL                        _doubleAction;
    BOOL                    _sendDoubleAction;
    
    // User information
    NSMutableDictionary        *_userInfo;
    
    // Delegate
    id <AJRCalendarViewDelegate>    __unsafe_unretained _delegate;
    
    // Configuration
    NSString                *_autosaveName;
    BOOL                    _awakenedFromNib;
    
    // Printing                
    id                        _calendarPrintView;
    
    // Avoiding update floods
    NSTimeInterval            _minimumRefreshInterval;
    NSTimeInterval            _lastRefresh;
}

// Basic calendar properties
@property (nonatomic,strong) NSCalendar *calendar;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSDate *displayDate;
@property (nonatomic,readonly) NSDate *time;
@property (nonatomic,strong) AJRCalendarRenderer *renderer;
@property (nonatomic,strong) EKEventStore *eventStore;

@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSColor *selectedBackgroundColor;
@property (nonatomic,strong) NSColor *todayBackgroundColor;
@property (nonatomic,strong) NSColor *gridColor;
@property (nonatomic,strong) NSFont *font;
@property (nonatomic,strong) NSColor *fontColor;
@property (nonatomic,strong) NSColor *dimmedFontColor;
@property (nonatomic,strong) NSColor *selectedFontColor;
@property (nonatomic,strong) NSColor *selectedDimmedFontColor;
@property (nonatomic,strong) NSColor *timeIndicatorColor;

@property (nonatomic,strong) IBOutlet NSControl *managedControl;

@property (nonatomic,assign) NSUInteger firstMinuteOfWorkHours;
@property (nonatomic,assign) NSUInteger lastMinuteOfWorkHours;

@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,strong) id doubleTarget;
@property (nonatomic,assign) SEL doubleAction;

@property (nonatomic,strong) NSMutableDictionary *userInfo;

@property (nonatomic,unsafe_unretained) IBOutlet id <AJRCalendarViewDelegate> delegate;

@property (nonatomic,strong) NSString *autosaveName;

@property (nonatomic,assign) NSTimeInterval minimumRefreshInterval;

/*!
 @methodgroup Actions
 */

- (IBAction)goToToday:(id)sender;
- (IBAction)goToDate:(id)sender;
- (IBAction)incrementDate:(id)sender;
- (IBAction)decrementDate:(id)sender;
- (IBAction)viewByDay:(id)sender;
- (IBAction)viewByWeek:(id)sender;
- (IBAction)viewByMonth:(id)sender;

- (IBAction)performControlAction:(id)sender;
- (IBAction)takeDateFromStringValue:(id)sender;
- (IBAction)takeDateFromTimeIntervalValue:(id)sender;
- (IBAction)takeDateFromEpochValue:(id)sender;

/*!
 @methodgroup Layout
 */
- (NSScrollView *)bodyScrollView;
- (void)tile;

/*!
 @methodgroup Display
 */
- (void)selectRendererNamed:(NSString *)name;
- (void)selectRenderer:(AJRCalendarRenderer *)renderer;
- (void)setupSegmentedControl:(NSSegmentedControl *)control;
- (void)showInspectorForItem:(EKCalendarItem *)item;

/*!
 @methodgroup Calendars
 */
- (void)setCalendars:(NSArray *)calendars;
- (NSArray *)calendars;
- (void)addCalendar:(EKCalendar *)calendar;
- (void)removeCalendar:(EKCalendar *)calendar;
- (BOOL)isDisplayingCalendar:(EKCalendar *)calendar;

/*!
 @methodgroup Temporary items
 */
- (NSArray *)temporaryItems;
- (NSArray *)temporaryItemsMatchingPredicate:(NSPredicate *)predicate;
- (void)addTemporaryItem:(EKCalendarItem *)item;
- (void)removeTemporaryItem:(EKCalendarItem *)item;
- (void)removeAllTempoaryItems;

/*!
 @methodgroup Selection
 */
- (NSArray *)selection;
- (void)clearSelection;
- (BOOL)isEventSelected:(EKEvent *)event;
- (void)selectEvent:(EKEvent *)event byExtendingSelection:(BOOL)flag;
- (void)showSelection;
- (BOOL)inspectEvent:(EKEvent *)event;

/*!
 @methodgroup Printing
 */
- (void)setupPrintInfo:(NSPrintInfo *)printInfo;
- (NSView *)calendarPrintView;

@end


