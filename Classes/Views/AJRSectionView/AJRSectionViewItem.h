//
//  AJRSectionViewItem.h
//  AJRInterface
//
//  Created by A.J. Raftis on 9/11/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRSectionView;

@interface AJRSectionViewItem : NSObject <NSCoding>
{
    NSView            *_view;
    NSString        *_title;
    NSRect            _viewFrame;
    BOOL            _expanded;
    
    AJRSectionView    *__unsafe_unretained _sectionView;
}

- (id)initWithView:(NSView *)view sectionView:(AJRSectionView *)sectionView;

@property (nonatomic,strong) NSView *view;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSRect viewFrame;
@property (nonatomic,assign,getter=isExpanded) BOOL expanded;
@property (nonatomic,unsafe_unretained) AJRSectionView *sectionView;

- (NSSize)desiredSize;
- (void)setHeight:(CGFloat)height;

@end
