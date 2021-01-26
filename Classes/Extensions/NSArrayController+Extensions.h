//
//  NSArrayController-Extensions.h
//  AJRInterface
//
//  Created by A.J. Raftis on 10/21/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArrayController (AJRInterfaceExtensions)

- (IBAction)selectFirstObject:(id)sender;
- (void)selectFirstObject;
@property (nonatomic,readonly,nullable) id firstSelectedObject;

- (IBAction)selectLastObject:(id)sender;
- (void)selectLastObject;
@property (nonatomic,readonly,nullable) id lastSelectedObject;

@property (nonatomic,readonly) NSInteger numberOfObjects;

@end

NS_ASSUME_NONNULL_END
