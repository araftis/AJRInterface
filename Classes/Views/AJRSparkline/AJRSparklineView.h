/*!
 @header AJRSparklineView.h

 @author Alex Raftis
 @updated 12/16/08.
 @copyright 2008 Apple, Inc.. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRSparklineChart, AJRSparklineCell;

/*!
 @class AJRSparklineView
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSparklineView : NSView 
{
    AJRSparklineCell        *_cell;
}

@property (nonatomic,retain) AJRSparklineCell *cell;
@property (nonatomic,retain) AJRSparklineChart *sparklineChart;

@end
