
#import "AJRPageLayout.h"

#import "AJRPagedView.h"

@implementation AJRPageLayout
{
    AJRPagedView *__weak _pagedView;
}

NSMutableDictionary *_pageLayouts = nil;

#pragma mark - Initialization

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pageLayouts = [[NSMutableDictionary alloc] init];
    });
}

#pragma mark - Factory

+ (void)registerPageLayout:(Class)class {
    [_pageLayouts setObject:class forKey:[class identifier]];
}

+ (NSArray *)pageLayoutIdentifiers {
    return [_pageLayouts allKeys];
}

+ (NSArray *)pageLayouts {
    return [_pageLayouts allValues];
}

+ (Class)pageLayoutForIdentifier:(NSString *)identifier {
    return [_pageLayouts objectForKey:identifier];
}

+ (id)pageLayoutForView:(AJRPagedView *)pagedView withIdentifier:(NSString *)identifier {
    return [[[self pageLayoutForIdentifier:identifier] alloc] initWithPagedView:pagedView];
}

+ (NSString *)identifier {
    return nil;
}

- (NSString *)identifier {
    return [[self class] identifier];
}

+ (NSString *)name {
    return nil;
}

#pragma mark - Creation

- (id)initWithPagedView:(AJRPagedView *)pagedView {
    if ((self = [super init])) {
        _pagedView = pagedView;
    }
    
    return self;
}

#pragma mark - Properties

- (AJRPagedView *)pagedView {
    return _pagedView;
}

- (NSInteger)pairedPageForPage:(NSInteger)pageNumber {
    return NSNotFound;
}

#pragma mark - Actions

- (void)updateConstraints {
}

#pragma mark - Utilities

- (id <AJRPagedViewDataSource>)pageDataSource {
    return [_pagedView pageDataSource];
}

- (CGFloat)verticalGap {
    return [_pagedView verticalGap];
}

- (CGFloat)horizontalGap {
    return [_pagedView horizontalGap];
}

- (void)getView:(NSView **)view forPage:(NSInteger)pageNumber {
    id <AJRPagedViewDataSource> document = [_pagedView pageDataSource];
    NSSize pageSize;
    CGFloat scale = [_pagedView scale];
    
    *view = [document pagedView:_pagedView viewForPage:pageNumber];
    pageSize = [document pagedView:_pagedView sizeForPage:pageNumber];
    [*view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [*view removeConstraints:[*view constraints]];
    
    pageSize.width *= scale;
    pageSize.height *= scale;
    
    // Width + Height
    [*view addConstraints:@[
        [[*view widthAnchor] constraintEqualToConstant:pageSize.width],
        [[*view heightAnchor] constraintEqualToConstant:pageSize.height],
    ]];
}

#pragma mark - Ruler Support

- (NSArray<NSView *> *)horizontalViews {
    return @[];
}

- (NSArray<NSView *> *)verticalViews {
    return @[];
}

@end
