/*
 AJRMCTablesView.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  AJRMCTablesView.m
//  AJRInterface
//
//  Created by Alex Raftis on 2/9/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import "AJRMCTablesViewP.h"

#import "AJRMarketingContextChooser.h"
#import "NSWindow-Extensions.h"

@implementation AJRMCTablesView

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _focused = AJRSegmentChooserMask;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_chooser release];
    
    [super dealloc];
}

@synthesize chooser = _chooser;

- (void)setChooser:(AJRMarketingContextChooser *)chooser
{
    if (_chooser != chooser) {
        if (_chooser) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AJRWindowDidChangeFirstResponderNotification object:_chooser];
        }
        [_chooser release];
        _chooser = [chooser retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeFirstResponder:) name:AJRWindowDidChangeFirstResponderNotification object:_chooser];
    }
}

- (BOOL)_checkFocused
{
    id                firstResponder = [_chooser firstResponder];
    BOOL            needsTile = NO;

    if (_focused == 0) {
        _focused = AJRSegmentChooserMask;
        needsTile = YES;
    }
    
    if (firstResponder == _chooser.geoTable) {
        _focused = AJRGeoChooserMask;
        needsTile = YES;
    } else if (firstResponder == _chooser.segmentTable) {
        _focused = AJRSegmentChooserMask;
        needsTile = YES;
    } else if (firstResponder == _chooser.languageTable) {
        _focused = AJRLanguageChooserMask;
        needsTile = YES;
    } else if (firstResponder == _chooser.channelTable) {
        _focused = AJRChannelChooserMask;
        needsTile = YES;
    }
    
    return needsTile;
}

- (NSDictionary *)_buildAnimationForView:(NSView *)view
                           startingFrame:(NSRect)startingFrame
                             endingFrame:(NSRect)endingFrame
{
    NSMutableDictionary        *dictionary = [[NSMutableDictionary alloc] init];

    // Specify which view to modify.
    [dictionary setObject:view forKey:NSViewAnimationTargetKey];
    // Specify the starting position of the view.
    [dictionary setObject:[NSValue valueWithRect:startingFrame] forKey:NSViewAnimationStartFrameKey];
    // Change the ending position of the view.
    [dictionary setObject:[NSValue valueWithRect:endingFrame] forKey:NSViewAnimationEndFrameKey];

    return [dictionary autorelease];
}

- (void)tileWithAnimation:(BOOL)animate
{
    NSRect            bounds = [self bounds];
    NSInteger        rows = 3;
    CGFloat            height, top;
    NSScrollView    *geoScroll = [_chooser.geoTable enclosingScrollView];
    NSScrollView    *segmentScroll = [_chooser.segmentTable enclosingScrollView];
    NSScrollView    *languageScroll = [_chooser.languageTable enclosingScrollView];
    NSScrollView    *channelScroll = [_chooser.channelTable enclosingScrollView];
    NSRect            geoFrame = [geoScroll frame];
    NSRect            segmentFrame = [segmentScroll frame];
    NSRect            languageFrame = [languageScroll frame];
    NSRect            channelFrame = [channelScroll frame];
    NSUInteger        partsMask = _chooser.partsMask;
    NSMutableArray    *animations = [[NSMutableArray alloc] init];
    
    if (!(partsMask & AJRSegmentChooserMask)) rows--;
    if (!(partsMask & AJRGeoChooserMask)) rows--;
    if (!(partsMask & AJRLanguageChooserMask)) rows--;
    if (!(partsMask & AJRChannelChooserMask)) rows--;

    [self _checkFocused];
    
    if (rows == 0) return;
    
    top = bounds.origin.y + bounds.size.height;
    height = bounds.size.height - (17.0 * rows) + rows;
    
    if (partsMask & AJRSegmentChooserMask) {
        NSRect    startingFrame = segmentFrame;
        
        [segmentScroll setHidden:NO];
        segmentFrame.size.width = bounds.size.width + 1;
        segmentFrame.size.height = _focused == AJRSegmentChooserMask ? height : 17.0;
        segmentFrame.origin.x = bounds.origin.x;
        segmentFrame.origin.y = top - segmentFrame.size.height;
        //[segmentScroll setFrame:segmentFrame];
        top -= (segmentFrame.size.height - 1);
        
        if (!NSEqualRects(startingFrame, segmentFrame)) {
            if (animate) {
                [animations addObject:[self _buildAnimationForView:segmentScroll startingFrame:startingFrame endingFrame:segmentFrame]];
            } else {
                [segmentScroll setFrame:segmentFrame];
            }
        }
    } else {
        [segmentScroll setHidden:YES];
    }
    
    if (partsMask & AJRGeoChooserMask) {
        NSRect    startingFrame = geoFrame;
        
        [geoScroll setHidden:NO];
        geoFrame.size.width = bounds.size.width + 1;
        geoFrame.size.height = _focused == AJRGeoChooserMask ? height : 17.0;
        geoFrame.origin.x = bounds.origin.x;
        geoFrame.origin.y = top - geoFrame.size.height;
        //[geoScroll setFrame:geoFrame];
        top -= (geoFrame.size.height - 1);
        
        if (!NSEqualRects(startingFrame, segmentFrame)) {
            if (animate) {
                [animations addObject:[self _buildAnimationForView:geoScroll startingFrame:startingFrame endingFrame:geoFrame]];
            } else {
                [geoScroll setFrame:geoFrame];
            }
        }
    } else {
        [geoScroll setHidden:YES];
    }
    
    if (partsMask & AJRLanguageChooserMask) {
        NSRect    startingFrame = languageFrame;
        
        [languageScroll setHidden:NO];
        languageFrame.size.width = bounds.size.width + 1;
        languageFrame.size.height = _focused == AJRLanguageChooserMask ? height : 17.0;
        languageFrame.origin.x = bounds.origin.x;
        languageFrame.origin.y = top - languageFrame.size.height;
        //[languageScroll setFrame:languageFrame];
        top -= (languageFrame.size.height - 1);
        
        if (!NSEqualRects(startingFrame, segmentFrame)) {
            if (animate) {
                [animations addObject:[self _buildAnimationForView:languageScroll startingFrame:startingFrame endingFrame:languageFrame]];
            } else {
                [languageScroll setFrame:languageFrame];
            }
        }
    } else {
        [languageScroll setHidden:YES];
    }
    
    if (partsMask & AJRChannelChooserMask) {
        NSRect    startingFrame = channelFrame;
        
        [channelScroll setHidden:NO];
        channelFrame.size.width = bounds.size.width + 1;
        channelFrame.size.height = _focused == AJRChannelChooserMask ? height : 17.0;
        channelFrame.origin.x = bounds.origin.x;
        channelFrame.origin.y = top - channelFrame.size.height;
        //[channelScroll setFrame:channelFrame];
        top -= (channelFrame.size.height - 1);
        
        if (!NSEqualRects(startingFrame, segmentFrame)) {
            if (animate) {
                [animations addObject:[self  _buildAnimationForView:channelScroll startingFrame:startingFrame endingFrame:channelFrame]];
            } else {
                [channelScroll setFrame:channelFrame];
            }
        }
    } else {
        [channelScroll setHidden:YES];
    }

    if ([animations count]) {
        NSViewAnimation        *animation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
        [animation setDuration:0.25];
        [animation setAnimationCurve:NSAnimationLinear];
        [animation startAnimation];
        [animation release];
    }
    [animations release];
}

- (void)tile
{
    [self tileWithAnimation:NO];
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [self tileWithAnimation:NO];
}

- (void)windowDidChangeFirstResponder:(NSNotification *)notification
{
    if ([self _checkFocused]) {
        [self tileWithAnimation:YES];
    }
}

@end
