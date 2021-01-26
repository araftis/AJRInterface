//
//  NSTextFieldCell.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/18/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextFieldCell (Extensions)

@end


@interface NSObject (NSTextFieldCellDelegate)

- (NSText *)textFieldCell:(NSTextFieldCell *)cell setUpFieldEditorAttributes:(NSText *)text;

@end
