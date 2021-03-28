
#import <Cocoa/Cocoa.h>

@interface AJRPieChart : NSView 
{
    NSInteger _currentColor;
    NSColor *_backgroundColor;
    NSString *_backgroundLabel;
    NSMutableArray *_keys;
    NSMutableDictionary *_values;
    NSMutableDictionary *_displayValues;
    NSMutableDictionary *_colors;
    double _totalValue;
    NSFormatter *_valueFormatter;
    NSFont *_font;
    NSMutableDictionary *_attributes;
    NSMutableDictionary *_boldAttributes;
    
    BOOL _showKey;
    BOOL _showValues;
}

@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSString *backgroundLabel;
@property (nonatomic,assign) double totalValue;
@property (nonatomic,strong) NSFormatter *valueFormatter;
@property (nonatomic,strong) NSFont *font;
@property (nonatomic,assign) BOOL showKey;
@property (nonatomic,assign) BOOL showValues;

- (void)addValue:(CGFloat)value forKey:(NSString *)key;
- (void)addValue:(CGFloat)value forKey:(NSString *)key withColor:(NSColor *)color;
- (void)removeKey:(NSString *)key;

- (NSColor *)colorForKey:(NSString *)key;
- (void)setColor:(NSColor *)color forKey:(NSString *)key;
- (double)floatValueForKey:(NSString *)key;
- (void)setFloatValue:(double)value forKey:(NSString *)key;
- (double)displayValueForKey:(NSString *)key;
- (void)setDisplayValue:(double)value forKey:(NSString *)key;

@end
