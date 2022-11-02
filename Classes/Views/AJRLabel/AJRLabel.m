/*
 AJRLabel.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

