/*!
 @header ServiceEditorManager.h

 @author A.J. Raftis
 @updated 12/10/08.
 @copyright 2008 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <AppKit/AppKit.h>

@interface AJRMultiViewController : NSViewController 
{
    NSString                *_autosaveName;
    NSMutableDictionary        *_viewControllers;
    NSController            *_rootController;
    NSControl                *_selectorControl;
    NSUInteger                _selectedViewIndex;
}

+ (void)registerEditor:(Class)editor forName:(NSString *)name;
+ (NSArray *)viewControllerNames;
+ (Class)viewControllerClassForName:(NSString *)name;

@property (nonatomic,strong) NSString *autosaveName;
@property (nonatomic,strong) IBOutlet NSController *rootController;
@property (nonatomic,strong) IBOutlet NSControl *selectorControl;

- (NSViewController *)viewControllerForName:(NSString *)name;

- (void)selectViewWithName:(NSString *)name;
- (void)selectViewAtIndex:(NSUInteger)index;
- (IBAction)selectView:(id)sender;

- (void)setupMenu:(NSMenu *)menu;
- (void)setupSegmentControl:(NSSegmentedControl *)segments;
- (void)setupPopUpButton:(NSPopUpButton *)popUpButton;
- (void)setupSelectorControl:(NSControl *)control;
- (NSUInteger)selectedViewIndex;

@end
