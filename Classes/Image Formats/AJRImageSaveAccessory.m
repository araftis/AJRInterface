/*
AJRImageSaveAccessory.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#import "AJRImageSaveAccessory.h"

#import "AJRImageFormat.h"
#import "NSBundle+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@interface AJRImageSaveAccessory ()

@property (nonatomic,strong) IBOutlet NSView *view;
@property (nonatomic,strong) IBOutlet NSBox *settingsBox;
@property (nonatomic,strong) IBOutlet NSPopUpButton *formatPopUpButton;

@end

@implementation AJRImageSaveAccessory {
    __weak NSSavePanel *_savePanel;
}

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"AJRImageFormat":[NSNumber numberWithInt:NSBitmapImageFileTypeTIFF]}];
}

- (instancetype)initWithSavePanel:(NSSavePanel *)savePanel {
    if ((self = [super init])) {
        [NSBundle ajr_loadNibNamed:@"AJRImageSaveAccessory" owner:self];
        _savePanel = savePanel;
    }

    return self;
}

- (void)awakeFromNib {
    NSArray *names = [AJRImageFormat formatNames];
    NSInteger x;
    NSMenuItem *item;

    [_formatPopUpButton removeAllItems];
    for (x = 0; x < (const NSInteger)[names count]; x++) {
        [_formatPopUpButton addItemWithTitle:[names objectAtIndex:x]];
        item = (NSMenuItem *)[_formatPopUpButton itemAtIndex:[_formatPopUpButton numberOfItems] - 1];
        [item setRepresentedObject:[AJRImageFormat imageFormatForName:[names objectAtIndex:x]]];
        [item setTag:[[item representedObject] imageType]];
    }

    [_formatPopUpButton selectItem:[_formatPopUpButton itemAtIndex:[_formatPopUpButton indexOfItemWithTag:[[NSUserDefaults standardUserDefaults] integerForKey:@"AJRImageFormat"]]]];
}

- (AJRImageFormat *)currentImageFormat {
    return [[_formatPopUpButton selectedItem] representedObject];
}

- (void)updateView {
    NSView *oldContentView = [_settingsBox contentView];
    NSView *newContentView = [[self currentImageFormat] view];

    if (oldContentView != newContentView) {
        NSRect oldRect = oldContentView ? [oldContentView bounds] : NSZeroRect;
        NSRect newRect = newContentView ? [newContentView bounds] : NSZeroRect;
        NSRect frame = [_view frame];

        [_settingsBox setContentView:nil];
        frame.size.height += newRect.size.height - oldRect.size.height;
        [_savePanel setAccessoryView:nil];
        [_view setFrame:frame];
        [_savePanel setAccessoryView:_view];

        [_settingsBox setContentView:newContentView];
    }
}

- (NSView *)view {
    [self updateView];
    return _view;
}

- (void)selectFormat:(id)sender {
    if (_savePanel) {
        NSString *extension = [[[sender selectedItem] representedObject] extension];
        
        [_savePanel setAllowedFileTypes:[NSArray arrayWithObject:extension]];
        _savePanel.nameFieldStringValue = [[_savePanel.nameFieldStringValue stringByDeletingPathExtension] stringByAppendingPathExtension:extension];
        
        [[NSUserDefaults standardUserDefaults] setInteger:[[self currentImageFormat] imageType] forKey:@"AJRImageFormat"];
        
        [self updateView];
    }
}

- (NSData *)representationForImage:(NSImage *)image {
    NSArray<NSImageRep *> *reps = [NSBitmapImageRep imageRepsWithData:[image TIFFRepresentation]];
    AJRImageFormat *format = [[_formatPopUpButton selectedItem] representedObject];

    return [(NSBitmapImageRep *)[reps firstObject] representationUsingType:[format imageType] properties:[format properties]];
}

@end
