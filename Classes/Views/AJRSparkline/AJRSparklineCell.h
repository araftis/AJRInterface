/*!
 @header AJRSparklineCell.h

 @author Alex Raftis
 @updated 12/16/08.
 @copyright 2008 Apple, Inc.. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

@class AJRSeries, AJRSparkline, AJRSparklineChart, AJRSparklineRenderer;

/*!
 @class AJRSparklineCell
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRSparklineCell : NSCell 
{
    AJRSparklineRenderer    *_renderer;
}

@property (nonatomic,retain) AJRSparklineChart *sparklineChart;
@property (nonatomic,retain) AJRSparklineRenderer *renderer;

@end
