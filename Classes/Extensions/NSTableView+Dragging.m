/*
NSTableView+Dragging.m
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

#import "NSTableView+Dragging.h"

#import "NSAffineTransform+Extensions.h"
#import "NSImage+Extensions.h"

#import <AJRInterface/AJRInterface.h>

NSString *NSTableViewDidMoveRowNotification = @"NSTableViewDidMoveRowNotification";
NSString *NSTableViewStartingRowIndexKey = @"NSTableViewStartingRowIndexKey";
NSString *NSTableViewEndingRowIndexKey = @"NSTableViewEndingRowIndexKey";
NSString *NSTableViewDeleteKeyPressedNotification = @"NSTableViewDeleteKeyPressedNotification";
NSString *NSTableViewSelectionKey = @"NSTableViewSelectionKey";

static NSTimeInterval AJRClearSearchDelay = 1.0 / 3.0;

@interface AJRHUDView : NSView {
    NSString *_stringValue;
    NSMutableDictionary *_attributes;
}

@property (nonatomic,strong) NSString *stringValue;
@property (nonatomic,readonly) NSMutableDictionary *attributes;

@end


@interface NSTableView (AJRPrivate)

- (NSWindow *)typeAheadHUDWindow;

@end


@interface AJRTableInitialization : NSObject 
@end

@interface NSTableView (AJRForwardDeclarations)

- (void)ajr_mouseDown:(NSEvent *)event;
- (void)ajr_keyDown:(NSEvent *)event;

@end


@implementation AJRTableInitialization

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AJRSwizzleMethods(objc_getClass("NSTableView"), @selector(mouseDown:), objc_getClass("NSTableView"), @selector(ajr_mouseDown:));
        AJRSwizzleMethods(objc_getClass("NSTableView"), @selector(keyDown:), objc_getClass("NSTableView"), @selector(ajr_keyDown:));
    });
}

@end


@implementation NSTableView (Dragging)

- (BOOL)_isPartOfComboBox {
    // Hack to tell us when we are being displayed in a ComboBox and hence should turn off the
    // key row display functionality since this interferes with the way the combo box list is
    // displayed
    return [[[[self superview] superview] superview] isKindOfClass:NSClassFromString(@"NSFrameView")];
}

// This is index of the row that is currently being dragged. This value will change as the row moves, so it always represents the rows current index. This isn't thread safe, but then neither is AppKit.
static NSInteger draggingRow;

// Draw a row. This is really just a convenience for me so that I don't have to compute the clip rectangle, draw the background, and grid in multiple places. Mostly, this is just a front to drawRow:clipRect:.
- (void)drawRow:(NSUInteger)rowIndex {
    NSRect rowRect = [self rectOfRow:rowIndex];
    
    if (rowIndex == draggingRow) {
        [NSColor.underPageBackgroundColor set];
    } else if ([self isRowSelected:rowIndex]) {
        [NSColor.selectedControlColor set];
    } else {
        [self.backgroundColor set];
    }
    NSRectFill(rowRect);
    if ([self gridStyleMask]) {
        [self drawGridInClipRect:[self visibleRect]];
    }
    if (rowIndex != draggingRow) {
        [self drawRow:rowIndex clipRect:[self visibleRect]];
    }
}

// Draw all the rows who partially overlap rect. We use this method a lot as we drag our row to restore the table view underneath the moving row.
- (void)drawRowsUnderRect:(NSRect)rect {
    NSRange rows = [self rowsInRect:rect];
    NSInteger x;
    
    for (x = 0; x < rows.length; x++) {
        [self drawRow:x + rows.location];
    }
}

// This method is called from mouseDown: when the command key is being held and the delegate responds to tableView:moveRowAtIndex:toIndex:
- (void)dragFromEvent:(NSEvent *)event {
	AJRLogWarning(@"This method, -[%C %S], is probably horribly broken due to lockFocus being deprecated. If you see this, fix this!", self, _cmd);
    NSPoint where = [self convertPoint:[event locationInWindow] fromView:nil]; // Where we are.
    NSInteger rowIndex = [self rowAtPoint:where];        // Our row
    NSInteger startingIndex = rowIndex;                  // Where we started.
    NSRect rect = [self rectOfRow:rowIndex];             // The rectangle of that row.
    NSImage *row;                                        // The image of our cached row.
    NSPoint mouseDelta;                                  // the dx, dy of our mouse in the row's rect
    BOOL done;                                           // if yes, we're done with our event loop.
    float maxY;                                          // The height of the table view.
    BOOL wasSelected = [self isRowSelected:rowIndex];    // If our starts life selected. This is important later on.
    float rowHeight = [self rowHeight];                  // Used for bounds checking.
    NSBezierPath *path;
    
    // Save the row that was selected in draggingRow.
    draggingRow = rowIndex;
    
    // Compute our offset in the row's rectangle. This allows us to draw the row's image correctly, relative to where the user selected it.
    mouseDelta.x = where.x - rect.origin.x;
    mouseDelta.y = where.y - rect.origin.y;
    
    // Create our image (cache)
    row = [[NSImage allocWithZone:nil] initWithSize:rect.size];
    // Lock focus on it.
    [row lockFocus];
    // Make sure it's flipped, since table view's are flipped.
    [row ajr_flipCoordinateSystem];
    // Make our coordinates equal to the row's rectangle's origin.
    [NSAffineTransform translateXBy:-rect.origin.x yBy:-rect.origin.y];
    // If we're selected, choose selectedControlColor, otherwise, just use our background color.
    if (wasSelected) {
        // This the alpha level to 0.5, just because it's cool.
        [[[NSColor selectedControlColor] colorWithAlphaComponent:0.5] set];
    } else {
        // This the alpha level to 0.5, just because it's cool.
        [[[self backgroundColor] colorWithAlphaComponent:0.5] set];
    }
    // Draw the background.
    NSRectFill(rect);
    // If the grid is on, draw our grid lines. Note that we're opaque again. This is done for ease of programming, since I don't want to compute (and temporarily change) gridColor with alpha. Also, the transparent background with opaque text and grid is neat looking.
    if ([self gridStyleMask]) {
        [self drawGridInClipRect:rect];
    }
    // Now, draw our row.
    [self drawRow:rowIndex clipRect:rect];
    // Also, draw some lines at the top and bottom of the row. I did this because before the lines, the row didn't standout from the row's that weren't moving. This makes the dragging row much more obvious.
    [[NSColor blackColor] set];
    path = [[NSBezierPath alloc] init];
    [path moveToPoint:(NSPoint){rect.origin.x, rect.origin.y}];
    [path relativeLineToPoint:(NSPoint){rect.size.width, 0.0}];
    [path moveToPoint:(NSPoint){rect.origin.x, rect.origin.y + rect.size.height - 1.0}];
    [path relativeLineToPoint:(NSPoint){rect.size.width, 0.0}];
    [path stroke];
    [row unlockFocus];
    
    // Figure out how tall we are. This is easiest (and fastest) to cache here, and will prevent us from dragging off the bottom of the table view.
    maxY = [self numberOfRows] * rowHeight;
    
    // We're drawing into ourself from now on.
    //[self lockFocus];
    
    done = NO;
    while (!done) {
        
        // Get the next event. Unlike what you may think, we don't need to use periodic event's like you might think. This is because of how we compute the row we're over.
        event = [NSApp nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged
                                   untilDate:[NSDate distantFuture]
                                      inMode:NSEventTrackingRunLoopMode
                                     dequeue:YES];
        
        // Find out where we are (or were as the case may be). The first time through this loop, where is computed on first entering the method. Subsequently, it's computed each time we get a drag event.
        rowIndex = [self rowAtPoint:where];
        
        // If rowIndex is not equal to draggingRow, then we've moved to a new position.
        if (rowIndex != draggingRow) {
            // Give our delegate a chance to deny the move. Note, if this method returns YES, then the rows have been rearranged by the delegate, and we'll need to make ourself reflect the new world order.
            if ([(id)[self delegate] tableView:self moveRowAtIndex:draggingRow toIndex:rowIndex]) {
                NSInteger    oldIndex = draggingRow;    // Save the old position.
                NSInteger    a, b;                            // These are used below to redraw moved rows.
                
                // If the row we're moving to is selected, then we need to deselect it and reselect it in it's new position. This must be done because the table view tracks the selection indices rather than the rows tracking their selection status.
                if ([self isRowSelected:rowIndex]) {
                    [self deselectRow:rowIndex];
                    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:draggingRow] byExtendingSelection:NO];
                    // It's important to call this, otherwise the table view will update itself when we call for the next event, and we're updating ourself in this event loop, so don't want to call the normal update mechanism.
                    [self setNeedsDisplay:NO];
                }
                // If we were selected at the start, then the move of the selection is backwards.
                if (wasSelected) {
                    [self deselectRow:draggingRow];
                    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
                    // It's important to call this, otherwise the table view will update itself when we call for the next event, and we're updating ourself in this event loop, so don't want to call the normal update mechanism.
                    [self setNeedsDisplay:NO];
                }
                // Now that we're all moved, set draggingRow to rowIndex, since this is the "new" row to drag.
                draggingRow = rowIndex;
                // Figure our the first and last rows to move. Set the first row index to 'a' and the second row index to 'b'.
                if (draggingRow < oldIndex) {
                    a = draggingRow;
                    b = oldIndex;
                } else {
                    a = oldIndex;
                    b = draggingRow;
                }
                // Loop over all rows that moved and redraw them. This is done because we can move not only to adjacent rows, but also accross multiple rows, if the user moves the mouse fast enough.
                for ( ; a <= b; a++) {
                    [self drawRow:a];
                }
            }
        }
        
        // Restore the old visual area. The first time through the loop, this makes sure that our position in the table view is drawn as "gray".
        [self drawRowsUnderRect:(NSRect){{0.0, where.y - mouseDelta.y}, [row size]}];
        
        // Now, see what we're doing...
        switch ([event type]) {
            case NSEventTypeLeftMouseUp:
                // Just finish. Since we reorder in real time, we don't really need to do anything else.
                done = YES;
                break;
            case NSEventTypeLeftMouseDragged:
                // Get our new location.
                where = [self convertPoint:[event locationInWindow] fromView:nil];
                // Contrain it such that we don't drag a row off the top or bottom of the table view.
                if (where.y < mouseDelta.y) {
                    where.y = mouseDelta.y;
                } else if (where.y > (maxY - (rowHeight - mouseDelta.y)) + 2.0) {
                    // 12/3/99 AJR (5450) This constraint checking wasn't working.
                    where.y = (maxY - (rowHeight - mouseDelta.y)) + 2.0;
                }
                // Make sure that we're still visible. If this method returns yes, then we scrolled, and we need to recompute our where.
                if ([self scrollRectToVisible:(NSRect){{0.0, where.y - mouseDelta.y}, [row size]}]) {
                    where = [self convertPoint:[event locationInWindow] fromView:nil];
                    // And since we recomputed this, we need to recontrain it.
                    if (where.y < mouseDelta.y) {
                        where.y = mouseDelta.y;
                    } else if (where.y > (maxY - (rowHeight - mouseDelta.y)) + 2.0) {
                        // 12/3/99 AJR (5450) This constraint checking wasn't working.
                        where.y = (maxY - (rowHeight - mouseDelta.y)) + 2.0;
                    }
                }
                // Draw our cached image over the table view. We use NSCompositingOperationSourceOver just to be cool.
                [row ajr_drawAtPoint:(NSPoint){0.0, where.y + (rect.size.height - mouseDelta.y)} operation:NSCompositingOperationSourceOver];
                // Flush the drawing to the screen.
                //[[self window] flushWindow];
                break;
            default:
                break;
        }
    }
    
    // We're done drawing to ourself.
    //[self unlockFocus];
    
    // If we actually moved, broadcast a notification.
    if (startingIndex != draggingRow) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSTableViewDidMoveRowNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:startingIndex], NSTableViewStartingRowIndexKey, [NSNumber numberWithInteger:draggingRow], NSTableViewEndingRowIndexKey, nil]];
    }
    
    // And since we probably did something, mark ourself as needing display.
    [self setNeedsDisplay:YES];
    if ([[self delegate] respondsToSelector:@selector(tableViewDidMoveRow:)]) {
        [(id)[self delegate] tableViewDidMoveRow:self];
    }
}

- (void)ajr_mouseDown:(NSEvent *)event {
//    if ([self _isPartOfComboBox]) {
//        [super mouseDown:event];
//        return;
//    }
    
    // don't do anything if we are disabled
    if (![self isEnabled])
        return;
    
    // This is the only piece of table view that we actually over ride, and it's pretty simple. Basically, just checks to see if our delegate responds to tableView:moveRowAtIndex:toIndex: and the user is holding down the command key. If this is the case, then dragFromEvent: is called, otherwise we call [super mouseDown:]. I chose the command key rather than the control key (which the old ScrollDoodScroll demo used), because NT doesn't give OPENSTEP apps easy access to the control key.
    if ((![[self delegate] respondsToSelector:@selector(tableViewShouldMoveRows:)] || [(id)[self delegate] tableViewShouldMoveRows:self]) && [[self delegate] respondsToSelector:@selector(tableView:moveRowAtIndex:toIndex:)] && ([event modifierFlags] & NSEventModifierFlagCommand)) {
        [self dragFromEvent:event];
        return;
    }
    
    [self ajr_mouseDown:event];
}

- (BOOL)_deleteKeyPressed {
    BOOL returnValue = NO;
    NSIndexSet *selection = [self selectedRowIndexes];
    
    if ([[self delegate] respondsToSelector:@selector(tableView:shouldDeleteRowsAtIndexes:)]) {
        if (![(id)[self delegate] tableView:self shouldDeleteRowsAtIndexes:selection]) {
            return NO;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NSTableViewDeleteKeyPressedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[self selectedRowIndexes], NSTableViewSelectionKey, nil]];
    if ([[self delegate] respondsToSelector:@selector(tableView:deleteRowsAtIndexes:)]) {
        if ([(id)[self delegate] tableView:self deleteRowsAtIndexes:selection]) {
            [self reloadData];
            returnValue = YES;
        }
    }
    if (returnValue && [[self delegate] respondsToSelector:@selector(tableView:didDeleteRowsAtIndexes:)]) {
        [(id)[self delegate] tableView:self didDeleteRowsAtIndexes:selection];
    }
    
    return returnValue;
}

- (IBAction)copy:(id)sender {
    NSMutableString *string = [NSMutableString string];
    NSMutableString *html = [NSMutableString string];
    NSInteger x, xMax = [self numberOfColumns];
    NSInteger y, yMax = [self numberOfRows];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    
    [html appendString:@"<table cellspacing=0 style=\"border: 1px solid darkgray; border-spacing: 0px 0px; font-family: 'Lucida Grande'; font-size: 11px;\"><tr>"];
    for (x = 0; x < xMax; x++) {
        NSCell *cell = [[[self tableColumns] objectAtIndex:x] headerCell];
        NSString *value = @"";
        if ([cell respondsToSelector:@selector(title)]) {
            value = [cell title];
        } else if ([cell respondsToSelector:@selector(stringValue)]) {
            value = [cell stringValue];
        }
        [string appendString:value];
        [string appendString:@"\t"];
        
        NSMutableString *style = [[NSMutableString alloc] initWithString:@"padding-left: 3px; padding-right: 3px; background-color: #E1E1E1; background-image: -webkit-linear-gradient(#F0F0F0,#F7F7F7 45%,#E5E5E5 55%,#DEDEDE);border-bottom: 1px solid darkgray;"];
        if (x < xMax - 1) {
            [style appendString:@"border-right: 1px solid darkgray;"];
        }
        [html appendFormat:@"<th style=\"%@\">%@</th>", style, [cell stringValue]];
    }
    [string appendString:@"\n"];
    [html appendString:@"</tr>"];
    
    for (y = 0; y < yMax; y++) {
        [html appendString:@"<tr>"];
        for (x = 0; x < xMax; x++) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            NSCell *cell = [self preparedCellAtColumn:x row:y];
#pragma clang diagnostic pop
            NSString *initialValue = nil;
            
            if ([cell isKindOfClass:[NSButtonCell class]]) {
                if ([(NSButtonCell *)cell imagePosition] == NSImageOnly) {
                    switch ([(NSButtonCell *)cell state]) {
                        case NSControlStateValueOn: initialValue = @"Yes"; break;
						case NSControlStateValueOff: initialValue = @"No"; break;
						case NSControlStateValueMixed: initialValue = @"Mixed"; break;
                    }
                } else {
                    initialValue = [cell title];
                }
            }
            if (initialValue == nil && [cell respondsToSelector:@selector(title)]) {
                initialValue = [cell title];
            }
            if (initialValue == nil && [cell respondsToSelector:@selector(stringValue)]) {
                initialValue = [cell stringValue];
            }
            if (initialValue) {
                NSMutableString    *value = [initialValue mutableCopy];
                [value replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:(NSRange){0, [value length]}];
                [value replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:(NSRange){0, [value length]}];
                [string appendString:value];
                
                NSMutableString *style = [[NSMutableString alloc] initWithString:@"padding-left: 3px; padding-right: 3px;"];
                if (x < xMax - 1 && [self gridStyleMask] & NSTableViewSolidVerticalGridLineMask) {
                    [style appendString:@"border-right: 1px solid lightgray;"];
                }
                if (y < yMax - 1 && [self gridStyleMask] & NSTableViewSolidHorizontalGridLineMask) {
                    [style appendString:@"border-bottom: 1px solid lightgray;"];
                }
                if (y < yMax - 1 && [self gridStyleMask] & NSTableViewDashedHorizontalGridLineMask) {
                    [style appendString:@"border-bottom: 1px dotted lightgray;"];
                }
                if (y % 2 && [self usesAlternatingRowBackgroundColors]) {
                    [style appendString:@"background-color:#EFF2F7;"];
                }
                
                if ([style length]) {
                    style = [NSMutableString stringWithFormat:@" style=\"%@\"", style];
                }
                
                value = [initialValue mutableCopy];
                [value replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:(NSRange){0, [value length]}];
                [value replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:(NSRange){0, [value length]}];
                [value replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:(NSRange){0, [value length]}];
                [value replaceOccurrencesOfString:@"\n" withString:@"<br/>" options:NSCaseInsensitiveSearch range:(NSRange){0, [value length]}];
                [html appendFormat:@"<td%@>%@</td>", style, value];
            }
            [string appendString:@"\t"];
        }
        [string appendString:@"\n"];
        [html appendString:@"</tr>"];
    }
    [html appendString:@"</table><br/>"];
    
	[pasteboard declareTypes:@[NSPasteboardTypeString, NSPasteboardTypeTabularText, NSPasteboardTypeHTML] owner:self];
	[pasteboard setString:string forType:NSPasteboardTypeString];
	[pasteboard setString:string forType:NSPasteboardTypeTabularText];
	[pasteboard setString:html forType:NSPasteboardTypeHTML];
}

- (void)setSearchString:(NSString *)searchString {
    [self setInstanceObject:searchString forKey:@"__search_string__"];
}

- (NSString *)searchString {
    return [self instanceObjectForKey:@"__search_string__"];
}

- (void)_sendDelayedAction {
    [NSApp sendAction:[self action] to:[self target] from:self];
}

- (void)_performSelection:(NSUInteger)row {
    id delegate = [self delegate];
    NSNotification *notification;
    
    if ([delegate respondsToSelector:@selector(selectionShouldChangeInTableView:)]) {
        if (![delegate selectionShouldChangeInTableView:self]) return;
    }
    if ([delegate respondsToSelector:@selector(tableView:shouldSelectRow:)]) {
        if (![delegate tableView:self shouldSelectRow:row]) return;
    }
    notification = [NSNotification notificationWithName:NSTableViewSelectionIsChangingNotification object:self];
    if ([delegate respondsToSelector:@selector(tableViewSelectionIsChanging:)]) {
        [delegate tableViewSelectionIsChanging:notification];
    }
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [self scrollRowToVisible:row];

    notification = [NSNotification notificationWithName:NSTableViewSelectionIsChangingNotification object:self];
    if ([delegate respondsToSelector:@selector(tableViewSelectionDidChange:)]) {
        [delegate tableViewSelectionDidChange:notification];
    }
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self performSelector:@selector(_sendDelayedAction) withObject:nil afterDelay:AJRClearSearchDelay];
}

- (NSTimeInterval)_lastSearchTime {
    NSNumber *value = [self instanceObjectForKey:@"__last_search_time__"];
    if (value) return [value doubleValue];
    return [[NSDate distantPast] timeIntervalSinceReferenceDate];
}

- (void)_noteSearchTime {
    [self setInstanceObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"__last_search_time__"];
}

- (void)_checkHUDDismissal {
    if ([NSDate timeIntervalSinceReferenceDate] - [self _lastSearchTime] > AJRClearSearchDelay) {
        [[self typeAheadHUDWindow] orderOut:self];
    } else {
        [self performSelector:@selector(_checkHUDDismissal) withObject:nil afterDelay:AJRClearSearchDelay / 4.0];
    }
}

- (void)_updateSearchForCharacter:(unichar)character {
    NSTimeInterval lastSearchTime = [self _lastSearchTime];
    NSString *searchString = [self searchString];
    NSIndexSet *indexes = nil;
    
    AJRPrintf(@"DEBUG: search (%.1f): %@", [NSDate timeIntervalSinceReferenceDate] - lastSearchTime, searchString);
    
    if ([NSDate timeIntervalSinceReferenceDate] - lastSearchTime >= AJRClearSearchDelay) {
        searchString = AJRFormat(@"%lc", character);
    } else {
        searchString = AJRFormat(@"%@%lc", searchString ? searchString : @"", character);
    }
    
    if ([searchString length]) {
        NSWindow *HUD;
        
        [self setSearchString:searchString];
        indexes = [(id)[self delegate] tableView:self rowsForSearchString:searchString];
        AJRPrintf(@"DEBUG: rows = %@", indexes);
        
        HUD = [self typeAheadHUDWindow];
        if (![HUD isVisible]) {
            NSScrollView *scrollView = [self enclosingScrollView];
            NSPoint origin;
            
            origin.x = 5.0;
            origin.y = [scrollView frame].size.height;
            origin = [[scrollView window] ajr_convertPointToScreen:[scrollView convertPoint:origin toView:nil]];
            origin.y = origin.y - [HUD frame].size.height + 1.0;
            [HUD setFrameOrigin:origin];
            [HUD orderFront:self];
        }
        [(AJRHUDView *)[HUD contentView] setStringValue:searchString];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_checkHUDDismissal) object:nil];
        [self performSelector:@selector(_checkHUDDismissal) withObject:nil afterDelay:AJRClearSearchDelay];
    } else {
        [self setSearchString:nil];
    }
    
    [self _noteSearchTime];
    
    if ([indexes count] > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_sendDelayedAction) object:nil];
        if ([self allowsMultipleSelection]) {
        } else {
            [self _performSelection:[indexes firstIndex]];
        }
    }
}

- (void)ajr_keyDown:(NSEvent *)event {
    NSString *characters;
    unichar character;
    
    if ([self _isPartOfComboBox]) {
        [self ajr_keyDown:event];
        return;
    }
    
    // don't do anything if disabled
    if (![self isEnabled])
        return;
    
    characters = [event charactersIgnoringModifiers];
    if ([characters length] != 1) {
        // Should never be true for a keyDown:, but we'll be paranoid
        [self ajr_keyDown:event];
        return;
    }
    
    character = [characters characterAtIndex:0];
    //AJRPrintf(@"%C: Character: 0x%04x\n", self, character);
    switch (character) {
        case UNICODE_DELETE_BACK:
        case UNICODE_DELETE:
            if ([self _deleteKeyPressed]) {
                return;
            }
            break;
        default:
            break;
    }
    
    if (character <= 31) {
        [self ajr_keyDown:event];
        return;
    }    

    if ([[self delegate] respondsToSelector:@selector(tableView:rowsForSearchString:)]) {
        [self _updateSearchForCharacter:character];
    } else {
        [self ajr_keyDown:event];
    }
}

#pragma mark HUD

- (NSWindow *)typeAheadHUDWindow {
    NSWindow *window = [self instanceObjectForKey:@"__type_hud__"];
    
    if (window == nil) {
        NSView *contentView;
        
        window = [[NSWindow alloc] initWithContentRect:(NSRect){{0.0}, {50.0, 21.0}} styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
        [window setLevel:NSPopUpMenuWindowLevel];
        contentView = [[AJRHUDView alloc] initWithFrame:(NSRect){{0.0, 0.0}, [window frame].size}];
        [window setContentView:contentView];
        
        [self setInstanceObject:window forKey:@"__type_hud__"];
    }
    
    return window;
}

@end


@implementation AJRHUDView

- (id)initWithContentRect:(NSRect)contentRect {
    if ((self = [super init])) {
        self.stringValue = @"";
        _attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       [NSFont systemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName,
                       nil];
    }
    return self;
}


@synthesize stringValue = _stringValue;
@synthesize attributes = _attributes;

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    
    [[NSColor colorWithCalibratedRed:0xFD / 255.0 green:0xFE / 255.0 blue:0xC8 / 255.0 alpha:1.0] set];
    NSRectFill(bounds);
    [[NSColor colorWithCalibratedWhite:0xAA / 255.0 alpha:1.0] set];
    NSFrameRect(bounds);
    
    [[NSColor blackColor] set];
    bounds = NSInsetRect(bounds, 5.0, 2.0);
    [_stringValue drawInRect:bounds withAttributes:_attributes];
}

- (void)setStringValue:(NSString *)stringValue {
    if (_stringValue != stringValue) {
        NSRect frame = [[self window] frame];
        
        if (stringValue == nil) {
            stringValue = @"";
        }
        _stringValue = stringValue;
        [self setNeedsDisplay:YES];

        frame.size.width = [_stringValue sizeWithAttributes:_attributes].width + 10.0;
        [[self window] setContentSize:frame.size];
    }
}

@end
