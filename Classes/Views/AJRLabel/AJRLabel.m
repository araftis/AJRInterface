
#import <AJRInterface/AJRLabel.h>

//static NSString* OM_version_info = @"Version Info: AJRLabel 3";
//__VERSION_SHUT_UP

@implementation AJRLabel

static Class cellClass;

+ (void)initialize
{
    cellClass = [AJRLabelCell class];
}

+ (void)setCellClass:(Class)classId
{
    cellClass = classId;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        NSCell    *cell = [[cellClass alloc] init];
        [self setCell:cell];
    }
    
    return self;
}

- (NSArray *)renderers
{
   return [[self cell] renderers];
}

- (NSUInteger)renderersCount
{
   return [[self cell] renderersCount];
}

- (AJRPathRenderer *)rendererAtIndex:(NSUInteger)index
{
   return [[self cell] rendererAtIndex:index];
}

- (NSUInteger)indexOfRenderer:(AJRPathRenderer *)renderer
{
   return [[self cell] indexOfRenderer:renderer];
}

- (AJRPathRenderer *)lastRenderer
{
   return [[self cell] lastRenderer];
}

- (void)addRenderer:(AJRPathRenderer *)renderer
{
   [[self cell] addRenderer:renderer];
   [self setNeedsDisplay:YES];
}

- (void)insertRenderer:(AJRPathRenderer *)renderer atIndex:(NSUInteger)index
{
   [[self cell] insertRenderer:renderer atIndex:index];
   [self setNeedsDisplay:YES];
}

- (void)removeRendererAtIndex:(NSUInteger)index
{
   [[self cell] removeRendererAtIndex:index];
   [self setNeedsDisplay:YES];
}

- (void)removeRenderersAtIndexes:(NSIndexSet *)indexes
{
    [[self cell] removeRenderersAtIndexes:indexes];
    [self setNeedsDisplay:YES];
}

- (void)moveRendererAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
   [[self cell] moveRendererAtIndex:fromIndex toIndex:toIndex];
}

- (IBAction)takeAlignmentFrom:(id)sender
{
    if ([sender isKindOfClass:[NSMatrix class]]) {
        [self setAlignment:[[sender selectedCell] tag]];
    } else {
        [self setAlignment:[sender intValue]];
    }
}

@end

