/*
 AJRPreferencesModule.m
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

#import "AJRPreferencesModule.h"

#import "AJRImages.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRPreferencesModule

- (id)init {
    if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]])) {
    }
    return self;
}

- (NSString *)name {
    return [[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrpreferencesmodule"] valueForProperty:@"name" onExtensionForClass:[self class]] valueForKey:@"name"];
    //return [[AJRPlugInManager sharedPlugInManager] valueForProperty:@"name" inExtension:[self class] andFactory:@"ajrpreferencesmodule"];
}

- (NSString *)toolTip {
    NSString *toolTip = [[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrpreferencesmodule"] valueForProperty:@"tooltip" onExtensionForClass:[self class]] valueForKey:@"name"];
//    NSString *toolTip = [[AJRPlugInManager sharedPlugInManager] valueForProperty:@"tooltip" inExtension:[self class] andFactory:@"ajrpreferencesmodule"];

    return toolTip ?: [self name];
}

- (NSImage *)image {
    if (!_image) {
        NSSize size;
        NSString *imageName = [[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrpreferencesmodule"] valueForProperty:@"image" onExtensionForClass:[self class]] valueForKey:@"name"];
//        NSString    *imageName = [[AJRPlugInManager sharedPlugInManager] valueForProperty:@"image" inExtension:[self class] andFactory:@"ajrpreferencesmodule"];
        
        if (imageName == nil) imageName = [self name];
        
        _image = [AJRImages imageNamed:imageName forObject:self];
        if (_image == nil) _image = [AJRImages imageNamed:NSStringFromClass([self class]) forObject:self];
        if (_image == nil) _image = [NSImage imageNamed:@"NSApplicationIcon"];
        
        size = [_image size];
        if (size.width > 32 || size.height > 32) {
            NSImage *originalImage = _image;
            _image = [originalImage copy];
            [_image setSize:(NSSize){32.0, 32.0}];
        }
    }
    
    return _image;
}

- (BOOL)isPreferred {
    return [[[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrpreferencesmodule"] valueForProperty:@"preferred" onExtensionForClass:[self class]] valueForKey:@"name"] boolValue];
//    return [[[AJRPlugInManager sharedPlugInManager] valueForProperty:@"preferred" inExtension:[self class] andFactory:@"ajrpreferencesmodule"] boolValue];
}

- (void)update {
}

@end

