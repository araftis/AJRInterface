//
//  AJRActivityView.h
//
//  Created by A.J. Raftis on Mon Nov 18 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class AJRActivity;

@interface AJRActivityView : NSControl
{
   NSMutableArray    *activities;
   AJRActivity        *selectedActivity;
   NSObject            *target;
   SEL                action;

   id <NSLocking>    lock;
}

- (void)tile;

- (NSArray *)activities;
- (void)addActivity:(AJRActivity *)activity;
- (void)removeActivity:(AJRActivity *)activity;
- (void)selectActivityAtIndex:(NSUInteger)index;
- (AJRActivity *)selectedActivity;

@end
