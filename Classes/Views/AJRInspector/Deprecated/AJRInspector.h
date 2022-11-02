/*
 AJRInspector.h
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

#import <AppKit/AppKit.h>

@class AJRInspectorModule, AJRBox;

@interface AJRInspector : NSObject <NSToolbarDelegate, NSWindowDelegate> {
    IBOutlet NSPanel *window;
    IBOutlet NSBox *box;
    IBOutlet NSMatrix *buttons;
    IBOutlet NSImageView *icon;
    IBOutlet NSTextField *title;
    
    IBOutlet NSView *emptySelectionView;
    IBOutlet NSView *multipleSelectionView;
    
    NSMutableArray *inspectors;
    AJRInspectorModule *inspector;
}

+ (id)sharedInstance;

- (id)init;
// After initializing, uses an AJRObjectBroker to find all AJRInspectorModule
// subclasses as specified by the inspectorClass method.  For each
// class found, addInspector is called.  If inspectorClass returns
// nil a NSInternalInconsistencyException exception is raised.

- (NSWindow *)window;

- (NSView *)emptySelectionView;
- (NSView *)multipleSelectionView;
// NSViews that are used by AJRInspectorModule subclasses when either nothing is
// selected or multiple items are selected and the AJRInspectorModule subclass
// does not handle that case.

- (AJRInspectorModule *)inspector;
- (BOOL)setInspector:(AJRInspectorModule *)anInspector;
// Accessor methods for the current inspector.  Returns YES if anInspector
// is already the current inspector or upon successful "switch" to
// anInspector.  Returns NO if the current inspector won't allow switching
// (see AJRInspector's inspectorControllerShouldSwitchInspectorPanel).
// Does not update the inspector panel - see updateInspectorSelection. 

- (Class)inspectorClass;
// Returns the respective AJRInspectorModule subclass for this AJRInspector.
// Default implementation returns nil.
// Override this so that AJRInspector subclasses will only get their
// respective AJRInspectorModule subclass.  i.e. OMOfferInspectorController is only
// interested in OMOfferInspector objects

- (void)addInspector:(Class)anInspectorClass;
// Instantiates and places the specified AJRInspectorModule subclass under this
// AJRInspectorController's control.

- (void)addInspectorMenu:(NSMenu *)aMenu;
- (void)addInspectorMenu:(NSMenu *)aMenu withMenuItemTarget:(id)target andMenuItemAction:(SEL)action;
// Adds a submenu of all AJRInspectorModule subclasses to aMenu, using each AJRInspectorModule
// subclass's title method as the menu item label.  This should only be called
// after all addInspector method calls.  Short version sets menu items target
// and action to automatically be handled by this AJRInspector.  Long
// version sets target and action to values given.

- (void)showInspectorPanel;
// Calls updateInspectorSelection, updateButtonsAndPopup, and makes window key
// and orders front.
- (void)showInspectorPanel:(id)sender;
// Calls selectInspector, passing sender, and makes window key and orders front.
// This method is the action for menu items created via addInspectorMenu method.

- (void)selectInspector:(id)sender;
// Uses sender's tag to set the current inspector (if allowed to switch) and
// if successful, updates the inspector.  Also syncs the button matrix and
// popup button.
- (BOOL)selectInspectorAtIndex:(NSUInteger)index;
// Sets the current inspector to the one specified by index (if allowed
// to switch - see setInspector) and updates the inspector, button matrix,
// and popup button.  If the window is not visiable, orders the window
// front.  Returns YES upon successful switch, NO otherwise.
- (BOOL)selectInspectorWithTitle:(NSString *)title;
// Finds the index of the inspector with the given title and then uses
// selectInspectorAtIndex to select the appropriate inspector.  Returns
// YES upon successful switch, NO otherwise.

- (void)updateInspectorSelection;
// Sets the current inspector's selection, updates the current panel, and
// tells the inspector to update.
- (void)updateButtonsAndPopup;
// Updates the button matrix and popup button to select to the corresponding
// current inspector.

- (BOOL)windowShouldClose:(id)sender;
// Asks the current inspector if it is okay to close the inspector.
// See AJRInspector's inspectorControllerShouldSwitchInspectorPanel method.

- (NSString *)orderKeyName;
// Returns the user defaults key that specifies the order the buttons are
// in the button matrix.  Format is <inspectorClass>ControllerOrderKey,
// where <inspectorClass> is the name of the class returned by the
// inspectorClass method.
- (void)sortCells;
// Sorts the buttons in the button matrix according to the order saved in
// the user defaults under the key specified by the orderKeyName method.
// Order is saved to the user defaults whenever the user moves a button
// in the button matrix.

- (NSMatrix *)buttons;

@end
