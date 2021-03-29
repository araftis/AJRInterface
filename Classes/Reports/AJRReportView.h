/*
AJRReportView.h
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
/*!
 @header AJRReportView.h

 @author A.J. Raftis
 @updated 12/18/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <WebKit/WebKit.h>

@class AJRGate;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

/*!
 @class AJRReportView
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRReportView : WebView <NSCoding>

@property (nonatomic,strong) NSString *reportName;
@property (nonatomic,readonly) NSBundle *reportBundle;
@property (nonatomic,strong) NSString *reportPath;
@property (nonatomic,strong) id rootObject;
@property (nonatomic,readonly) NSMutableDictionary *objects;
@property (nonatomic,unsafe_unretained) id delegate;
@property (nonatomic,strong) NSURL *baseURL;

- (void)resetDocument;

- (void)updateNodes:(NSArray *)children;
- (void)updateNode:(NSXMLNode *)node;
- (void)update;

- (NSString *)htmlString;

- (BOOL)isLandscape;
- (CGFloat)topMargin;
- (CGFloat)bottomMargin;
- (CGFloat)leftMargin;
- (CGFloat)rightMargin;

/*!
 @methodgroup Printing
 */
- (void)print;
- (void)printDocument:(id)sender;
- (void)printInWindow:(NSWindow *)window;

/*!
 @methodgroup E-Mail
 */
- (NSString *)mimeMessageBody;
- (void)emailReportFrom:(NSString *)sender to:(NSString *)recipient subject:(NSString *)subject via:(NSString *)smtpHost;

@end

@interface NSObject (AJRReportViewDelegate)

- (void)reportView:(AJRReportView *)reportView didFinishPrintingWithSuccess:(BOOL)flag;

@end

#pragma clang diagnostic pop
