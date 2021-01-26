
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

