//
//  AJRSeparatorBorder.h
//  AJRInterface
//
//  Created by A.J. Raftis on 8/6/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <AJRInterface/AJRBorder.h>

@class AJRGradientColor;

@interface AJRSeparatorBorder : AJRBorder

@property (nonatomic,strong) AJRGradientColor *leftColor;
@property (nonatomic,strong) AJRGradientColor *rightColor;
@property (nonatomic,strong) AJRGradientColor *topColor;
@property (nonatomic,strong) AJRGradientColor *bottomColor;
@property (nonatomic,strong) AJRGradientColor *backgroundColor;

@property (nonatomic,strong) AJRGradientColor *inactiveLeftColor;
@property (nonatomic,strong) AJRGradientColor *inactiveRightColor;
@property (nonatomic,strong) AJRGradientColor *inactiveTopColor;
@property (nonatomic,strong) AJRGradientColor *inactiveBottomColor;
@property (nonatomic,strong) AJRGradientColor *inactiveBackgroundColor;

@end
