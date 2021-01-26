
#import "AJRFill.h"

static NSMutableDictionary *_fills = nil;
static NSMutableDictionary *_fillsByName = nil;
static NSMutableDictionary *_fillViews = nil;

NSString *AJRFillDidUpdateNotification = @"AJRFillDidUpdateNotification";
NSString *AJRFillWillUpdateNotification = @"AJRFillWillUpdateNotification";

@implementation AJRFill

+ (void)initialize {
    if (_fills == nil) {
        _fills = [[NSMutableDictionary alloc] init];
        _fillsByName = [[NSMutableDictionary alloc] init];
        _fillViews = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerFill:(Class)aClass {
    @autoreleasepool {
        [_fills setObject:aClass forKey:NSStringFromClass(aClass)];
        [_fillsByName setObject:aClass forKey:[aClass name]];
    }
}

+ (NSString *)name {
    return @"None";
}

- (void)willUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRFillWillUpdateNotification object:self];
}

- (void)didUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRFillDidUpdateNotification object:self];
}

+ (NSArray *)fillTypes {
    return [[_fills allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray *)fillNames {
    return [[_fillsByName allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (AJRFill *)fillForType:(NSString *)type {
    Class aClass = [_fills objectForKey:type];
    
    if (aClass) return [[aClass alloc] init];
    
    return [[[self class] alloc] init];
}

+ (AJRFill *)fillForName:(NSString *)type {
    Class aClass = [_fillsByName objectForKey:type];
    
    if (aClass) return [[aClass alloc] init];
    
    return [[[self class] alloc] init];
}

- (void)fillPath:(NSBezierPath *)aPath {
}

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView {
}

- (void)fillRect:(NSRect)aRect {
    [self fillRect:aRect controlView:nil];
}

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView {
    [self fillPath:[NSBezierPath bezierPathWithRect:rect] controlView:controlView];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}

- (BOOL)isOpaque {
    return YES;
}

@end
