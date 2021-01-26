
#import "AJRFillInspector.h"

#import "AJRFill.h"
#import "AJRFillInspectorModule.h"
#import "NSBezierPath+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRFillInspector
{
	NSMutableDictionary *_inspectorModules;
	AJRFillInspectorModule *_inspectorModule;
	NSMutableDictionary *_dictionary;
}

#pragma mark - Creation

- (id)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {
        _inspectorModules = [[NSMutableDictionary alloc] init];
    
		[self setTitle:@""];
		[self setBoxType:NSBoxCustom];
		[self setTitlePosition:NSNoTitle];
		[self setTransparent:YES];
		[self setContentViewMargins:NSZeroSize];
	}
    return self;
}

#pragma mark - Properties

- (void)setFill:(AJRFill *)aFill {
    if (_fill != aFill) {
        _fill = aFill;
        
        if (_fill) {
            _inspectorModule = [_inspectorModules objectForKey:[[_fill class] name]];
            if (!_inspectorModule) {
                Class        class = NSClassFromString(AJRFormat(@"%@InspectorModule", NSStringFromClass([_fill class])));
                if (class) {
                    _inspectorModule = [[class alloc] init];
                    [_inspectorModules setObject:_inspectorModule forKey:[[_fill class] name]];
                }
            }
        } else {
            _inspectorModule = nil;
        }
        
        [self setContentView:[_inspectorModule view]];
    }
    
    [_inspectorModule setFill:_fill];
}

@end
