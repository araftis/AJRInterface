
#import <AppKit/AppKit.h>
#import <AJRInterface/AJRLabelCell.h>

@interface AJRLabel : NSTextField
{
}

+ (void)initialize;
+ (void)setCellClass:(Class)classId;

- (id)initWithFrame:(NSRect)frameRect;

- (NSArray *)renderers;
- (NSUInteger)renderersCount;
- (AJRPathRenderer *)rendererAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfRenderer:(AJRPathRenderer *)renderer;
- (AJRPathRenderer *)lastRenderer;
- (void)addRenderer:(AJRPathRenderer *)renderer;
- (void)insertRenderer:(AJRPathRenderer *)renderer atIndex:(NSUInteger)index;
- (void)removeRendererAtIndex:(NSUInteger)index;
- (void)removeRenderersAtIndexes:(NSIndexSet *)indexes;
- (void)moveRendererAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (IBAction)takeAlignmentFrom:(id)sender;

@end

