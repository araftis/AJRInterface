
#import "AJRMultiViewController.h"

static NSMutableDictionary *_subviewControllerClasses = nil;

@implementation AJRMultiViewController

+ (void)initialize {
    if (_subviewControllerClasses == nil) {
        _subviewControllerClasses = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerEditor:(Class)editorClass forName:(NSString *)name {
    @synchronized (_subviewControllerClasses) {
        NSMutableDictionary *classes = [_subviewControllerClasses objectForKey:NSStringFromClass([self class])];
        
        if (classes == nil) {
            classes = [[NSMutableDictionary alloc] init];
            [_subviewControllerClasses setObject:classes forKey:NSStringFromClass([self class])];
        }
        
        [classes setObject:editorClass forKey:name];
    }
}

+ (NSArray *)viewControllerNames {
    @synchronized (_subviewControllerClasses) {
        return [[[_subviewControllerClasses objectForKey:NSStringFromClass([self class])] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }
    return nil;
}

+ (Class)viewControllerClassForName:(NSString *)name {
    @synchronized (_subviewControllerClasses) {
        return [[_subviewControllerClasses objectForKey:NSStringFromClass([self class])] objectForKey:name];
    }
    return nil;
}

- (id)init {
    if ((self = [super init])) {
        _viewControllers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@synthesize autosaveName = _autosaveName;
@synthesize rootController = _rootController;
@synthesize selectorControl = _selectorControl;

- (void)setAutosaveName:(NSString *)autosaveName {
    BOOL restore = _autosaveName == nil;

    if (_autosaveName != autosaveName) {
        _autosaveName = autosaveName;
        
        if (restore) {
            [self selectViewAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:_autosaveName]];
        }
    }
}

- (NSViewController *)viewControllerForName:(NSString *)name {
    NSViewController *viewController = nil;
    
    @synchronized (_viewControllers) {
        viewController = [_viewControllers objectForKey:name];
        if (viewController == nil) {
            Class    class = [[self class] viewControllerClassForName:name];
            if (class) {
                viewController = [[class alloc] init];
                [viewController setTitle:name];
                [_viewControllers setObject:viewController forKey:name];
            }
        }
    }
    
    return viewController;
}

- (void)selectViewWithName:(NSString *)name {
    [self selectViewAtIndex:[[[self class] viewControllerNames] indexOfObject:name]];
}

- (void)selectViewAtIndex:(NSUInteger)index {
    _selectedViewIndex = index;
    if (self.autosaveName) {
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:self.autosaveName];
    }
}

- (IBAction)selectView:(id)sender {
    if ([sender isKindOfClass:[NSPopUpButton class]]) {
        [self selectViewAtIndex:[(NSPopUpButton *)sender indexOfSelectedItem]];
    } else if ([sender isKindOfClass:[NSMenuItem class]]) {
        [self selectViewWithName:[(NSMenuItem *)sender title]];
    } else if ([sender isKindOfClass:[NSMatrix class]]) {
        [self selectViewAtIndex:[[(NSMatrix *)sender selectedCell] tag]];
    } else if ([sender isKindOfClass:[NSSegmentedControl class]]) {
        [self selectViewAtIndex:[(NSSegmentedControl *)sender selectedSegment]];
    }
}

- (void)setupMenu:(NSMenu *)menu {
}

- (void)setupSegmentControl:(NSSegmentedControl *)segments {
}

- (void)setupPopUpButton:(NSPopUpButton *)popUpButton
{
    [popUpButton removeAllItems];
    for (NSString *name in [[self class] viewControllerNames]) {
        NSViewController *controller = [self viewControllerForName:name];
        NSMenuItem *item;
        
        [popUpButton addItemWithTitle:[controller title]];
        item = [[popUpButton itemArray] lastObject];
        [item setRepresentedObject:[controller title]];
    }
}

- (void)setupSelectorControl:(NSControl *)control {
    if ([control isKindOfClass:[NSMenu class]]) {
        [self setupMenu:(NSMenu *)control];
    } else if ([control isKindOfClass:[NSSegmentedControl class]]) {
        [self setupSegmentControl:(NSSegmentedControl *)control];
    } else if ([control isKindOfClass:[NSPopUpButton class]]) {
        [self setupPopUpButton:(NSPopUpButton *)control];
    }
}

- (void)setSelectorControl:(NSControl *)control {
    [self setupSelectorControl:control];
    [control setTarget:self];
    [control setAction:@selector(selectView:)];
}

- (NSUInteger)selectedViewIndex {
    return _selectedViewIndex;
}

@end
