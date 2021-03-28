
#import "AJRSectionViewItem.h"

@implementation AJRSectionViewItem

- (id)initWithView:(NSView *)view sectionView:(AJRSectionView *)sectionView {
    if ((self = [super init])) {
        self.view = view;
        _viewFrame = [view frame];
        self.expanded = YES;
        self.sectionView = sectionView;
    }
    return self;
}


#pragma mark Properties

@synthesize view = _view;
@synthesize title = _title;
@synthesize viewFrame = _viewFrame;
@synthesize expanded = _expanded;
@synthesize sectionView = _sectionView;

#pragma mark Utility Methods

- (NSSize)desiredSize {
    if (self.expanded) {
        return _viewFrame.size;
    }
    return NSZeroSize;
}

- (void)setHeight:(CGFloat)height {
    _viewFrame.size.height = height;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object {
    return self == object;
}

- (NSUInteger)hash {
    return (NSUInteger)self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _view = [coder decodeObjectForKey:@"view"];
        _title = [coder decodeObjectForKey:@"title"];
        _viewFrame = [coder decodeRectForKey:@"viewFrame"];
        _expanded = [coder decodeBoolForKey:@"expanded"];
        _sectionView = [coder decodeObjectForKey:@"sectionView"]; // Not retained.
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
    [coder encodeObject:_view forKey:@"view"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeRect:_viewFrame forKey:@"viewFrame"];
    [coder encodeBool:_expanded forKey:@"expanded"];
    [coder encodeObject:_sectionView forKey:@"sectionView"];
}

@end
