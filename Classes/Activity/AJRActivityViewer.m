//
//  AJRActivityViewer.m
//
//  Created by A.J. Raftis on Mon Nov 18 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AJRActivityViewer.h"

#import "AJRActivityView.h"
#import "NSBundle+Extensions.h"

#import <AJRFoundation/AJRActivity.h>

@implementation AJRActivityViewer

+ (id)allocWithZone:(NSZone *)aZone {
    static AJRActivityViewer *SELF = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SELF = [super allocWithZone:nil];
    });
    return SELF;
}

+ (id)sharedInstance {
    return [[self alloc] init];
}

- (id)init {
    if (!window) {
        [NSBundle ajr_loadNibNamed:@"AJRActivityViewer" owner:self];
        [statusText setStringValue:@""];
        [progressText setStringValue:@""];
        [stopButton setEnabled:NO];
        [scrollView setBackgroundColor:[NSColor whiteColor]];
        
        [self performSelector:@selector(timedUpdate) withObject:nil afterDelay:1.0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    if ([window isVisible]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ActivityViewerVisible"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)timeIntervalString:(NSTimeInterval)ts {
    NSInteger        tsi = (NSInteger)ts;
    
    if (tsi < 0) tsi = -tsi;
    
    if (tsi < 60) {
        return AJRFormat(@"%d second%@", tsi, tsi == 1 ? @"" : @"s");
    } else if (tsi < 60 * 60) {
        NSInteger        seconds = tsi % 60;
        NSInteger        minutes = tsi / 60;
        return AJRFormat(@"%d minute%@ %d second%@",
                         minutes, minutes == 1 ? @"" : @"s",
                         seconds, seconds == 1 ? @"" : @"s");
    } else {
        NSInteger        seconds = tsi % 60;
        NSInteger        minutes = (tsi / 60) % 60;
        NSInteger        hours = tsi / (60 * 60);
        return AJRFormat(@"%d hour%@ %d minute%@ %d second%@",
                         hours, hours == 1 ? @"" : @"s",
                         minutes, minutes == 1 ? @"" : @"s",
                         seconds, seconds == 1 ? @"" : @"s");
    }
}

- (void)update {
    AJRActivity        *activity = [view selectedActivity];
    
    if (activity == nil) {
        [statusText setStringValue:@""];
        [progressText setStringValue:@""];
        [stopButton setEnabled:NO];
    } else {
        if ([activity isStopRequested]) {
            [statusText setStringValue:@"Stopping"];
            [stopButton setEnabled:NO];
        } else if ([activity isStopped]) {
            [statusText setStringValue:@"Stopped"];
            [stopButton setEnabled:NO];
        } else {
            [statusText setStringValue:@"Active"];
            [stopButton setEnabled:YES];
        }
        if ([[activity messages] count]) {
            [progressText setStringValue:AJRFormat(@"%@\n%@", [self timeIntervalString:[activity ellapsedTime]], [[activity messages] objectAtIndex:0])];
        } else {
            [progressText setStringValue:AJRFormat(@"%@", [self timeIntervalString:[activity ellapsedTime]])];
        }
    }
}

- (void)timedUpdate {
    if ([window isVisible]) {
        [self update];
    }
    [self performSelector:@selector(timedUpdate) withObject:nil afterDelay:1.0];
}

- (NSArray *)activities {
    return [view activities];
}

- (void)addActivity:(AJRActivity *)activity {
    [view addActivity:activity];
}

- (void)removeActivity:(AJRActivity *)activity {
    [view removeActivity:activity];
    [self update];
}

- (void)stopActivity:(id)sender {
    [[view selectedActivity] stop];
    [self update];
}

- (void)selectActivity:(id)sender {
    [self update];
}

- (void)showActivityPanel:(id)sender {
    [window orderFront:sender];
}

@end


@implementation NSResponder (AJRActivityViewer)

- (void)showActivityPanel:(id)sender {
    [[AJRActivityViewer sharedInstance] showActivityPanel:sender];
}

@end
