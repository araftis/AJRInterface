//
//  AJRExceptionPanel.h
//  AJRInterface
//
//  Created by A.J. Raftis on 1/26/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRReportView;

@interface AJRExceptionPanel : NSObject
{
    NSPanel            *_panel;
    NSTextField        *_titleText;
    NSTextField        *_messageText;
    AJRReportView    *_exceptionReport;
    NSButton        *_exitButton;
    NSButton        *_continueButton;
    NSButton        *_printButton;
    NSButton        *_emailButton;
    NSException        *_exception;
}

+ (id)exceptionPanelWithException:(NSException *)exception;

- (id)initWithException:(NSException *)exception;

@property (nonatomic,strong) IBOutlet NSPanel *panel;
@property (nonatomic,strong) IBOutlet NSTextField *titleText;
@property (nonatomic,strong) IBOutlet NSTextField *messageText;
@property (nonatomic,strong) IBOutlet AJRReportView *exceptionReport;
@property (nonatomic,strong) IBOutlet NSButton *exitButton;
@property (nonatomic,strong) IBOutlet NSButton *continueButton;
@property (nonatomic,strong) IBOutlet NSButton *printButton;
@property (nonatomic,strong) IBOutlet NSButton *emailButton;
@property (nonatomic,strong) NSException *exception;

- (NSInteger)run;

- (IBAction)exitApplication:(id)sender;
- (IBAction)continueApplication:(id)sender;
- (IBAction)printException:(id)sender;
- (IBAction)emailException:(id)sender;

@end
