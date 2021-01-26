//
//  AJRRatingsCell.h
//  AJRInterface
//
//  Created by Mike Lee on 1/21/09.
//  Copyright 2009 United Lemur. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AJRRatingsCell : NSLevelIndicatorCell {
    BOOL _usesLargeStars;
}

@property BOOL usesLargeStars;

@end
