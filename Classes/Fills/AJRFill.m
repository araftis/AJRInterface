/*
 AJRFill.m
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

#import "AJRFill.h"

static NSMutableDictionary *_fills = nil;
static NSMutableDictionary *_fillsByName = nil;
static NSMutableDictionary *_fillViews = nil;

NSString *AJRFillDidUpdateNotification = @"AJRFillDidUpdateNotification";
NSString *AJRFillWillUpdateNotification = @"AJRFillWillUpdateNotification";

@implementation AJRFill

+ (void)initialize {
    if (_fills == nil) {
        _fills = [[NSMutableDictionary alloc] init];
        _fillsByName = [[NSMutableDictionary alloc] init];
        _fillViews = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerFill:(Class)aClass {
    @autoreleasepool {
        [_fills setObject:aClass forKey:NSStringFromClass(aClass)];
        [_fillsByName setObject:aClass forKey:[aClass name]];
    }
}

+ (NSString *)name {
    return @"None";
}

- (void)willUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRFillWillUpdateNotification object:self];
}

- (void)didUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRFillDidUpdateNotification object:self];
}

+ (NSArray *)fillTypes {
    return [[_fills allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray *)fillNames {
    return [[_fillsByName allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (AJRFill *)fillForType:(NSString *)type {
    Class aClass = [_fills objectForKey:type];
    
    if (aClass) return [[aClass alloc] init];
    
    return [[[self class] alloc] init];
}

+ (AJRFill *)fillForName:(NSString *)type {
    Class aClass = [_fillsByName objectForKey:type];
    
    if (aClass) return [[aClass alloc] init];
    
    return [[[self class] alloc] init];
}

- (void)fillPath:(NSBezierPath *)aPath {
}

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView {
}

- (void)fillRect:(NSRect)aRect {
    [self fillRect:aRect controlView:nil];
}

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView {
    [self fillPath:[NSBezierPath bezierPathWithRect:rect] controlView:controlView];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}

- (BOOL)isOpaque {
    return YES;
}

@end
