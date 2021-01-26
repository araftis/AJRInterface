//
//  NSSegmentedControl-Extensions.h
//  Meta Monkey
//
//  Created by A.J. Raftis on 3/20/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MMTranslator;

@interface NSSegmentedControl (AJRInterfaceExtensions)

- (void)translateWithTranslator:(MMTranslator *)translator;

@end
