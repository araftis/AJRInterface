/*
AJRDropShadowBorderInspectorModule.m
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

#import "AJRDropShadowBorderInspectorModule.h"

#import "AJRDropShadowBorder.h"

@implementation AJRDropShadowBorderInspectorModule

- (void)update
{
    [shallowCheckBox setState:[(AJRDropShadowBorder *)border isShallow]];
    [clipCheckBox setState:[(AJRDropShadowBorder *)border doesClip]];
    [radiusSlider setFloatValue:[(AJRDropShadowBorder *)border radius]];
    [radiusText setFloatValue:[(AJRDropShadowBorder *)border radius]];    
}

- (void)setIsShallow:(id)sender
{
    [(AJRDropShadowBorder *)border setShallow:[sender state]];
}

- (void)setDoesClip:(id)sender
{
    [(AJRDropShadowBorder *)border setClip:[sender state]];
}

- (void)setRadius:(id)sender
{
    float    radius = [sender intValue];
    
    if (radius < 0.0) radius = 0.0;
    if (radius > 30.0) radius = 30.0;
    [radiusText setFloatValue:radius];
    [radiusSlider setFloatValue:radius];
    [(AJRDropShadowBorder *)border setRadius:radius];
}

@end
