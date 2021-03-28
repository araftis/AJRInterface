
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
