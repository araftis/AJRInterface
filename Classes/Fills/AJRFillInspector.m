/*
AJRFillInspector.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
