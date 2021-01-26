//
//  AJRPopUpTextFieldCell.h
//  Meta Monkey
//
//  Created by A.J. Raftis on 3/11/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRPopUpTextFieldCell : NSTextFieldCell

@property (strong) IBOutlet NSMenu *menu;

@property (nonatomic,strong) NSGradient *activeGradient;
@property (nonatomic,strong) NSGradient *inactiveGradient;
@property (nonatomic,strong) NSGradient *disabledGradient;

- (void)viewDidChangeEffectiveAppearance;

@end
