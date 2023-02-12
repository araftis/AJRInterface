/*
 AJRPathRendererInspector.m
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

#import "AJRPathRendererInspector.h"

#import "AJRPathRenderer.h"
#import "AJRPathRendererInspectorModule.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRPathRendererInspector

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    inspectorModules = [[NSMutableDictionary alloc] init];
    
    [self setTitle:@"Path Renderer Inspector"];
    [self setBoxType:NSBoxPrimary];
    [self setTitlePosition:NSNoTitle];
    [self setTransparent:YES];
    [self setContentViewMargins:NSZeroSize];
    
    return self;
}


- (void)setPathRenderer:(AJRPathRenderer *)aPathRenderer;
{
    if (renderer != aPathRenderer) {
        renderer = aPathRenderer;
        
        if (renderer) {
            inspectorModule = [inspectorModules objectForKey:[[renderer class] name]];
            if (!inspectorModule) {
                Class        class = NSClassFromString(AJRFormat(@"%@InspectorModule", NSStringFromClass([renderer class])));
                if (class) {
                    inspectorModule = [[class alloc] init];
                    [inspectorModules setObject:inspectorModule forKey:[[renderer class] name]];
                }
            }
        }
        
        [self setContentView:[inspectorModule view]];
    }
    
    [inspectorModule setPathRenderer:renderer];
}

- (AJRPathRenderer *)renderer;
{
    return renderer;
}

@end
