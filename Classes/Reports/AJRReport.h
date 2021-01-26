/*!
 @header AJRReport.h

 @author A.J. Raftis
 @updated 12/18/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRReportView;

/*!
 @class AJRReport
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRReport : NSObject 
{
    NSWindow        *_window;
    AJRReportView    *_reportView;
}

- (id)initWithPath:(NSString *)path;

- (AJRReportView *)reportView;

- (void)setReportPath:(NSString *)path;
- (NSString *)reportPath;

- (void)setRootObject:(id)object;
- (id)rootObject;

- (void)print;
- (void)printInWindow:(NSWindow *)window;

@end
