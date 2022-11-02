/*
 NSTableView+Dragging.h
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

/*!
 @header NSTableView+Dragging.h
 @discussion Defines the methods and constants used for table row reordering as well as implemented row deletion methods.
 */

#import <AppKit/AppKit.h>

/*!
 @discussion This is broadcast at the end of a move, if a row actually changed positions. The object will be the table view and the user info will have two keys, NSTableViewStartingRowIndexKey and NSTableViewEndingRowIndexKey.
 */
extern NSString *NSTableViewDidMoveRowNotification;

/*!
 @discussion Used as keys to the user info of the NSTableViewDidMoveRowNotification.
 */
extern NSString *NSTableViewStartingRowIndexKey;

/*!
 @discussion Used as keys to the user info of the NSTableViewDidMoveRowNotification.
 */
extern NSString *NSTableViewEndingRowIndexKey;

/*!
 @discussion Used as keys to the user info of the NSTableViewDidMoveRowNotification.
 */
extern NSString *NSTableViewEndingRowIndexKey;

/*!
 @discussion Notification sent when the user presses the delete key.
 */
extern NSString *NSTableViewDeleteKeyPressedNotification;

/*!
 @discussion When receiving a NSTableViewDeleteKeyPressedNotification, this defines the selection in the notification's userInfo dictionary.
 */
extern NSString *NSTableViewSelectionKey;

/*!
 @discussion Methods implemented by the table view's delegate to intervene in row reordering.
 */
@interface NSObject (AJRAdditonalTableViewDelegates)

/*!
 @abstract Delegate method to reorder rows in your datasource when the table reorders rows.
 @discussion Have your delegate implement this method if you want to allow rows to reorder. This method does one of two things. First, if it allows it, it reorders it's own representation of the rows and returns YES. This allows the table view to move the rows in real time while the user drags.
 
 If the delegate does not want the table view to re-order the rows, then it should just return NO from this method and the rows will not re-arrange.
*/
- (BOOL)tableView:(NSTableView *)tableView moveRowAtIndex:(NSUInteger)index toIndex:(NSUInteger)otherIndex;

/*!
 @abstract Delegate method to allow/disallow row dragging.
 @discussion Implement this method if you want to sometimes (or always) prevent the rows in a table view from being move.  You can use this if you have a class which is a delegate of multiple table views, and you only want some of them to have rows which are movable.  You can also use it if a table view can only have its rows rearranged sometimes.  Return YES to allow rows to be moved, or NO if rows cannot be moved for the given table view.  If you implement tableView:moveRowAtIndex:toIndex:, and do not implement this method, YES is ajrsumed.
 */
- (BOOL)tableViewShouldMoveRows:(NSTableView *)tableView;

/*!
 @discussion If the delegate implements this method, it will be called at the end of the row rearrangement (after the mouse button is released).
 */
- (void)tableViewDidMoveRow:(NSTableView *)tableView;

/*!
 @discussion Sent by the table view just prior to deleting a row. If the delegate wishes to block the deletion, it should return NO from this method. Otherwise, returning YES will delete the row. Note that the delegate should also implement -tableView:deleteRowAtIndex: to do the actual deletion.
 */
- (BOOL)tableView:(NSTableView *)tableView shouldDeleteRowsAtIndexes:(NSIndexSet *)indexSet;

/*!
 @discussion Sent when the user tries to delete a row. If the delegate can, it should delete the row at index from its data source and return YES, otherwise the delegate should return NO.
 */
- (BOOL)tableView:(NSTableView *)tableView deleteRowsAtIndexes:(NSIndexSet *)indexSet;

/*!
 @discussion Sent by the table after a row has been deleted. Note that this is only informative. Once this method is called, the deleted rows no longer exist in the table view.
 */
- (void)tableView:(NSTableView *)tableView didDeleteRowsAtIndexes:(NSIndexSet *)indexSet;

/*!
 @discussion As the user types, this delegate message is sent to the delegate. The delegate can then return a list of row indexes it would like the table view to select. Selection will trigger other valid delegate methods to be called.
 */
- (NSIndexSet *)tableView:(NSTableView *)tableView rowsForSearchString:(NSString *)searchString;

@end

/*!
 @abstract Category to add a couple methods in support of table row dragging.
 @discussion This category adds methods used when the table drags rows. These are basically some convenience methods on top of other table methods that make doing stuff like drawing rows much easier.
 */
@interface NSTableView (Dragging)

/*!
 @discussion Draws the table row specified by rowIndex. This is drawn into the table's view, so you cannot use this method to draw a row wherever you'd like.
 */
- (void)drawRow:(NSUInteger)rowIndex;

/*!
 @discussion Triggers drawing all rows that intersect rect.
 */
- (void)drawRowsUnderRect:(NSRect)rect;

/*!
 @abstract This method implements row dragging behavior.
 @discussion When you want the table to start dragging a row, you call this method with the event that initiated the event. Event should be some kind of mouse event, as the row to be dragged will be determined by the mouse's location. This method will call various delegate method to allow the table's delegate to intervene in the drag operation.
 @seealso -tableViewShouldMoveRows:
 @seealso -tableViewDidMoveRow:
 @seealso -tableView:moveRowAtIndex:toIndex:
 */
- (void)dragFromEvent:(NSEvent *)event;

@end
