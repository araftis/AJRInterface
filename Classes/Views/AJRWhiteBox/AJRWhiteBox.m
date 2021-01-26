//
//  AJRWhiteBox.m
//  AJRInterface
//
//  Created by Scottie on 11/7/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRWhiteBox.h"


@implementation AJRWhiteBox

- (void)setup {
    [self setTitle:@""];
    [self setBoxType:NSBoxCustom];
    //[self setBorderType:NSLineBorder];
    [self setFillColor:[NSColor whiteColor]];
    [self setBorderColor:[NSColor grayColor]];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        // Initialization code here.
        [self setup];
    }
    return self;    
}


- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    [super drawRect:rect];
}

@end
