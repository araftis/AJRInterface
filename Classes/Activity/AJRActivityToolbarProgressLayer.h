//
//  AJRActivityToolbarProgressLayer.h
//  Meta Monkey
//
//  Created by A.J. Raftis on 9/10/12.
//
//

#import <QuartzCore/QuartzCore.h>

@interface AJRActivityToolbarProgressLayer : CALayer

@property (nonatomic,assign,getter=isIndeterminate) BOOL indeterminate;
@property (nonatomic,assign) double minimum;
@property (nonatomic,assign) double maximum;
@property (nonatomic,assign) double progress;
@property (nonatomic,assign) CGColorRef color;

@end
