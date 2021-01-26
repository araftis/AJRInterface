/*!
 @header AJRReportElement.h

 @author A.J. Raftis
 @updated 12/19/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRReportView;

/*!
 @class AJRReportElement
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRReportElement : NSObject 
{
    AJRReportView    *_reportView;
    NSXMLElement    *_node;
}

+ (void)registerReportElement:(Class)element forName:(NSString *)name;

+ (id)elementForNode:(NSXMLElement *)node inReportView:(AJRReportView *)reportView;

- (id)initWithNode:(NSXMLElement *)node inReportView:(AJRReportView *)reportView;

- (void)apply;
- (void)cleanup;

@end
