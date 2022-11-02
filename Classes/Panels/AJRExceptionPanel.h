/*
 AJRExceptionPanel.h
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

#import <Cocoa/Cocoa.h>

@class AJRReportView;

@interface AJRExceptionPanel : NSObject {
    NSPanel *_panel;
    NSTextField *_titleText;
    NSTextField *_messageText;
    AJRReportView *_exceptionReport;
    NSButton *_exitButton;
    NSButton *_continueButton;
    NSButton *_printButton;
    NSButton *_emailButton;
    NSException *_exception;
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
