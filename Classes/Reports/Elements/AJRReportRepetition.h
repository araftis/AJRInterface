/*!
 @header AJRReportRepetition.h

 @author A.J. Raftis
 @updated 12/19/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <AJRInterface/AJRReportElement.h>

/*!
 @class AJRReportRepetition
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRReportRepetition : AJRReportElement 
{
    id                _list;
    NSString        *_objectName;
    NSString        *_indexName;
    NSUInteger        _index;
    NSXMLElement    *_parent;
    NSXMLElement    *_beforeNode;
    NSUInteger        _insertIndex;
    NSMutableArray    *_elements;
    NSMutableArray    *_sortOrderings;
}

@end
