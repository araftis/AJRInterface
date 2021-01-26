//
//  AJRHistogramView.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/20/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRHistogramView : NSView

@property (nonatomic,strong) NSDictionary *statistics;
@property (nonatomic,strong) NSFont *labelFont;
@property (nonatomic,assign) NSInteger SLA;
@property (nonatomic,strong) NSColor *SLAColor;
@property (nonatomic,strong) NSColor *borderColor;
@property (nonatomic,strong) NSColor *backgroundColor;

@end
