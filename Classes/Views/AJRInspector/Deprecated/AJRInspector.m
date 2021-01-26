
#import "AJRInspector.h"
#import "AJRInspectorModule.h"
#import <AJRInterface/AJRBox.h>
#import <AJRFoundation/AJRFunctions.h>
#import <Foundation/NSArray.h>

@implementation AJRInspector

static NSLock    *_sortLock = nil;

+ (void)initialize
{
    _sortLock = [[NSLock alloc] init];
}

+ (id)sharedInstance
{
    return [[self alloc] init];
}

- (id)init
{
    if (!window) {
        Class   inspectorClass;
        
        if (![[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self topLevelObjects:NULL]) {
            if (![[NSBundle bundleForClass:[AJRInspector class]] loadNibNamed:@"AJRInspector" owner:self topLevelObjects:NULL]) {
                [NSException raise:NSInternalInconsistencyException format:@"Could not load nib: %@", NSStringFromClass([self class])];
            }
        }
        [window setFrameAutosaveName:NSStringFromClass([self class])];
        [window setFrameUsingName:NSStringFromClass([self class])];
        [window setHidesOnDeactivate:YES];
        [window setDelegate:self];
        
        // remove any buttons or items in pop up button saved in nib file
        while ([buttons numberOfRows]) {
            [buttons removeRow:[buttons numberOfRows] - 1];
        }
        
        inspectorClass = [self inspectorClass];
        if (inspectorClass) {
            inspectors = [[NSMutableArray allocWithZone:nil] init];
            
            [buttons setCellSize:(NSSize){64, 64}];
            [buttons setFrame:(NSRect){{0, 0}, {64, 64 * [[buttons cells] count]}}];
            [self sortCells];
            
            [self setInspector:[inspectors objectAtIndex:[[buttons cellAtRow:0 column:0] tag]]];
            [self updateInspectorSelection];
        } else {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Subclasses of AJRInspector should return a valid value from -[inspectorClass:]."];
        }
    }
    
    return self;
}


- (NSWindow *)window
{
    return window;
}

- (NSView *)emptySelectionView
{
    return emptySelectionView;
}

- (NSView *)multipleSelectionView
{
    return multipleSelectionView;
}

- (BOOL)setInspector:(AJRInspectorModule *)anInspector
{
    BOOL    result = YES;
    
    if (inspector != anInspector) {
        if (inspector) {
            result = [inspector inspectorShouldSwitchView:self];
        }
        if (result) {
            inspector = anInspector;
            [icon setImage:[inspector icon]];
            [title setStringValue:[NSString stringWithFormat:@"%@ Inspector", [inspector title]]];
        }
    }
    
    return result;
}

- (AJRInspectorModule *)inspector
{
    return inspector;
}

- (Class)inspectorClass
{
    return nil;
}

- (void)addInspector:(Class)anInspectorClass
{
    AJRInspectorModule   *anInspector = [[anInspectorClass allocWithZone:nil] init];
    
    [inspectors addObject:anInspector];
    [anInspector setInspectorController:self];
    
    if ([anInspector icon]) {
        NSButtonCell   *cell;
        
        [buttons addRow];
        cell = (NSButtonCell *)[[buttons cells] lastObject];
        [cell setTag:[inspectors count] - 1];
        [cell setImage:[anInspector icon]];
        [cell setBordered:NO];
        [cell setTitle:[anInspector title]];
        [cell setImagePosition:NSImageAbove];
    }
    
    AJRPrintf(@"INFO: Inspector: %@ (%@)", anInspectorClass, [anInspector title]);
}


- (void)addInspectorMenu:(NSMenu *)aMenu withMenuItemTarget:(id)target andMenuItemAction:(SEL)action
{
    NSMenuItem        *menuItem;
    NSMenu            *menu;
    NSUInteger        index;
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Inspector"
                                          action:NULL
                                   keyEquivalent:@""];
    menu = [[NSMenu alloc] initWithTitle:@"Inspector"];
    [menuItem setTag:-1];
    [menuItem setSubmenu:menu];
    if (target == self) {
        [menu setAutoenablesItems:NO];
    }
    [aMenu addItem:menuItem];
    
    for (index = 0; index < [inspectors count]; index++) {
        menuItem = [[NSMenuItem alloc] initWithTitle:[[inspectors objectAtIndex:index] title]
                                              action:NULL
                                       keyEquivalent:[NSString stringWithFormat:@"%lu", (index + 1)]];
        [menuItem setImage:[[inspectors objectAtIndex:index] icon]];
        [menuItem setTarget:target];
        [menuItem setAction:action];
        [menuItem setTag:index];
        [menu addItem:menuItem];
    }
}

- (void)addInspectorMenu:(NSMenu *)aMenu
{
    [self addInspectorMenu:aMenu withMenuItemTarget:self andMenuItemAction:@selector(showInspectorPanel:)];
}


- (void)showInspectorPanel
{
    [self updateInspectorSelection];
    [self updateButtonsAndPopup];
    [window makeKeyAndOrderFront:self];
}

- (void)showInspectorPanel:(id)sender
{
    [self selectInspector:sender];
    [window makeKeyAndOrderFront:sender];
}


- (void)selectInspector:(id)sender
{
    NSInteger   index;
    
    if (sender == buttons) {
        index = [[sender selectedCell] tag];
    } else if ([sender isKindOfClass:[NSMenuItem class]]) {
        index = [sender tag];
    } else {
        index = [sender indexOfSelectedItem];
    }
    
    if ([self setInspector:[inspectors objectAtIndex:index]]) {
        [self updateInspectorSelection];
    }
    [self updateButtonsAndPopup];
}

