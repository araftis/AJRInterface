/*
AJREmbossRendererInspectorModule.m
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

#import "AJREmbossRendererInspectorModule.h"

#import "AJREmbossRenderer.h"

@implementation AJREmbossRendererInspectorModule

- (void)update
{
   [colorWell setColor:[(AJREmbossRenderer *)renderer color]];
   [highlightColorWell setColor:[(AJREmbossRenderer *)renderer highlightColor]];
   [shadowColorWell setColor:[(AJREmbossRenderer *)renderer shadowColor]];
   [angleField setFloatValue:[(AJREmbossRenderer *)renderer angle]];
   [errorField setFloatValue:[(AJREmbossRenderer *)renderer error]];
   [widthField setFloatValue:[(AJREmbossRenderer *)renderer width]];
}

- (void)setColor:(id)sender
{
   [(AJREmbossRenderer *)renderer setColor:[sender color]];
}

- (void)setHighlightColor:(id)sender
{
   [(AJREmbossRenderer *)renderer setHighlightColor:[sender color]];
}

- (void)setShadowColor:(id)sender
{
   [(AJREmbossRenderer *)renderer setShadowColor:[sender color]];
}

- (void)setAngle:(id)sender
{
   [(AJREmbossRenderer *)renderer setAngle:[sender floatValue]];
}

- (void)setWidth:(id)sender
{
   [(AJREmbossRenderer *)renderer setWidth:[sender floatValue]];
}

- (void)setError:(id)sender
{
   [(AJREmbossRenderer *)renderer setError:[sender floatValue]];
}

@end
