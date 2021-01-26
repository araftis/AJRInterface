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