- (BOOL)selectInspectorAtIndex:(NSUInteger)index
{
    BOOL    result = NO;
    
    if (index < [inspectors count]) {
        result = [self setInspector:[inspectors objectAtIndex:index]];
        if (result) {
            [self updateInspectorSelection];
        }
        [self updateButtonsAndPopup];
        
        if (![window isVisible]) {
            [window orderFront:self];
        }
    }
    
    return (result);
}

- (BOOL)selectInspectorWithTitle:(NSString *)aTitle
{
    BOOL    result = NO;
    
    if (aTitle) {
        NSInteger    index;
        
        for (index = 0; index < (const NSInteger)[inspectors count]; index++) {
            if ([[[inspectors objectAtIndex:index] title] isEqualToString:aTitle]) {
                result = [self selectInspectorAtIndex:index];
                index = [inspectors count];
            }
        }
    }
    
    return (result);
}


- (void)updateInspectorSelection
{
    NSView   *view;
    
    view = [inspector view];
    if ([box contentView] != view) {
        NSSize        oldSize = [(NSView *)[box contentView] frame].size;
        NSSize        newSize = [view frame].size;
        
        if (!NSEqualSizes(oldSize, newSize)) {
            NSSize    delta = { oldSize.width-newSize.width, oldSize.height-newSize.height };
            NSRect    frame = [window frame];
            
            frame.size.width -= delta.width;
            frame.size.height -= delta.height;
            frame.origin.y += delta.height;
            [box setContentView:nil];
            [window setFrame:frame display:YES animate:YES];
            [box setContentView:view];
        } else {
            [box setContentView:view];
        }
    }
    [inspector update];
}

- (void)updateButtonsAndPopup
{
    NSUInteger    index = [inspectors indexOfObject:inspector];
    
    if (index != NSNotFound) {
        //[buttons selectCellAtRow:index column:0];
    }
}


- (BOOL)windowShouldClose:(id)sender
{
    BOOL    result = YES;
    
 /*  if ([sender isEqual:window])
  {
  if (inspector)
  {
  result = [inspector inspectorControllerShouldSwitchInspectorPanel];
  }
  }*/
    
    return (result);
}


// NSMatrix delegate methods
- (BOOL)matrix:(NSMatrix *)matrix canMoveCell:(NSCell *)aCell
         atRow:(NSUInteger)row column:(NSUInteger)column
         toRow:(NSUInteger)newRow column:(NSUInteger)newColumn
{
    return YES;
}


- (void)matrix:(NSMatrix *)matrix didMoveCell:(NSCell *)aCell
         atRow:(NSUInteger)row column:(NSUInteger)column
         toRow:(NSUInteger)newRow column:(NSUInteger)newColumn
{
    NSString   *orderKeyName = [self orderKeyName];
    
    if (orderKeyName) {
        NSArray               *cells = [buttons cells];
        NSMutableArray    *inspectorNames = [[NSMutableArray allocWithZone:nil] initWithCapacity:[cells count]];
        NSInteger                    index;
        
        for (index = 0; index < (const NSInteger)[cells count]; index++) {
            [inspectorNames addObject:[[[inspectors objectAtIndex:[[cells objectAtIndex:index] tag]] class] description]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:inspectorNames forKey:orderKeyName];
    }
}

// Note: If you use either of this variables, make sure to call [_sortLock lock] and [_sortLock unlock] for thread safety.
static NSArray *_order = nil;
static NSArray *_inspectors = nil;

static NSComparisonResult cellSorter(NSCell *first, NSCell *second, AJRInspector *self)
{
    NSInteger        index1, index2;
    NSString    *name1 = [[[_inspectors objectAtIndex:[first tag]] class] description];
    NSString    *name2 = [[[_inspectors objectAtIndex:[second tag]] class] description];
    
    index1 = [_order indexOfObject:name1];
    index2 = [_order indexOfObject:name2];
    
    if ((index1 == NSNotFound) && (index2 != NSNotFound)) return NSOrderedDescending;
    if ((index1 != NSNotFound) && (index2 == NSNotFound)) return NSOrderedAscending;
    if ((index1 == NSNotFound) && (index2 == NSNotFound)) return [name1 compare:name2];
    
    if (index1 < index2) return NSOrderedAscending;
    if (index1 > index2) return NSOrderedDescending;
    
    return NSOrderedSame;
}


- (NSString *)orderKeyName
{
    NSString   *name = nil;
    
    if ([self inspectorClass]) {
        name = [NSString stringWithFormat:@"%@OrderKey", NSStringFromClass([self class])];
    }
    
    return name;
}

- (void)sortCells
{
    NSString   *orderKeyName = [self orderKeyName];
    
    if (orderKeyName) {
        
        [_sortLock lock];
        _order = [[NSUserDefaults standardUserDefaults] stringArrayForKey:orderKeyName];
        
        if (_order) {
            _inspectors = inspectors;
            [buttons sortUsingFunction:(NSInteger (*)(id, id ,void *))cellSorter context:(__bridge void *)(self)];
            _order = nil;
            _inspectors = nil;
            [buttons setNeedsDisplay:YES];
        }
        
        [_sortLock unlock];
    }
}

- (NSMatrix *)buttons
{
    return buttons;
}

@end
