
#import <Cocoa/Cocoa.h>

@interface AJRHistogramView : NSView

@property (nonatomic,strong) NSDictionary *statistics;
@property (nonatomic,strong) NSFont *labelFont;
@property (nonatomic,assign) NSInteger SLA;
@property (nonatomic,strong) NSColor *SLAColor;
@property (nonatomic,strong) NSColor *borderColor;
@property (nonatomic,strong) NSColor *backgroundColor;

@end
