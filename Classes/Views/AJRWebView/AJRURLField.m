
#import "AJRURLField.h"

#import "AJRURLFieldCell.h"
#import "AJRImages.h"
#import "NSImage+Extensions.h"
#import "NSEvent+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <WebKit/WebKit.h>

@implementation AJRURLField {
    NSButton *_reloadButton;
    BOOL _initiateURLDragOnMouseDragged;
    BOOL _dropInitiated;
    BOOL _editableBeforeDrop;
    NSArray<NSPasteboardType> *_savedPasteboardTypes;
}

+ (void)initialize {
	[self setCellClass:[AJRURLFieldCell class]];
}

#pragma mark - Creation

- (void)ajr_commonInit {
    NSImage *image = [AJRImages imageNamed:@"AJRWebReloadIcon" forObject:self];
    _reloadButton = [NSButton buttonWithImage:[image ajr_imageTintedWithColor:[NSColor colorWithCalibratedWhite:0.3 alpha:1.0]] target:nil action:@selector(reload:)];
    _reloadButton.alternateImage = [image ajr_imageTintedWithColor:[NSColor alternateSelectedControlColor]];
    [_reloadButton setBordered:NO];
    [_reloadButton setBezelStyle:NSBezelStyleSmallSquare];
    [_reloadButton setButtonType:NSButtonTypeMomentaryChange];
    [self addSubview:_reloadButton];

    [_reloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_reloadButton addConstraints:@[[[_reloadButton widthAnchor] constraintEqualToConstant:11.0],
                                    [[_reloadButton heightAnchor] constraintEqualToConstant:15.0],
                                    ]];
    [self addConstraints:@[[[self rightAnchor] constraintEqualToAnchor:[_reloadButton rightAnchor] constant:5.0],
                           [[self centerYAnchor] constraintEqualToAnchor:[_reloadButton centerYAnchor] constant:1.0],
                           ]];
    
    [self registerForDraggedTypes:@[NSPasteboardTypeURL, NSPasteboardTypeString]];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        [self ajr_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self ajr_commonInit];
    }
    return self;
}

#pragma mark - NSTextField

+ (Class)cellClass {
	return [AJRURLFieldCell class];
}

- (void)setCell:(id)cell {
	[super setCell:cell];
}

#pragma mark - Properties

// We must override these, because we also override stringValue. That's why we can super. If we didn't we'd infinitely recurse.
- (void)setURLValue:(NSURL *)aURL {
	[self setStringValue:[aURL absoluteString] ?: @""];
}

- (NSURL *)URLValue {
	return [NSURL URLWithParsableString:[super stringValue]];
}

- (void)setIcon:(NSImage *)anIcon {
	[[self cell] setIcon:anIcon];
	[self setNeedsDisplay:YES];
}

- (NSImage *)icon {
	return [[self cell] icon];
}

- (NSImage *)displayIcon {
	return [[self cell] displayIcon];
}

- (NSButton *)reloadButton {
    return _reloadButton;
}

- (NSString *)stringValue {
    return self.URLValue.absoluteString;
}

- (NSString *)titleForDrag {
    return _titleForDrag ?: [self stringValue];
}

#pragma mark - Progress

- (void)setProgress:(double)value {
    [(AJRURLFieldCell *)[self cell] setProgress:value];
    [self setNeedsDisplay:YES];
}

- (double)progress {
    return [(AJRURLFieldCell *)[self cell] progress];
}

- (void)_noteProgressComplete {
	[self setProgress:0.0];
}

- (void)noteProgressComplete {
	[self setProgress:1.0];
	[self performSelector:@selector(_noteProgressComplete) withObject:nil afterDelay:0.25];
}

#pragma mark - NSView

- (void)resetCursorRects {
    NSRect rect = [[self cell] textRectForBounds:[self bounds]];
    [self addCursorRect:rect cursor:[NSCursor IBeamCursor]];
}

#pragma mark - NSResponder

- (void)mouseDown:(NSEvent *)event {
    NSPoint where = [event ajr_locationInView:self];
    if (NSMouseInRect(where, [(AJRURLFieldCell *)[self cell] iconRectForBounds:[self bounds]], NO)) {
        _initiateURLDragOnMouseDragged = YES;
    } else {
        _initiateURLDragOnMouseDragged = NO;
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (_initiateURLDragOnMouseDragged) {
        NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:[self URLValue]];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.titleForDrag attributes:@{NSFontAttributeName:[self font]}];
        NSSize textSize = [string size];
        NSSize imageSize = {16.0 + 4.0 + textSize.width, 16.0};
        
        item.draggingFrame = (NSRect){NSZeroPoint, imageSize};
        [item setImageComponentsProvider:^NSArray<NSDraggingImageComponent *> * _Nonnull{
            NSDraggingImageComponent *imageComponent = [[NSDraggingImageComponent alloc] initWithKey:NSDraggingImageComponentIconKey];
            NSImage *image = [NSImage ajr_imageWithSize:imageSize scales:@[@(1.0), @(2.0)] flipped:NO colorSpace:nil commands:^(CGFloat scale) {
                [[self icon] drawInRect:(NSRect){NSZeroPoint, {16.0, 16.0}}];
                NSRect textRect = (NSRect){{20.0, 0.0}, textSize};
                [string drawInRect:textRect];
            }];
            imageComponent.contents = image;
            imageComponent.frame = (NSRect){NSZeroPoint, imageSize};
            return @[imageComponent];
        }];
        [self beginDraggingSessionWithItems:@[item] event:event source:self];
    }
}

#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy;
}

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if (!_dropInitiated) {
        _dropInitiated = YES;
        NSTextView *editor = AJRObjectIfKindOfClass(self.window.firstResponder, NSTextView);
        if (editor != nil && editor.delegate == (id)self) {
            // We're currently the primary editor...
            _savedPasteboardTypes = [editor registeredDraggedTypes];
            [editor unregisterDraggedTypes];
        }
    }
    return [[[sender draggingPasteboard] types] containsObject:NSPasteboardTypeURL] ? NSDragOperationCopy : NSDragOperationNone;
}

- (void)draggingExited:(nullable id <NSDraggingInfo>)sender {
}


- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    if (NSMouseInRect([self convertPoint:[sender draggingLocation] fromView:nil], [self bounds], NO)) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    if (NSMouseInRect([self convertPoint:[sender draggingLocation] fromView:nil], [self bounds], NO)) {
        NSURL *URL = [NSURL URLWithString:[[sender draggingPasteboard] stringForType:NSPasteboardTypeURL]];
        if (URL) {
            self.URLValue = URL;
            [NSApp sendAction:[self action] to:[self target] from:self];
        }
    }

    if (_savedPasteboardTypes) {
        // This will probably be true, but be safe.
        NSTextView *editor = AJRObjectIfKindOfClass(self.window.firstResponder, NSTextView);
        if (editor != nil && editor.delegate == (id)self) {
            [editor registerForDraggedTypes:_savedPasteboardTypes];
        }
        _savedPasteboardTypes = nil;
    }

    _dropInitiated = YES;
    return NO;
}

@end
